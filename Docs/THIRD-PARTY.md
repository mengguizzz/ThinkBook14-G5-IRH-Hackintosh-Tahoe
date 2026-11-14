# 第三方组件和分发说明

由 [mengguizzz](https://github.com/mengguizzz) 整理。`NOTICE.md` 不改变第三方许可证。完整 EFI 中组件是否启用以 config.plist 为准；版本和启用状态见 COMPONENTS.csv。

| 组件 | 来源 / 许可证入口 |
| --- | --- |
| OpenCore、OpenRuntime、OpenCanopy、OpenShell、ResetNvramEntry | [acidanthera/OpenCorePkg](https://github.com/acidanthera/OpenCorePkg) |
| GoldenGate、HfsPlus.efi | [acidanthera/OcBinaryData](https://github.com/acidanthera/OcBinaryData)，遵循二进制和资源原有授权 |
| WhateverXe / Compat 源码 | [b00t0x/WhateverXe](https://github.com/b00t0x/WhateverXe)，LICENSE.txt 随源码保留 |
| OCLP | [b00t0x/OpenCore-Legacy-Patcher](https://github.com/b00t0x/OpenCore-Legacy-Patcher)，LICENSE.txt 随 Python 源码保留 |
| Lilu | [acidanthera/Lilu](https://github.com/acidanthera/Lilu) |
| VirtualSMC 和 SMC 插件 | [acidanthera/VirtualSMC](https://github.com/acidanthera/VirtualSMC) |
| AppleALC | [acidanthera/AppleALC](https://github.com/acidanthera/AppleALC) |
| AMFIPass Mod | [WhateverXe-Graphics extras](https://github.com/b00t0x/WhateverXe-Graphics/tree/main/extras) |
| AirportItlwm-Tahoe | [kgp-macPro/AirportItlwm-Tahoe](https://github.com/kgp-macPro/AirportItlwm-Tahoe)，派生于 [OpenIntelWireless/itlwm](https://github.com/OpenIntelWireless/itlwm) |
| IntelBluetoothFirmware / IntelBTPatcher | [OpenIntelWireless/IntelBluetoothFirmware](https://github.com/OpenIntelWireless/IntelBluetoothFirmware)，本机采用 lshbluesky 2.5.3 构建；固件另遵循上游固件通知 |
| BlueToolFixup | [acidanthera/BrcmPatchRAM](https://github.com/acidanthera/BrcmPatchRAM) |
| IntelMausi | [acidanthera/IntelMausi](https://github.com/acidanthera/IntelMausi) |
| IntelMausiEthernet | [Mieze/IntelMausiEthernet](https://github.com/Mieze/IntelMausiEthernet)，原 Apple 派生代码通知另保留 |
| CPUFriend | [acidanthera/CPUFriend](https://github.com/acidanthera/CPUFriend)；DataProvider 是本机配置数据 |
| CpuTopologyRebuild | [b00t0x/CpuTopologyRebuild](https://github.com/b00t0x/CpuTopologyRebuild) |
| RestrictEvents / NVMeFix / BrightnessKeys | [RestrictEvents](https://github.com/acidanthera/RestrictEvents)、[NVMeFix](https://github.com/acidanthera/NVMeFix)、[BrightnessKeys](https://github.com/acidanthera/BrightnessKeys) |
| NoTouchID | [al3xtjames/NoTouchID](https://github.com/al3xtjames/NoTouchID) |
| ECEnabler | [1Revenger1/ECEnabler](https://github.com/1Revenger1/ECEnabler) |
| USBToolBox / UTBMap | [USBToolBox/kext](https://github.com/USBToolBox/kext)，UTBMap 是本机映射 |
| VoodooI2C / VoodooI2CHID | [VoodooI2C/VoodooI2C](https://github.com/VoodooI2C/VoodooI2C)，GPL 及上游组件通知 |
| VoodooPS2Controller | [acidanthera/VoodooPS2](https://github.com/acidanthera/VoodooPS2) |
| YogaSMC | [zhen-zen/YogaSMC](https://github.com/zhen-zen/YogaSMC) |
| XHCI-unsupported | [RehabMan/OS-X-USB-Inject-All](https://github.com/RehabMan/OS-X-USB-Inject-All)，注入配置 |
| IOSkywalkFamily / IO80211FamilyLegacy / AirPortBrcmNIC | Apple 历史无线组件，保留原 bundle、签名资源和 Apple 标识，不属于本项目自由授权的原创代码 |

Apple 组件不因出现在配置集合中而改变所有权或变成可任意再授权的软件。没有打包完整 macOS 镜像、GPU/音频根补丁安装包、KDK、Apple 私钥或账户信息。不能把整个集合改标为自己拥有的 MIT/BSD 项目。

许可证通知副本见 Licenses；组件固件许可和对应源码以原项目为准。
