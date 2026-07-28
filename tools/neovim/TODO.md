# Neovim 待办事项

只记录已经确认需要、但当前阶段不适合实装的功能。

## 自动切换英文输入法

状态：`DEFERRED`

目标：

- 离开 Insert Mode 后切换到 ABC 英文输入法
- 重新进入 Buffer、Window 或聚焦 Neovim 时，在非 Insert Mode 下切换
- 不阻塞模式切换和界面响应

候选事件：

- `InsertLeave`
- `BufEnter`
- `WinEnter`
- `FocusGained`

设计约束：

- 不预设继续使用旧的 Hammerspoon 实现
- 先确认 Neovim 本身是否具备可靠的输入源控制能力
- 比较专用输入源工具、Hammerspoon 和 macOS 自动化方案
- 优先选择依赖少、响应快、可检测且失败安全的实现
- 外部工具不可用时，Neovim 必须正常启动

旧实现参考：

- Hammerspoon 正在运行
- `hs` CLI 和 `hs.ipc` 可用
- ABC 输入源 ID 为 `com.apple.keylayout.ABC`

调研维度：

- 是否必须依赖外部程序
- 每次模式切换是否创建新进程
- 调用是否异步
- 如何检测当前输入源，避免无意义重复切换
- 工具不存在、超时或调用失败时如何降级
- macOS 更新后方案是否稳定

实装阶段：

- 阶段 12：个人工作流

验收标准：

- 中文输入状态离开 Insert Mode 后自动恢复英文
- Insert Mode 中不会被意外切换
- 最终选定方案的外部依赖不可用时，Neovim 正常启动且不报错
- 高频事件不会造成明显延迟或重复进程堆积
