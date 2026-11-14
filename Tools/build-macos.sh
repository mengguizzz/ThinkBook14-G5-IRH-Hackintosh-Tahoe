#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
[[ "$(uname -s)" == Darwin ]] || { echo 'Run on macOS'; exit 1; }
[[ $EUID != 0 ]] || { echo 'Do not use sudo for building'; exit 1; }
xcrun --find clang++ >/dev/null
[[ -d "$ROOT/Source/WhateverXe/MacKernelSDK/Headers" ]] || { echo 'Prepare the pinned MacKernelSDK first; see Docs/BUILD.md'; exit 1; }
TASK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/wex082.XXXXXX")"
echo "Temporary build directory: $TASK_DIR"
rsync -a --exclude=.git "$ROOT/Source/WhateverXe/" "$TASK_DIR/"
OUT="$ROOT/BuildOutput/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUT"
cd "$TASK_DIR"
python3 tools/test.py --output "$OUT/tests" 2>&1 | tee "$OUT/tests.log"
python3 tools/build.py --release --lilu "$ROOT/Source/BuildDependencies/LiluFixed.kext" --output build/RELEASE 2>&1 | tee "$OUT/build.log"
python3 tools/check_compat_version.py build/RELEASE
plutil -lint build/RELEASE/WhateverXe.kext/Contents/Info.plist
ditto build/RELEASE "$OUT/RELEASE"
shasum -a 256 "$OUT/RELEASE/WhateverXe.kext/Contents/MacOS/WhateverXe" | tee "$OUT/SHA256.txt"
echo "Build complete: $OUT"
echo 'EFI was not modified.'
