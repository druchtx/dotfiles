# Neovim 待办事项

只记录已经确认需要、但当前阶段不适合实装的功能。

## 按语言组织开发配置

状态：`DONE`

目标：

- 使用 `languages/<language>.lua` 集中描述每种语言的开发能力
- 每种语言记录 Filetype、Treesitter parser、LSP、formatter 和 linter
- 通用插件配置继续留在 `treesitter.lua`、`lsp.lua`、`lint.lua` 等文件

设计约束：

- 语言文件只声明语言差异，不重复插件 setup
- Mason 仍统一管理编辑器使用的外部工具
- mise 仍管理语言运行时和项目特殊版本
- 不为当前唯一的 Go 配置提前设计抽象层

触发条件：

- 实际加入第二种开发语言时再重构

验收标准：

- 增加语言时主要修改一个语言文件
- 删除语言时能明确移除 parser、Server、formatter 和 linter
- 各插件仍只执行一次 setup

## 仓库级 Diffview

状态：`DEFERRED`

当前方案：

- Neo-tree 显示仓库中的修改文件
- Gitsigns 提供当前 Buffer 的 hunk、预览和单文件 diff
- 提交前可以逐个打开修改文件完成轻量审查

引入条件：

- 需要在同一 Tabpage 中连续审查整个仓库
- 需要比较分支、Commit 或 Tag
- 需要文件历史视图
- 需要三方或四方冲突处理

设计约束：

- 不与 Neo-tree 的文件状态和 Gitsigns 的行级能力重复配置
- 只在当前方案实际产生明显操作成本时引入

实装阶段：

- 阶段 13：插件审计、精简和最终验收

## 复制当前 Buffer 文件信息

状态：`DEFERRED`

目标：

- 复制当前 Buffer 对应文件的名称
- 复制相对于 cwd 的文件路径
- 需要时复制绝对路径

设计约束：

- 属于 Buffer 能力，不依赖 Explorer 或 Picker
- 无文件名的 Buffer 需要给出清晰提示
- 使用 Neovim 原生 API，不引入插件
- 快捷键遵循 `<leader> + object + action` 规则

实装阶段：

- 阶段 10：快捷键体系与交互统一

## 项目本地开发工具优先

状态：`DEFERRED`

目标：

- Mason 提供默认的 LSP、formatter、linter 和 DAP
- 项目声明特殊工具版本时，优先使用项目本地可执行程序
- 找不到项目版本时，安全回退到 Mason

设计约束：

- 不把所有编辑器工具塞进全局 mise 配置
- 项目可使用自己的 mise、devcontainer、Nix 或工具目录
- 工具选择以项目 root 为边界，不能污染同一 Neovim 中的其他项目
- 不无条件执行未经信任的项目配置
- LSP、formatter、linter 和 DAP 使用一致的解析策略

实装阶段：

- 阶段 12：个人项目、Session 与 Workspace 工作流

验收标准：

- 普通项目默认使用 Mason 工具
- 特殊项目可以固定自己的工具版本
- 同时打开不同项目时，各自使用正确的工具
- 项目工具缺失或失效时能定位原因并安全回退

## Treesitter 语言状态助手

状态：`DEFERRED`

目标：

- 从当前 Buffer 的 Filetype 找到对应的 Treesitter parser
- 显示 parser/query 是否已经安装
- 提供加入个人语言清单所需的信息
- 需要时提供安装、更新、删除和查看日志的快捷入口

设计约束：

- `nvim-treesitter` 仍是唯一的 parser 管理器
- 不为包装 `:TSStatus` 引入功能重复的插件
- 区分 registry 中“可以安装”和本地“已经安装”
- 不自动修改配置中的语言清单
- 不自动删除磁盘中的 parser

候选实现：

- 一个小型用户命令
- 在已有 picker 能力完成后增加 picker 界面
- 复用 `:TSStatus`、`:TSInstall`、`:TSUpdate`、`:TSUninstall` 和
  `:TSLog`

实装阶段：

- 阶段 13：插件审计、精简和最终验收

验收标准：

- 能从当前 Buffer 看见 Filetype、parser 名称和安装状态
- 能明确下一步应修改语言清单还是运行管理命令
- 不影响 Neovim 启动，也不在后台自动更新或删除 parser

## 自动切换英文输入法

状态：`DEFERRED`

目标：

- 离开 Insert Mode 后切换到 ABC 英文输入法
- 重新进入 Buffer、Window 或聚焦 Neovim 时的切换按实际需求再增加
- 不阻塞模式切换和界面响应

候选事件：

- `InsertLeave`
- `BufEnter`
- `WinEnter`
- `FocusGained`

设计约束：

- 当前复用已有 Hammerspoon，不增加新的外部工具
- 第一版只监听 `InsertLeave`，通过 `vim.system()` 异步执行
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
