#!/usr/bin/env python3
"""Local AX211/audio entry point; b00t0x rc.3+m.3 engine and payloads.

Detection adaptation informed by laobamac/OCLP-Mod 3.1.9 and
JeoJay127/OCLP-X 3.0.0-rc.5. Their payloads are deliberately not imported.
"""
import argparse
import enum
import hashlib
import json
import logging
import os
from pathlib import Path
import plistlib
import subprocess
import sys
from dataclasses import dataclass
from typing import ClassVar


def selected_types(items, selection, wireless, audio):
    allowed = {"wifi": (wireless,), "audio": (audio,), "both": (wireless, audio)}
    return [item for item in items if isinstance(item, allowed[selection])]


def physical_gpu(gpu):
    vendor = getattr(gpu, "vendor_id_unspoofed", -1)
    device = getattr(gpu, "device_id_unspoofed", -1)
    return (gpu.vendor_id if vendor in (-1, None) else vendor,
            gpu.device_id if device in (-1, None) else device)


def require_baseline(version, gpus, loaded, efi_amfi):
    if tuple(int(x) for x in version.split(".")) < (26, 7):
        raise RuntimeError("Graphics 0.4.4 documents Tahoe >=26.7; record this OS version before patching.")
    if not any(physical_gpu(g) == (0x8086, 0xA7A0) for g in gpus):
        raise RuntimeError("This local tool is scoped to the verified physical 8086:A7A0 machine.")
    if not loaded:
        raise RuntimeError("AMFIPass is not loaded.")
    digest = hashlib.sha256(Path(efi_amfi).read_bytes()).hexdigest()
    if digest != "2d36aeca1740b258e6bb0b66844b5bfb59a0edb7cdd9ef78206689e5d223d8dc":
        raise RuntimeError("Selected EFI AMFIPass does not match the verified Mod binary.")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("action", choices=("inspect", "apply", "revert"))
    parser.add_argument("selection", choices=("wifi", "audio", "both"), default="both", nargs="?")
    parser.add_argument("--efi-amfi", help="AMFIPass binary on the EFI actually used to boot")
    args = parser.parse_args()
    # Some OCLP utilities parse sys.argv as their own CLI.
    sys.argv = [sys.argv[0]]
    from opencore_legacy_patcher.constants import Constants
    from opencore_legacy_patcher.detections import device_probe, os_probe
    from opencore_legacy_patcher.support import subprocess_wrapper, utilities
    from opencore_legacy_patcher.sys_patch.patchsets.detect import HardwarePatchsetDetection
    from opencore_legacy_patcher.sys_patch.patchsets.hardware.networking.modern_wireless import ModernWireless
    from opencore_legacy_patcher.sys_patch.patchsets.hardware.misc.modern_audio import ModernAudio
    from opencore_legacy_patcher.sys_patch.sys_patch import PatchSysVolume

    @dataclass
    class IntelAX211(device_probe.WirelessCard):
        VENDOR_ID: ClassVar[int] = 0x8086

        class Chipsets(enum.Enum):
            AX211 = "Intel AX211 51F1"
            Unknown = "Unknown"

        def detect_chipset(self):
            self.chipset = self.Chipsets.AX211 if self.device_id == 0x51F1 else self.Chipsets.Unknown

    c = Constants()
    probe = os_probe.OSProbe()
    c.detected_os = probe.detect_kernel_major()
    c.detected_os_minor = probe.detect_kernel_minor()
    c.detected_os_build = probe.detect_os_build()
    c.detected_os_version = probe.detect_os_version()
    c.computer = device_probe.Computer.probe()
    c.host_is_hackintosh = c.computer.firmware_vendor not in (None, "", "Apple")
    c.launcher_script = str(Path(__file__).resolve())
    c.launcher_binary = sys.executable
    c.cli_mode = True
    c.gui_mode = False
    c.wxpython_variant = True
    c.commit_info = ("Local AX211/audio adaptation", "2026-11-14", "local:WEX-AX211-audio-v1")
    c.ignore_updates = True
    logging.basicConfig(level=logging.INFO, format="%(message)s", stream=sys.stdout)

    original_wifi = ModernWireless.present
    original_audio = ModernAudio.present
    ModernWireless.present = lambda self: (
        self._xnu_major >= 24 and isinstance(self._computer.wifi, IntelAX211)
        and self._computer.wifi.device_id == 0x51F1
    ) or original_wifi(self)
    ModernAudio.present = lambda self: (
        self._xnu_major == 25 and self._os_build != "25A5279m"
        and any(physical_gpu(g) == (0x8086, 0xA7A0) for g in self._computer.gpus)
    ) or original_audio(self)
    # Apply the restriction inside production detection, including its later
    # invocation by PatchSysVolume. Requirements still use original validation.
    HardwarePatchsetDetection._strip_incompatible_hardware = lambda self, items: selected_types(
        items, args.selection, ModernWireless, ModernAudio
    )
    # Source runs use an explicitly elevated Python process rather than installing
    # a debug setuid helper or weakening its certificate checks.
    def root_run(*run_args, **kwargs):
        if os.geteuid() != 0:
            raise PermissionError("Apply/revert must be launched with sudo.")
        return subprocess.run(*run_args, **kwargs)
    subprocess_wrapper.run_as_root = root_run

    loaded = utilities.check_kext_loaded("com.dhinakg.AMFIPass")
    print("OS:", c.detected_os_version, c.detected_os_build, flush=True)
    print("Wi-Fi:", repr(c.computer.wifi), flush=True)
    print("AMFIPass loaded:", loaded, flush=True)
    print("AppleHDA exists:", Path("/System/Library/Extensions/AppleHDA.kext").exists(), flush=True)
    detector = HardwarePatchsetDetection(c)
    print("DETECTION:", json.dumps(detector.device_properties, indent=2, default=str), flush=True)
    print("PATCHES:", json.dumps(detector.patches, indent=2, default=str), flush=True)
    if args.action == "inspect":
        return
    if os.geteuid() != 0:
        raise PermissionError("Use the launcher; apply/revert require sudo.")
    if args.action == "apply":
        if not args.efi_amfi:
            raise RuntimeError("Pass --efi-amfi with the binary from the EFI used for this boot.")
        require_baseline(c.detected_os_version, c.computer.gpus, loaded, args.efi_amfi)
        if Path("/System/Library/CoreServices/OpenCore-Legacy-Patcher.plist").exists():
            raise RuntimeError("Existing root patches detected. Do not stack patchers; inspect the report first.")
        if args.selection in ("wifi", "both") and not isinstance(c.computer.wifi, IntelAX211):
            raise RuntimeError("Physical AX211 not detected; refusing to force wireless patches.")
        if not detector.patches or not detector.can_patch:
            raise RuntimeError("No applicable patches or original OCLP validation blocked patching.")
        if not Path("payloads/Universal-Binaries").exists():
            # Actual DMG mount is handled by OCLP; a local signed pkg provided it.
            if not Path("Universal-Binaries.dmg").is_file():
                raise RuntimeError("Author Mod payload disk image is missing; run prepare.command.")
        # Retain the original cleanup for metadata-listed old patches, but do not
        # let its unrelated pre-2021 relocation heuristic move working GPU kexts.
        # The clean-baseline gate above establishes there are no old root patches.
        from opencore_legacy_patcher.sys_patch.kernelcache.kernel_collection.support import KernelCacheSupport
        if args.action == "apply":
            KernelCacheSupport.clean_auxiliary_kc = lambda self: logging.info(
                "Clean baseline: preserving existing /Library/Extensions; no prior root patch kexts to clean."
            )
        print("Applying with original b00t0x validation, KDK, Mod payloads and snapshot creation.", flush=True)
        patcher = PatchSysVolume(c.computer.real_model, c)
        patcher.start_patch()
    else:
        record = Path("/System/Library/CoreServices/OpenCore-Legacy-Patcher.plist")
        if not record.is_file() or plistlib.loads(record.read_bytes()).get("Commit URL") != c.commit_info[2]:
            raise RuntimeError("No root patches from this local tool found; use the original patcher for other patches.")
        print("Reverting OCLP root snapshot. Graphics may need reinstalling after reboot.", flush=True)
        patcher = PatchSysVolume(c.computer.real_model, c)
        patcher.start_unpatch()
    if not c.root_patcher_succeeded:
        raise RuntimeError("OCLP did not report success. Save this log; do not treat this as a completed patch.")
    print("SUCCESS. No automatic reboot. Save the log before restarting.", flush=True)


if __name__ == "__main__":
    main()
