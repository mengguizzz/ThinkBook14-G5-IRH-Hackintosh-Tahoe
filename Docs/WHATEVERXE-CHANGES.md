# WhateverXe 差异与贡献归属

## 两个比较基准

实际成功构建来自 [jkbuha/WhateverXe-contrib](https://github.com/jkbuha/WhateverXe-contrib) 的 `xps9720-igpu` 分支，基于 b00t0x/WhateverXe。与 U 盘源码核对时仅两份测试 fixture 存在 CRLF/LF 字节差异，规范换行后文本一致，没有额外的本地功能修复。

- 官方 `0.8.2` 标签：`643bb1dd50288368bcf5a50ae62462c95dfc5259`。
- 本机成功构建所用提交：`91fdb96fc08b931c8e90e1bccdda78acf392f1e1`，提交标题为合并 origin/main 到 xps9720-igpu。

`Source/WhateverXe` 是第二个提交的完整源码快照，导出时受版本控制文件无额外本地修改。**相对发行标签存在差异；相对选定开发提交没有我们额外未提交的 GPU 源码修复。**

实际 diff 在 [WhateverXe-0.8.2-to-91fdb96.patch](../Source/Diffs/WhateverXe-0.8.2-to-91fdb96.patch)，文件统计和提交标题同目录提供。差异来自上游已有开发历史，不能把它们全部归为本项目原创。

## 开发分支包含的变化

| 方向 | 差异中的内容 | 本机验证边界 |
| --- | --- | --- |
| 固件 eDP 接管 | 允许相应固件交接状态、单输出时钟路径、保留合格的固件 CMTG 状态 | 此源码构建后本机加速可用；未逐条做消融测试 |
| framebuffer 边界 | 接受不以页边界结束的合格 aperture、相关拓扑边界处理 | 不能单凭代码存在就认定是 19 MB 的唯一原因 |
| 显示中断/电源 | 单输出显示唤醒时 IRQ 保持、DE master 停放/恢复和状态一致性处理 | 完整系统睡眠未测试 |
| 可选 eDP 路径 | `-wex-edp-keep`、`-wex-edp-blank`、`-wex-no-edp-hpd` 支持及测试 | 公开 EFI 没有默认加上这些参数；不要盲加 |
| 可选视频诊断 | `-wex-no-gva`、`-wex-no-gva-scaler` 等诊断路径 | 不作为正常配置建议 |

diff 还含测试及 README 中日文同步更新。提供源码差异不是承诺所有分支变化均适用于此机器。

## 本项目实际做的机器适配

选择并保存成功构建；维持 Graphics 0.4.4 / AMFIPass Mod 的正确组合；为无线/音频做严格限定的 OCLP 入口；补齐 PNLF；修正蓝牙产品名与 NVRAM 长度；修正 CPU 显示名称；通过对照关闭会影响 Windows 核显的 DMAR 替换。

可确认的观察是：早期发行包组合显示 19 MB，没有加速；替换上述构建后动画流畅。没有隔离源码、构建工具链和完整系统状态之间的每一个变量，因此不宣称“只改某一行即可适配所有 13500H”。
