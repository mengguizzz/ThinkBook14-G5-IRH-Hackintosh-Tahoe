#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
tool_dir="$PWD"
[[ -f local-path.txt ]] || { echo 'Run prepare.command first.'; exit 1; }
work_dir=$(<local-path.txt)
[[ "$work_dir" == /Users/Shared/WEX-RootPatch.* && -f "$work_dir/source/local_patch.py" ]] || { echo 'Invalid prepared path.'; exit 1; }
action="${1:-inspect}"
selection="${2:-both}"
efi_binary="${3:-}"
case "$action" in inspect|apply|revert) ;; *) echo 'Action: inspect, apply, revert'; exit 1;; esac
case "$selection" in wifi|audio|both) ;; *) echo 'Selection: wifi, audio, both'; exit 1;; esac
stamp=$(/bin/date +%Y%m%d-%H%M%S)
log_dir="$tool_dir/logs/$stamp-$action-$selection"
/bin/mkdir -p "$log_dir"
log_dir=$(cd "$log_dir" && pwd)
{
    /usr/bin/sw_vers
    /usr/bin/csrutil status || true
    /usr/bin/csrutil authenticated-root status || true
    /usr/bin/kmutil showloaded || true
    /usr/sbin/diskutil apfs listSnapshots / || true
} > "$log_dir/baseline.txt" 2>&1
cd "$work_dir/source"
if [[ "$action" == inspect ]]; then
    "$work_dir/venv/bin/python3" -u local_patch.py inspect "$selection" 2>&1 | /usr/bin/tee "$log_dir/operation.log"
else
    if [[ "$action" == apply && ! -f "$efi_binary" ]]; then
        echo 'Argument 3 must be the AMFIPass binary in the EFI used to boot, e.g. /Volumes/EFI/EFI/OC/Kexts/AMFIPass.kext/Contents/MacOS/AMFIPass'
        exit 1
    fi
    backup_dir=$(/usr/bin/mktemp -d "$work_dir/backup-$stamp-$action-$selection.XXXXXX")
    printf '%s\n' "$backup_dir" > "$log_dir/backup-location.txt"
    echo "Saving /Library/Extensions and existing kernel collections locally to $backup_dir before root changes."
    backup_copy() {
        if ! sudo /usr/bin/ditto "$1" "$2" >> "$log_dir/backup.log" 2>&1; then
            /bin/cat "$log_dir/backup.log"
            echo "Backup failed. Root patcher was not started. Log: $log_dir/backup.log"
            exit 1
        fi
    }
    backup_copy /Library/Extensions "$backup_dir/Library-Extensions"
    if [[ -d /Library/KernelCollections ]]; then
        backup_copy /Library/KernelCollections "$backup_dir/Library-KernelCollections"
    fi
    if [[ -f /System/Library/CoreServices/OpenCore-Legacy-Patcher.plist ]]; then
        /bin/cp /System/Library/CoreServices/OpenCore-Legacy-Patcher.plist "$log_dir/previous-root-patches.plist"
        /bin/cp /System/Library/CoreServices/OpenCore-Legacy-Patcher.plist "$backup_dir/previous-root-patches.plist"
    fi
    # root is confined to this invocation; no debug privileged helper is installed.
    extra=()
    [[ "$action" != apply ]] || extra=(--efi-amfi "$efi_binary")
    sudo "$work_dir/venv/bin/python3" -u local_patch.py "$action" "$selection" "${extra[@]}" 2>&1 | /usr/bin/tee "$log_dir/operation.log"
fi
echo "Logs: $log_dir"
