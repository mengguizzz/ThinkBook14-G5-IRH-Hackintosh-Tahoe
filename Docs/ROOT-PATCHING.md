# GPU、无线与音频补丁方法

## 固定组件关系

| 部分 | 本机使用 |
| --- | --- |
| EFI GPU kext | WhateverXe 0.8.2，提交 91fdb96 的成功构建 |
| GPU 系统组件 | WhateverXe-Graphics 0.4.4 |
| 签名配套 | AMFIPass 1.4.1 Mod，不能随意换成普通上游版 |
| 无线公共系统组件 | 作者 Mod 链的 Modern Wireless Common 13.7.2-25 |
| Tahoe 音频 | AppleHDA 26.0 Beta 1，配合 AppleALC `alcid=99` |
| Wi-Fi EFI kext | kgp-macPro AirportItlwm-Tahoe 2.0.0 |

从 [WhateverXe-Graphics](https://github.com/b00t0x/WhateverXe-Graphics) 获取 Graphics 及 Mod AMFIPass，按对应版本说明安装 GPU 系统组件。无线/音频载荷由下面工具从指定作者 OCLP pkg 本地解包。仓库不包含根补丁安装包或它们的 Apple 载荷。

不要叠加不同 OCLP 分支的根补丁。之前其他分支组合曾 panic，但没有隔离到具体冲突文件；当前组合能用不意味着任意分支都可混装。

## 无线/音频工具

进入 `Patches/RootPatch`。使用 python.org 的 Python 3.11、3.12 或 3.13，不使用 Apple 系统 Python。自行取得作者 `3.0.0-rc.3+m.3` 的 OpenCore-Patcher.pkg；SHA256 固定为：

```text
754755b50f30fea3c41c366e5ae878016604c3c799dd1a82baa0a0cf3e18089f
```

准备及检查：

```sh
cd Patches/RootPatch
bash prepare.command /实际路径/OpenCore-Patcher.pkg
bash run.command inspect both
```

准备过程只解包资源、创建独立 venv，不应用根补丁。先阅读生成的 baseline.txt 和 operation.log。

## 应用条件

本工具 apply 检查 Tahoe >=26.7、物理 GPU `8086:A7A0`、实际 AX211、已加载 AMFIPass，以及启动 EFI 中 AMFIPass 可执行文件的精确哈希。保留原作者 SIP/AMFI/KDK/快照检查。不选择图形补丁。

先确认实际启动 EFI 的挂载位置，再运行：

```sh
bash run.command apply both /实际挂载路径/EFI/OC/Kexts/AMFIPass.kext/Contents/MacOS/AMFIPass
```

`both` 可替换为 `audio` 或 `wifi`。选择不同并不意味着可以先后叠加；已有根补丁元数据时 apply 会停止。当前已正常打补丁的系统不需要再运行，不能为了绕过检查删除元数据。

脚本先把 Extensions 和现有内核集合备份到 Mac 本地 `/Users/Shared/WEX-RootPatch.*`，避免 exFAT U 盘复制内核缓存元数据时 `ditto: Invalid argument`。日志的 backup-location.txt 记录备份位置。备份失败阻止补丁执行；末尾出现 SUCCESS 才表示工具报告成功，不会自动重启。

音频补丁实机后声音恢复，Wi-Fi 在换用 Tahoe 驱动后可用但仍有偶发问题。这不是全版本通用补丁。

## 回退和故障处理

```sh
bash run.command revert both
```

这调用对应根补丁的 OCLP 回退，不保证 GPU/AuxKC 全部恢复，可能需要重新安装 Graphics。不要跨快照直接复制备份 KC。保留可启动 U 盘和恢复环境。

公开包准备脚本只是把 source.zip 改为读取随附源码目录，其余校验保留。更多细节见 [工具说明](../Patches/RootPatch/README.md)。
