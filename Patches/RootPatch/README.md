# AX211 / Tahoe 音频根补丁工具

本工具复用 b00t0x OCLP 的验证、KDK、根卷及快照流程，只选择 Modern Wireless / Modern Audio，不选择 GPU 补丁。其源代码和授权在 `source`。`local_patch.py` 保留物理 `8086:A7A0` GPU、`8086:51F1` AX211 和精确 AMFIPass Mod 哈希的检查，不作为通用硬件补丁工具。

实测搭配 Graphics 0.4.4、AMFIPass 1.4.1 Mod；音频补丁后声音恢复，无线还依赖匹配的 Tahoe AirportItlwm。原始说明保留在 ORIGINAL-INSTRUCTIONS.txt，其中“尚未实机验证”的部分是当时的历史状态，不是本次重新执行的结果。

## 准备与检查

需要 macOS、python.org 的 Python 3.11/3.12/3.13，以及用户自行取得的作者 `3.0.0-rc.3+m.3` OpenCore-Patcher.pkg。脚本固定检查包的 SHA256：

```text
754755b50f30fea3c41c366e5ae878016604c3c799dd1a82baa0a0cf3e18089f
```

在本文件夹运行：

```sh
bash prepare.command /实际路径/OpenCore-Patcher.pkg
bash run.command inspect both
```

公开包仅把原 `prepare.command` 的 source.zip 解包步骤改为复制随附的 `source` 目录，其他精确版本与载荷校验不变。准备过程创建独立 venv，载荷从作者安装包解包，不通过 GitHub 重新分发。

## 应用

只在检查通过、保留恢复环境且确认没有既有根补丁时应用。参数3必须是实际启动 EFI 中的 AMFIPass 二进制，不是随便找到的同名文件：

```sh
bash run.command apply both /实际挂载路径/EFI/OC/Kexts/AMFIPass.kext/Contents/MacOS/AMFIPass
```

可将 both 改为 audio 或 wifi。此入口不会给已应用补丁的机器强行重叠补丁；已有本工具根补丁时再次 apply 会拒绝。不要为强行运行而删除检测元数据。

脚本在 Mac 本地 `/Users/Shared/WEX-RootPatch.*` 保存 Extensions 和内核集合，避免 exFAT U盘 `ditto Invalid argument`。U盘 logs 中的 backup-location.txt 记录实际位置。备份失败会阻止补丁启动。末尾须出现 SUCCESS，不自动重启。

## 回退与日志

```sh
bash run.command revert both
```

回退使用 OCLP 根卷回退流程，不保证 GPU/AuxKC 全部自动恢复；可能需要重新安装 Graphics。不要跨快照直接复制旧内核集合作为通用恢复办法。

`collect.command` 和运行日志可能包含硬件、接口等信息；本公开包不附带实际日志。生成后不要直接上传。

## 已检查与未检查

此公开副本会做 shell 语法、Python 源码语法和现有 CPU 检测测试；这些不执行 macOS 根卷写入。历史实机结果不代表本次重新打过补丁，也不代表任意 Tahoe 构建兼容。任何发布后的代码修改都需要重新验证。
