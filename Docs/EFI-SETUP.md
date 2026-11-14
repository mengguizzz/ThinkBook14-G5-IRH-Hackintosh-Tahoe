# EFI 安装与配置

## 使用自己的机器身份

`EFI/OC/config.plist` 已脱敏。MacBookPro16,2 的 SystemSerialNumber / MLB 为空，SystemUUID 为全零，ROM 为六个零字节。必须使用 GenSMBIOS / OpenCore macserial 等工具生成匹配的身份，ROM 使用自己设备的真实网卡地址。不要使用其他人的身份，不保证随机生成的信息已通过 Apple 服务验证。

公开模板并非拿来即可登录 Apple ID 的配置。保存到 Git 前再检查 PlatformInfo 和任何诊断输出。

## 必要设置

- OC 1.0.8；主题 GoldenGate，菜单 3 秒；启用的驱动和工具引用应与文件一致。
- 保留 `alcid=99 -allow3d -disablegfxfirmware -igfxdvmt revcpu=1 revpatch=cpuname` 等模板中已验证参数；不要因为源码支持某参数就自动添加。
- 本机保留 DVMT 相关 framebuffer 配置。其他设备如能设 96 MB，应按 WhateverXe 说明核对是否仍需要 `-igfxdvmt` 和 stolenmem 属性。
- 保留 WhateverXe 在 Lilu 后的加载顺序，使用指定 Mod AMFIPass，不同时启用 WhateverGreen。
- 原始 DMAR 应保留：`ACPI/Add/DMAR.aml` 和 `ACPI/Delete/DMAR` 的 Enabled 都为 false。其他 ACPI 修改仍可能传给 Windows，不宣称完全原生隔离。
- `AX211BluetoothName.kext` 为精确的本机 USB 匹配；其他 USB 路径需要重新核对。不要改成 Broadcom 内部控制器名称。
- Bluetooth NVRAM 数据长度：bluetoothInternalControllerInfo 为 14 字节，bluetoothExternalDongleFailed 为 1 字节。不要把长度误改回 13。
- RestrictEvents 的 CPU 名称及 ProcessorType 用于显示名称，不用其结果判断核心数、电源管理或调度。

## U 盘验证和内置 EFI

先将 `EFI` 放到 FAT32 EFI 分区验证。原始系统、根补丁和启动恢复手段需自行保留。不要覆盖 `EFI/Microsoft`。

复制到 Windows EFI 系统分区时，可只合并 `EFI/OC`，然后在固件中添加 `\EFI\OC\OpenCore.efi` 启动项。如果没有注册这个启动项，复制 OC 文件夹并不会自动改变默认启动方式。`EFI/BOOT/BOOTX64.EFI` 是另一种回退入口，替换前备份现有文件。

保留 Windows Boot Manager，以便 OC 或 macOS 无法启动时回到 Windows。不要把微软的 bootmgfw.efi 替换成 OC。

## 安全启动

仓库中的 EFI 是未签名版本：SecureBootModel=Disabled，DisableSecurityPolicy=false，Vault=Optional。不要仅打开固件 Secure Boot 就期待它直接加载。

本机后来使用第三方工具签名并注册密钥，Windows Confirm-SecureBootUEFI 返回 True，同时配置被改为 DisableSecurityPolicy=true。这放宽了 OC 后续加载策略，不能称为严格完整的安全启动链。该改动没有合入此模板，不承诺任何 Windows 软件接受此方案。不附带私钥或固件密钥注册包，不指导清空原厂密钥。

完整睡眠、外接显示及连续互通仍需各自验证。
