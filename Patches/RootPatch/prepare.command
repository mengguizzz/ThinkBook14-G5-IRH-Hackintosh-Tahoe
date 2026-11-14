#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
tool_dir="$PWD"
[[ "$(uname -s)" == Darwin ]] || { echo 'Run this on macOS.'; exit 1; }
pkg="${1:-$tool_dir/../WEX-author-OCLP-3.0.0-rc.3+m.3/OpenCore-Patcher.pkg}"
[[ -f "$pkg" ]] || { echo 'Supply the author OpenCore-Patcher.pkg path as argument 1.'; exit 1; }
expected=754755b50f30fea3c41c366e5ae878016604c3c799dd1a82baa0a0cf3e18089f
actual=$(/usr/bin/shasum -a 256 "$pkg" | /usr/bin/awk '{print $1}')
[[ "$actual" == "$expected" ]] || { echo 'Wrong package: SHA256 does not match the verified author rc.3+m.3 release.'; exit 1; }
python_bin=''
for candidate in /Library/Frameworks/Python.framework/Versions/3.11/bin/python3 /Library/Frameworks/Python.framework/Versions/3.12/bin/python3 /Library/Frameworks/Python.framework/Versions/3.13/bin/python3 /opt/homebrew/bin/python3.11 /usr/local/bin/python3.11; do
    if [[ -x "$candidate" ]]; then python_bin="$candidate"; break; fi
done
[[ -n "$python_bin" ]] || { echo 'Install Python 3.11 (macOS universal2 installer) from https://www.python.org/downloads/macos/ then run this again. Apple system Python is not used.'; exit 1; }
work_dir=$(/usr/bin/mktemp -d /Users/Shared/WEX-RootPatch.XXXXXX)
echo "Preparing in $work_dir"
[[ -f "$tool_dir/source/local_patch.py" ]] || { echo 'The source directory is missing.'; exit 1; }
/usr/bin/ditto "$tool_dir/source" "$work_dir/source"
/usr/sbin/pkgutil --expand-full "$pkg" "$work_dir/pkg"
payload_dmg=$(/usr/bin/find "$work_dir/pkg" -type f -name payloads.dmg -print -quit)
universal_dmg=$(/usr/bin/find "$work_dir/pkg" -type f -name Universal-Binaries.dmg -print -quit)
[[ -n "$payload_dmg" && -n "$universal_dmg" ]] || { echo 'Author package resources not found; preserve this folder and report the error.'; exit 1; }
/bin/mkdir "$work_dir/resources"
/usr/bin/hdiutil attach "$payload_dmg" -readonly -nobrowse -mountpoint "$work_dir/resources" -passphrase password
trap '/usr/bin/hdiutil detach "$work_dir/resources" >/dev/null 2>&1 || true' EXIT
/usr/bin/ditto "$work_dir/resources" "$work_dir/source/payloads"
/bin/cp "$universal_dmg" "$work_dir/source/Universal-Binaries.dmg"
/usr/bin/hdiutil detach "$work_dir/resources"
trap - EXIT
"$python_bin" -m venv "$work_dir/venv"
"$work_dir/venv/bin/python3" -m pip install -r "$work_dir/source/requirements.txt"
echo "$work_dir" > "$tool_dir/local-path.txt"
echo "Ready. Run: bash \"$tool_dir/run.command\" inspect both"
echo 'No root patches were installed. Temporary package resources are retained for provenance.'
