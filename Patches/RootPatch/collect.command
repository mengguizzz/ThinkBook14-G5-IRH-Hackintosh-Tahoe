#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
report="$PWD/logs/$(/bin/date +%Y%m%d-%H%M%S)-collect"
/bin/mkdir -p "$report"
{
    /usr/bin/sw_vers
    /usr/bin/csrutil status || true
    /usr/bin/csrutil authenticated-root status || true
    /usr/sbin/sysctl machdep.cpu.brand_string || true
} > "$report/system.txt" 2>&1
/usr/bin/kmutil showloaded > "$report/loaded-kexts.txt" 2>&1 || true
/usr/bin/kmutil showloaded --show-mach-headers > "$report/loaded-kext-identities.txt" 2>&1 || true
/usr/sbin/ioreg -l -w0 -r -c AirportItlwm > "$report/airportitlwm-controller.txt" 2>&1 || true
/usr/sbin/ioreg -l -w0 -r -n 'CNVW@14,3' > "$report/cnvw-controller.txt" 2>&1 || true
{
    /usr/sbin/sysctl kern.bootargs
    /usr/sbin/nvram boot-args
    /usr/sbin/ioreg -l -w0 -r -c AppleVTD
} > "$report/wifi-boot-dma.txt" 2>&1 || true
/usr/sbin/system_profiler SPAudioDataType SPAirPortDataType SPDisplaysDataType SPBluetoothDataType SPUSBDataType > "$report/hardware.txt" 2>&1 || true
/usr/sbin/ioreg -l -w0 -r -c IOPCIDevice > "$report/pci.txt" 2>&1 || true
/usr/sbin/ioreg -l -w0 -r -c IOUSBHostDevice > "$report/usb-devices.txt" 2>&1 || true
/usr/sbin/ioreg -l -w0 -p IOUSB > "$report/usb-topology.txt" 2>&1 || true
/usr/sbin/ioreg -l -w0 -r -c AppleUSBHostPort > "$report/usb-host-ports.txt" 2>&1 || true
/usr/sbin/ioreg -l -w0 -r -c IO80211Interface > "$report/wifi-interface.txt" 2>&1 || true
/usr/sbin/ioreg -l -w0 -r -c IOBluetoothHCIController > "$report/bluetooth-controller.txt" 2>&1 || true
/usr/sbin/ioreg -l -w0 -r -c AppleBacklightDisplay > "$report/backlight-display.txt" 2>&1 || true
/usr/sbin/ioreg -l -w0 -r -c IOFramebuffer > "$report/framebuffers.txt" 2>&1 || true
{
    /usr/sbin/ioreg -l -w0 -r -k AppleClamshellState | /usr/bin/grep -E 'AppleClamshellState|AppleClamshellCausesSleep'
    /usr/bin/pmset -g custom
    /usr/sbin/sysctl machdep.cpu.brand_string hw.cputype hw.cpusubtype hw.ncpu
    /usr/sbin/nvram '4D1FDA02-38C7-4A6A-9CC6-4BCCA8B30102:revcpuname'
    /usr/sbin/nvram '4D1FDA02-38C7-4A6A-9CC6-4BCCA8B30102:revcpu'
    /usr/sbin/nvram bluetoothExternalDongleFailed
    /usr/sbin/nvram bluetoothInternalControllerInfo
} > "$report/lid-cpu-nvram.txt" 2>&1 || true
/usr/sbin/networksetup -listallhardwareports > "$report/network-ports.txt" 2>&1 || true
/sbin/ifconfig -a > "$report/interfaces.txt" 2>&1 || true
echo 'Collecting wireless/Bluetooth logs; sudo may request your password. No settings are changed.'
if sudo -v; then
    sudo /usr/bin/wdutil info > "$report/wdutil-info.txt" 2>&1 || true
    sudo /usr/bin/log show --last 5m --style compact --info --predicate '(process == "bluetoothd") OR (process == "BlueTool") OR (process == "airportd") OR (process == "wifid") OR ((process == "kernel") AND ((eventMessage CONTAINS[c] "itlwm") OR (eventMessage CONTAINS[c] "bluetooth") OR (eventMessage CONTAINS[c] "firmware")))' > "$report/wireless-bluetooth-log.txt" 2>&1 || true
fi
/usr/sbin/diskutil list > "$report/disks.txt" 2>&1 || true
/usr/sbin/diskutil apfs listSnapshots / > "$report/snapshots.txt" 2>&1 || true
for plist in /System/Library/Extensions/AppleHDA.kext/Contents/Info.plist /System/Library/CoreServices/OpenCore-Legacy-Patcher.plist /Applications/OpenCore-Patcher.app/Contents/Info.plist; do
    if [[ -f "$plist" ]]; then
        { echo "$plist"; /usr/bin/plutil -p "$plist"; } >> "$report/plists.txt" 2>&1
    fi
done
echo "Collected (this script did not modify system settings or install patches): $report"
