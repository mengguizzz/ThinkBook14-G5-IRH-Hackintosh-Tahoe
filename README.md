# Lenovo ThinkBook 14 G5+ IRH · macOS Tahoe

由 [@mengguizzz](https://github.com/mengguizzz) 整理与实机验证。**免费分享，禁止将本项目的原创整理内容打包售卖、付费倒卖或冒充自己的适配成果。** 请保留署名及上游来源；第三方代码和驱动的权利仍以各自许可证为准，见 [分享声明](NOTICE.md)。

适用基线：ThinkBook 14 G5+ IRH（Lenovo 21HW）、i5-13500H、Iris Xe `8086:A7A0`、AX211 `8086:51F1`。实测 macOS Tahoe 26.7.3 / 25G342，OpenCore 1.0.8。其他配置即使外观相同，也要重新核对 GPU、无线网卡、ACPI 和 USB 映射。EFI仅在**26.7.3**版本测试，其他版本请**自行测试**！！！！

**使用前请仔细阅读快速开始！！！！EFI不是到手就用，还需要打补丁等操作！！！！！**：[跳转到快速开始](#快速开始)

<img width="485" alt="IMG_20261114_220146" src="https://github.com/user-attachments/assets/434aba1d-30bd-49a6-84d3-7aab292a9786" />
<img width="485" alt="IMG_20261114_220016" src="https://github.com/user-attachments/assets/05de19c4-72b4-4de0-9f01-8b7c75e35704" />


## 硬件和功能状态

**✅ 已实测可用　◐ 可用但有问题或限制　☐ 未测试**。状态只代表本机反馈，不代表该功能所有模式均已验证。

| 硬件 / 功能 | 本机信息 | 状态 | 说明 |
| --- | --- | :---: | --- |
| CPU | Intel Core i5-13500H | ✅ | CPU 名称显示正确；不据此宣称核心拓扑与调度全面验证 |
| 内存 | 16 GB LPDDR5，Windows 报告 6400 MT/s | ✅ | 正常启动使用 |
| 集成显卡 | Intel Iris Xe，`8086:A7A0` | ✅ | WhateverXe 编译版本 + Graphics 0.4.4，桌面动画和加速正常 |
| 内屏 | 2880 × 1800 | ✅ | 分辨率、亮度调节正常 |
| 合盖息屏 | 内置屏幕 | ✅ | 合盖能息屏；不等同于完整系统睡眠测试 |
| 有线网络 | Intel I219-V，`8086:0DC6` | ✅ | IntelMausiEthernet，正常联网 |
| 无线网络 | Intel Wi-Fi 6E AX211，`8086:51F1` | ◐ | Tahoe AirportItlwm 可以联网，仍有偶发连接问题；iPhone 热点未解决，6 GHz 未验证 |
| 蓝牙 | AX211 USB 蓝牙，`8087:0033` | ✅ | 配对、连接实测成功，需保留名称注入与 NVRAM 设置 |
| 声音 | Realtek ALC257 | ✅ | AppleALC `alcid=99` + Tahoe AppleHDA 根补丁，声音恢复 |
| 摄像头 | 内置摄像头 | ✅ | 实测可用 |
| USB | 本机 USBToolBox / UTBMap 映射 | ✅ | 常用 USB 功能可用；不是所有拓展坞/端口模式的完整测试 |
| 电池 | 内置电池 | ✅ | 电量显示可用 |
| NVMe 存储 | 实机 NVMe 系统盘 | ✅ | 系统可启动使用；不同 SSD 不保证兼容 |
| Apple ID / 定位 | 系统服务 | ✅ | 生成有效的本机身份后可登录；定位需要打开隐私权限 |
| 键盘 / 触摸板扩展功能 | EFI 含 PS2 / I2C 驱动 | ☐ | 未独立记录全部快捷键和手势测试 |
| 完整睡眠 / 唤醒 | 系统电源管理 | ☐ | 本次未测试 |
| HDMI / USB-C 外接显示 | 外接显示链路 | ☐ | 未完成专项测试 |
| AirDrop / Handoff / 连续互通 | Apple 生态功能 | ☐ | 不因 Wi-Fi、蓝牙可用而宣称完整支持 |
| 经 OC 启动 Windows | 同机双系统 | ✅ | 关闭 DMAR 替换后核显正常启动；保留原生 Windows Boot Manager 回退 |
| UEFI Secure Boot | 自定义签名方案 | ◐ | 实机另行签名后 Windows 报告开启；工具放宽了 OC 策略，不是严格完整验证链；仓库 EFI 未签名 |

## 仓库结构

```text
EFI/                         完整 EFI 文件树，身份已脱敏，未签名
Source/WhateverXe/           实测成功提交的完整源码、构建工具和原测试
Source/Diffs/                相对上游 0.8.2 的真实差异和提交列表
Source/ACPI/                 本机 PNLF、EC/USBX、CPU 命名空间 ASL
Source/Bluetooth/            AX211 产品名称注入 kext
Patches/RootPatch/           无线/音频根补丁脚本及 OCLP Python 源码
Docs/                       编译、安装、补丁、来源与分发说明
```

EFI 中只保留一份 `OC/config.plist`，它是一份基于已验证配置的公开模板：**序列号、MLB、UUID、ROM 已清空或置零，使用前必须填入自己的信息。** 根补丁安装器、Apple 系统根补丁载荷、签名私钥和日志不在仓库内。

## 快速开始

1. 阅读 [EFI 安装与配置](Docs/EFI-SETUP.md)，核对硬件，下载镜像，备份当前引导并准备可启动 U 盘。
2. 为 EFI 生成自己的 MacBookPro16,2 身份信息，检查 BIOS / DVMT 和驱动依赖。
3. 安装系统，并进入系统完成基础设置，由于一开始没有GPU驱动，系统会很卡，耐心一点。
4. 先用 U 盘验证；需要 GPU 系统组件时，使用指定的 WhateverXe Graphics 与 AMFIPass Mod 组合，具体操作看下一条。
5. 需要恢复 Tahoe 音频/无线系统组件时，按 [根补丁指南](Docs/ROOT-PATCHING.md) 先 inspect，再在满足条件时 apply。不要把当前已打补丁系统重复强行叠补丁，实测OCLP无法使用，可能会导致和GPU驱动冲突，发生panic。
6.（非必须） 如果你需要自己构建 WhateverXe，按 [编译指南](Docs/BUILD.md) 操作，EFI内部已有编译好的，可以直接拿去用。

##  WhateverXe 的一些相关说明

成功构建的实际来源为 [jkbuha/WhateverXe-contrib](https://github.com/jkbuha/WhateverXe-contrib) 的 `xps9720-igpu` 分支，基于 [b00t0x/WhateverXe](https://github.com/b00t0x/WhateverXe)。以下“开发分支”指这个社区分支；感谢两者的开发工作。构建所用 Lilu 开发资源另存于 `Source/BuildDependencies`。

EFI最初使用原作者发行包时没有启用加速，显示 19 MB 显存。后来替换为源码提交 `91fdb96fc08b931c8e90e1bccdda78acf392f1e1` 的编译产物后，加速正常。

源码快照来自上述社区分支，导出时没有额外未提交的功能修改；相对官方 `0.8.2` 标签，它有真实的开发分支差异，包括 eDP 固件接管、显示中断、电源和 framebuffer 边界处理。详见 [源码差异与归属](Docs/WHATEVERXE-CHANGES.md)。没有隔离到单条“必需修复”，不保证这些改动全部与本机问题有关，也不建议盲加开发参数。

## 来源、署名与禁止售卖

维护与硬件验证：[@mengguizzz](https://github.com/mengguizzz)。本项目免费公开，请不要购买，也不要把本项目的原创文档、配置整理和适配资料直接包装售卖。第三方作者拥有各自成果，不能将上游工作归为本仓库原创。

- [来源与版本](SOURCES.md)
- [组件与第三方许可](Docs/THIRD-PARTY.md)
- [分享声明](NOTICE.md)

提交问题时写清系统构建、GPU/无线 PCI ID、启动方式和可复现步骤。分享日志前移除序列号、UUID、MAC、SSID 与账户信息，不要提交完整未脱敏 IORegistry 或崩溃转储。
