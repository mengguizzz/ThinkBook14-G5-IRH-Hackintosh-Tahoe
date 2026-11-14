"""CPU checks of real detector methods with macOS IOKit/validation unexecuted.

Basis: donor forks' AX211 admission and Tahoe AppleHDA restoration. Check retained
native OS exclusion, exact physical identity, and no graphics patch selection.
This is not a test of kernel cache creation or the macOS root patch workflow.
"""
import ast
from dataclasses import dataclass
import enum
from pathlib import Path
from types import SimpleNamespace
from typing import ClassVar
import local_patch

ROOT = Path(__file__).parent


class BaseHardware:
    def __init__(self, major, minor, build, constants):
        self._xnu_major = major
        self._os_build = build
        self._computer = constants.computer


@dataclass
class WirelessCard:
    vendor_id: int
    device_id: int

    def __post_init__(self):
        self.detect_chipset()


class Broadcom(WirelessCard):
    class Chipsets(enum.Enum):
        AirPortBrcm4360 = 1
        AirportBrcmNIC = 2
        AirPortBrcmNICThirdParty = 3


scope = dict(
    BaseHardware=BaseHardware, device_probe=SimpleNamespace(Broadcom=Broadcom, WirelessCard=WirelessCard),
    dataclass=dataclass, ClassVar=ClassVar, enum=enum,
    os_data=SimpleNamespace(sonoma=SimpleNamespace(value=23), tahoe=SimpleNamespace(value=25)),
    smbios_data=SimpleNamespace(smbios_dictionary={}), physical_gpu=local_patch.physical_gpu,
    selected_types=local_patch.selected_types, args=SimpleNamespace(selection="both"),
    HardwarePatchsetDetection=type("HardwarePatchsetDetection", (), {}), __name__="__main__",
)
for path in ("networking/modern_wireless.py", "misc/modern_audio.py"):
    tree = ast.parse((ROOT / "opencore_legacy_patcher/sys_patch/patchsets/hardware" / path).read_text())
    classes = [node for node in tree.body if isinstance(node, ast.ClassDef)]
    exec(compile(ast.fix_missing_locations(ast.Module(body=[ast.ImportFrom(module="__future__", names=[ast.alias(name="annotations")], level=0)] + classes, type_ignores=[])), path, "exec"), scope)
scope["original_wifi"] = scope["ModernWireless"].present
scope["original_audio"] = scope["ModernAudio"].present
tree = ast.parse((ROOT / "local_patch.py").read_text())
main = next(node for node in tree.body if isinstance(node, ast.FunctionDef) and node.name == "main")
adaptation = [node for node in main.body if isinstance(node, ast.ClassDef) or
              isinstance(node, ast.Assign) and isinstance(node.targets[0], ast.Attribute) and
              isinstance(node.targets[0].value, ast.Name) and node.targets[0].value.id in
              {"ModernWireless", "ModernAudio", "HardwarePatchsetDetection"}]
exec(compile(ast.Module(body=adaptation, type_ignores=[]), "local adaptation", "exec"), scope)
wifi_type, audio_type = scope["ModernWireless"], scope["ModernAudio"]
intel = scope["IntelAX211"]
gpu = SimpleNamespace(vendor_id=0x8086, device_id=0xA7A0)
computer = SimpleNamespace(wifi=intel(0x8086, 0x51F1), gpus=[gpu], real_model="MacBookPro16,2")
constants = SimpleNamespace(computer=computer)
wifi, audio = wifi_type(25, 6, "25G83", constants), audio_type(25, 6, "25G83", constants)
assert wifi.present() and not wifi.native_os()
assert audio.present() and not audio.native_os()
computer.wifi = intel(0x8086, 0x1234)
assert not wifi.present(), "Unknown Intel device must not be force-admitted"
computer.wifi = intel(0x8086, 0x51F1)
assert not wifi_type(23, 0, "23A344", constants).present(), "Do not force the Ventura Airport route before Sequoia"
assert audio_type(24, 0, "24A335", constants).native_os(), "Sequoia keeps native audio behavior"
assert audio_type(25, 0, "25A5279m", constants).native_os(), "Tahoe beta 1 keeps native audio"
assert not audio_type(25, 0, "25A5279m", constants).present()
computer.gpus = [SimpleNamespace(vendor_id=0x8086, device_id=0xA7A0,
                                vendor_id_unspoofed=0x8086, device_id_unspoofed=0x1234)]
assert not audio.present(), "Spoofed display identity must not widen local audio scope"
computer.gpus = [gpu]
other = object()
for selection, expected in (("both", [wifi, audio]), ("wifi", [wifi]), ("audio", [audio])):
    scope["args"].selection = selection
    actual = scope["HardwarePatchsetDetection"]()._strip_incompatible_hardware([other, wifi, audio])
    assert actual == expected, "Nonselected/graphics handlers must not reach patch generation"
for version, gpus, loaded in (("26.6.2", [gpu], "1.4.1"),
                              ("26.7", [], "1.4.1"), ("26.7", [gpu], None)):
    try:
        local_patch.require_baseline(version, gpus, loaded, "/nonexistent/amfipass")
    except RuntimeError:
        pass
    else:
        raise AssertionError("Invalid baseline must stop before opening an EFI binary")
print("PASS: exact AX211 detection, Tahoe audio/native boundaries, physical GPU guard, selected handler propagation.")
print("OMITTED: IOKit discovery, real Broadcom delegation, AMFI/SIP validation, signed DMG mount, KDK, root volume, AuxKC and boot.")
