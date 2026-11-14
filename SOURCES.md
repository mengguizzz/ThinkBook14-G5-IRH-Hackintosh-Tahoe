# 来源与固定版本

- WhateverXe 源码：[jkbuha/WhateverXe-contrib](https://github.com/jkbuha/WhateverXe-contrib)，`xps9720-igpu` 分支，提交 [91fdb96fc08b931c8e90e1bccdda78acf392f1e1](https://github.com/jkbuha/WhateverXe-contrib/commit/91fdb96fc08b931c8e90e1bccdda78acf392f1e1)，基于 [b00t0x/WhateverXe](https://github.com/b00t0x/WhateverXe)。源码原样导出；许可证在 `Source/WhateverXe/LICENSE.txt`。
- Lilu 开发资源：`Source/BuildDependencies/LiluFixed.kext` 保存实机成功构建所用快照，来源 acidanthera/Lilu，只有开发头文件和库源码，不能当运行时驱动安装；许可证见 `Docs/Licenses/acidanthera--Lilu.txt`。SDK 固定提交与使用方式见编译指南。
- Graphics 0.4.4 与 AMFIPass 1.4.1 Mod：[b00t0x/WhateverXe-Graphics](https://github.com/b00t0x/WhateverXe-Graphics)。不附带 pkg、Apple 载荷或签名密钥。
- 无线/音频补丁引擎：[b00t0x/OpenCore-Legacy-Patcher](https://github.com/b00t0x/OpenCore-Legacy-Patcher)，本地适配记录的基础为 `3.0.0-rc.3+m.3` / `c2892cbb0e0060654d90c248560e5631e4042bde`。导出的是当时使用的 Python 源码副本，未包含 GUI 构建资源；保留其 `LICENSE.txt`。
- 检测逻辑参考：[laobamac/OCLP-Mod 3.1.9](https://github.com/laobamac/OCLP-Mod/releases/tag/3.1.9)、[JeoJay127/OCLP-X 3.0.0-rc.5](https://github.com/JeoJay127/OCLP-X/releases/tag/3.0.0-rc.5)。没有从这些分支混入二进制载荷。
- Wi-Fi：[kgp-macPro/AirportItlwm-Tahoe](https://github.com/kgp-macPro/AirportItlwm-Tahoe)。
- 蓝牙：[OpenIntelWireless/IntelBluetoothFirmware](https://github.com/OpenIntelWireless/IntelBluetoothFirmware)，实测使用 lshbluesky 构建的 2.5.3；BlueToolFixup 来自 [acidanthera/BrcmPatchRAM](https://github.com/acidanthera/BrcmPatchRAM)。
- OpenCore：[acidanthera/OpenCorePkg](https://github.com/acidanthera/OpenCorePkg)，实测 1.0.8；CPU 命名用 [RestrictEvents](https://github.com/acidanthera/RestrictEvents) 1.1.7。

根补丁安装包及载荷请从对应项目说明获取。完整 EFI 包含所用历史无线组件，见 Docs/THIRD-PARTY.md；不包含固件转储、机器身份、账户信息或实际采集日志。
