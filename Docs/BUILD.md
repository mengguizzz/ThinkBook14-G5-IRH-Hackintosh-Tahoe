# 构建 WhateverXe

来源：[jkbuha/WhateverXe-contrib](https://github.com/jkbuha/WhateverXe-contrib) 的 `xps9720-igpu` 分支，提交 `91fdb96fc08b931c8e90e1bccdda78acf392f1e1`，基于 b00t0x/WhateverXe。源码及上游中日文说明原样保留在 `Source/WhateverXe`。差异见 [WHATEVERXE-CHANGES.md](WHATEVERXE-CHANGES.md)。

## 环境与依赖

使用真实 macOS，安装 Xcode Command Line Tools、Python 3.9+；编译器和链接器通过 `xcrun` 调用。普通 WSL 安装 Python/clang 并不能替代 macOS 的构建环境。本仓库没有提供经过验证的通用 WSL 交叉编译工具链。

```sh
xcode-select --install
```

从 [acidanthera/MacKernelSDK](https://github.com/acidanthera/MacKernelSDK) 取得 SDK，固定到实机成功构建所用提交 `05094e5e88cec7caedbfb35e8449ed0db94bf95b`。本仓库已在 `Source/BuildDependencies/LiluFixed.kext` 保存当时使用的 Lilu 开发资源。SDK 放到以下位置（不需要创建示意中的 Lilu.kext，构建时显式指定已保存的开发资源）：

```text
Source/WhateverXe/
├─ MacKernelSDK/
│  ├─ Headers/
│  └─ Library/x86_64/libkmod.a
├─ Lilu.kext/
│  └─ Contents/Resources/
├─ tools/
└─ WhateverXe/
```

Lilu 开发资源来自 [acidanthera/Lilu](https://github.com/acidanthera/Lilu)，许可见 [Lilu 许可证](Licenses/acidanthera--Lilu.txt)。此快照只有头文件和库源码，没有运行时 Info.plist 或驱动二进制，不能装进 EFI。未确认其相对 Lilu 上游的具体修改；`plugin_start.cpp` SHA256 为 `cb6e866c53ed2a6cc0061db5ee9ddadc3a8edf1e0e38523c3766523a1851928e`。不同依赖、编译器版本可能影响结果，源码可构建不等于位级可复现。

也可在准备好 SDK 后，从仓库根目录运行 `bash Tools/build-macos.sh`。它按成功的 U 盘构建流程适配路径，先测试再编译，将输出保存在被 Git 忽略的 BuildOutput，不修改 EFI。

## 测试与 RELEASE 构建

```sh
cd Source/WhateverXe
python3 tools/test.py
python3 tools/build.py --release --lilu ../BuildDependencies/LiluFixed.kext --output build/RELEASE
python3 tools/check_compat_version.py build/RELEASE
```

运行前可用 `python3 tools/build.py --help` 和 `python3 tools/check_compat_version.py --help` 核对该快照参数。构建器会检查 Compat plist/ABI，不应为了编译通过随意提高兼容性下限。

测试输出会说明 optional native replay 的缺失；没有提供精确 Apple 驱动时，不能把默认 CPU 测试通过视为所有 replay 或 GPU 功能已验证。

输出在 `build/RELEASE`，包括 WhateverXe.kext 和 AppleIntelTGLCompat.kext。不要把单独编译的 Compat 装入 EFI，系统侧使用 Graphics 0.4.4 配套组件。U 盘成功构建的 CPU 测试摘要为 221 项通过、无失败，部分可选模式跳过；不代表完整 GPU 或睡眠资格验证。

## 替换与验证

备份当前可用 EFI，使用构建产物替换 WhateverXe.kext，保持与 Lilu、Graphics 0.4.4、AMFIPass 1.4.1 Mod 的配套关系。更新 config 的 kext 引用后运行匹配版本的 ocvalidate，再实机验证。GPU 系统组件安装见 [ROOT-PATCHING.md](ROOT-PATCHING.md)。

本机成功使用的 WhateverXe 可执行文件 SHA256：

```text
C32D8B0149D4AB68DBF3E5C1BC84B1B90C7567606AAA63A436A9BEA0BF8CE728
```

该哈希用于识别随 EFI 提供的成功产物，不承诺任何环境重新编译都得到相同哈希。本次仓库整理没有重新编译或重新做硬件资格验证。
