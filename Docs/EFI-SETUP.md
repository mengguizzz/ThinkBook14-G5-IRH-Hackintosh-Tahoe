# EFI 安装与配置

## 使用自己的机器身份

`EFI/OC/config.plist` 已去除序列号等信息。MacBookPro16,2 的 SystemSerialNumber / MLB 为空，SystemUUID 为全零，ROM 为六个零字节。**必须使用 GenSMBIOS / OpenCore macserial 等工具生成匹配的身份**，ROM 使用自己设备的真实网卡地址。不要使用其他人的身份，不保证随机生成的信息已通过 Apple 服务验证。

公开模板**并非拿来即可登录 Apple ID 的配置**。保存到 Git 前再检查 PlatformInfo 和任何诊断输出。

## 必要设置

- 保留 `alcid=99 -allow3d -disablegfxfirmware -igfxdvmt revcpu=1 revpatch=cpuname` 等模板中已验证参数；
- 本机保留 DVMT 相关 framebuffer 配置。其他设备如能设 96 MB，应按 WhateverXe 说明核对是否仍需要 `-igfxdvmt` 和 stolenmem 属性。
- 保留 WhateverXe 在 Lilu 后的加载顺序，使用指定 Mod AMFIPass，不同时启用 WhateverGreen。
- 原始 DMAR 应保留：`ACPI/Add/DMAR.aml` 和 `ACPI/Delete/DMAR` 的 Enabled 都为 false。其他 ACPI 修改仍可能传给 Windows，不宣称完全原生隔离。
- `AX211BluetoothName.kext` 为精确的本机 USB 匹配；其他 USB 路径需要重新核对。不要改成 Broadcom 内部控制器名称。
- Bluetooth NVRAM 数据长度：bluetoothInternalControllerInfo 为 14 字节，bluetoothExternalDongleFailed 为 1 字节。不要把长度误改回 13。
- RestrictEvents 的 CPU 名称及 ProcessorType 用于显示名称，不用其结果判断核心数、电源管理或调度。

## 安全启动

参考[OpenCore-Secure-Boot-Tool](https://github.com/hd9p7jrchg-crypto/OpenCore-Secure-Boot-Tool)
