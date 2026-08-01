# Neovim 学习与重建路线

## 目标

最终得到一套自己能够解释、验证和维护的开发环境：

- 使用 `lazy.nvim` 安装、更新和锁定插件版本
- 不直接继承整套 LazyVim 配置
- 把 LazyVim 当作 IDE 能力清单和实现参考
- 只保留个人开发和工作流真正需要的功能
- 清楚区分 Neovim 原生能力、Lua 插件和外部程序

## 状态规则

阶段状态只使用以下四种值：

- `TODO`：尚未开始
- `DOING`：正在学习或实装，同一时间只允许一个阶段处于此状态
- `DONE`：完成了阶段的学习、实装和验证标准
- `BLOCKED`：存在明确阻塞，并已记录原因

更新阶段状态时，同时更新下方的“最近更新”，并在
`LEARNING_LOG.md` 添加一条记录。

## 总体进度

最近更新：2026-07-31

| 阶段 | 主题 | 状态 | 完成日期 |
|---|---|---|---|
| 0 | 建立安全的重建工作区 | DONE | 2026-07-28 |
| 1 | 启动流程与配置加载 | DONE | 2026-07-28 |
| 2 | Buffer、Window 与 Tabpage | DONE | 2026-07-28 |
| 3 | Mode、Option、Keymap、Command 与 Autocmd | DONE | 2026-07-29 |
| 4 | Filetype、Syntax 与 Treesitter 基础 | DONE | 2026-07-29 |
| 5 | 使用 lazy.nvim 管理插件和版本 | DONE | 2026-07-29 |
| 6 | 为 Go 加入 Treesitter | DONE | 2026-07-29 |
| 7 | 原生 LSP 与外部 Language Server | DONE | 2026-07-30 |
| 8 | 补全、格式化与静态检查 | DONE | 2026-07-31 |
| 9 | 文件导航与搜索 | DOING | - |
| 10 | Git 基础能力 | TODO | - |
| 11 | 按实际需求扩展开发语言 | TODO | - |
| 12 | 恢复个人项目、Session 与 Workspace 工作流 | TODO | - |
| 13 | 插件审计、精简和最终验收 | TODO | - |

## 阶段说明

### 0. 建立安全的重建工作区

学习内容：

- 使用独立 Git 分支隔离重建过程
- 保存旧配置，但不把它当作新配置模板直接复制
- 建立可以启动的最小 `init.lua`

完成标准：

- [x] 从 `main` 创建 `dev/neovim`
- [x] 旧配置移动到 `tools/_backup/neovim-20260728-0800`
- [x] 新配置只保留最小入口
- [x] 最小配置通过 headless 启动验证

### 1. 启动流程与配置加载

学习内容：

- Neovim 如何寻找 `init.lua`
- `stdpath("config")`、runtimepath 和 `:runtime`
- Lua 的 `require`、`package.path` 与 `lua/` 目录
- 启动参数、配置加载顺序和排错入口

完成标准：

- [x] 能说明当前 `init.lua` 为什么会被加载
- [x] 能从 `lua/` 目录加载一个自己的模块
- [x] 能用命令确认配置路径和 runtimepath
- [x] 能在不加载个人配置的情况下启动 Neovim

### 2. Buffer、Window 与 Tabpage

学习内容：

- 文件与 Buffer 并不是同一个概念
- Window 是 Buffer 的视图
- Tabpage 是 Window 布局集合，不是传统编辑器的文件标签
- 当前 Buffer、alternate Buffer、hidden Buffer 和 listed Buffer

完成标准：

- [x] 能用原生命令创建、切换和删除 Buffer
- [x] 能让同一 Buffer 同时显示在两个 Window
- [x] 能解释关闭 Window 与删除 Buffer 的差异
- [x] 能解释 Tabpage 的原生职责，为以后判断是否需要 bufferline 或
  自定义 tab workspace 建立基础

### 3. Mode、Option、Keymap、Command 与 Autocmd

学习内容：

- 常用 Mode 及其输入语义
- global、buffer-local、window-local option
- keymap 的模式、作用域、递归和表达式
- 用户命令与 Ex command
- event、pattern、group 和 callback

完成标准：

- [x] 建立最小 `options.lua`
- [x] 建立最小 `keymaps.lua`
- [x] 审计 Autocmd，并确认当前不创建空的 `autocmds.lua`
- [x] 每条设置都能说明作用域和存在理由

### 4. Filetype、Syntax 与 Treesitter 基础

学习内容：

- Filetype 检测和 filetype plugin
- Vim syntax 与 Treesitter parser 的区别
- Treesitter 能提供高亮、结构和 textobject，但不提供 LSP

完成标准：

- [x] 能确认一个 Buffer 的 filetype
- [x] 能区分传统 Syntax 与 Treesitter
- [x] 确认 Neovim 不内置 Go parser
- [x] 决定先只为 Go 管理 parser，不提前加入 textobjects 和 autotag

### 5. 使用 lazy.nvim 管理插件和版本

学习内容：

- bootstrap、plugin spec 和 lazy-loading
- `opts`、`config`、`dependencies`、`event`、`cmd`、`keys`
- `lazy-lock.json` 的作用
- 更新、锁定、回退和健康检查
- `lazy.nvim` 与 LazyVim 的区别

完成标准：

- [x] 完成最小 bootstrap
- [x] 插件声明按能力组织且可以审计
- [x] 提交 `lazy-lock.json`
- [x] 使用全新 data 目录按 lockfile 恢复插件版本

### 6. 为 Go 加入 Treesitter

学习内容：

- 当前 `nvim-treesitter` 与旧版配置的差异
- parser、query 和 highlighter 的安装与启用
- Go parser 的外部构建依赖
- parser 和 query 的更新策略

完成标准：

- [x] 只安装 Go parser 和 query
- [x] 为 Go Filetype 启用 Treesitter highlighter
- [x] 传统 Go Syntax 不再作为主要高亮来源
- [x] `:checkhealth nvim-treesitter` 通过必要检查

### 7. 原生 LSP 与外部 Language Server

学习内容：

- Neovim 原生 LSP client 的职责
- Language Server 是独立进程
- `nvim-lspconfig`、Mason 和 Language Server 的边界
- root、capabilities、diagnostics 和 attach 生命周期

完成标准：

- [x] 先用 Go 和 `gopls` 打通一条完整 LSP 链路
- [x] 能检查客户端是否 attach
- [x] 能定位跳转、重命名、诊断分别来自哪里
- [x] 能判断问题在 Neovim、配置还是外部 Server

### 8. 补全、格式化与静态检查

学习内容：

- LSP completion 与补全 UI 的区别
- snippet source 与补全引擎的关系
- formatter、linter 与 LSP 的独立职责
- 手动格式化与保存时格式化的取舍

完成标准：

- [x] 用 `blink.cmp` 打通 Go 补全
- [x] 使用原生 LSP formatting 手动格式化
- [x] 使用 `golangci-lint` 完成 Go 静态检查
- [x] 能解释补全、格式化和 lint 的完整调用链

### 9. 文件导航与搜索

学习内容：

- 原生路径、cwd、root 和 `:find`
- 文件查找、文本搜索、Buffer 切换和目录浏览是不同能力
- picker/explorer 插件对 `fd`、`rg` 等外部程序的依赖

完成标准：

- [x] 使用 Snacks Picker 与 Neo-tree 分别承担查找和目录浏览
- [x] 完成找文件、搜文本、切 Buffer 三条高频流程
- [x] 当前以 cwd 作为 Picker 和 Explorer 的起点
- [x] 基础键位与高频别名调用同一能力，不保留功能重复的实现

### 10. Git 基础能力

学习内容：

- Neovim 内置命令与外部 `git` 进程
- sign、hunk action、diff view 和 Git UI 的区别

完成标准：

- [x] 使用 `gitsigns.nvim` 提供行级状态与 hunk 操作
- [x] Diffview 暂缓，等仓库级集中审查、历史或冲突需求出现再引入
- [x] lazygit 是 Homebrew 管理的外部程序，Snacks 只提供终端集成

### 11. 按实际需求扩展开发语言

每种语言分别记录：

- Treesitter parser
- Language Server
- formatter
- linter
- debugger 和 test runner 是否必要
- 所需外部可执行程序及安装来源

完成标准：

- [x] 当前只保留已经验证的 Go 开发链路
- [x] Go 的 parser、LSP、补全、格式化和 lint 均能独立验证
- [x] 不加入暂无实际需求的语言，也不复制 LazyVim language extra

### 12. 恢复个人工作流

状态：DONE

候选能力：

- project picker
- session persistence
- tab-scoped workspace
- explorer 响应式布局
- tmux navigation
- Git review workflow
- 自动切换英文输入法

当前进度：

- [x] 最小 project picker：三层内发现 Git 项目，没有时回退到一级目录
- [x] 使用 tab-local cwd，并打开对应的 Neo-tree
- [x] 理解原生 Session 与 `sessionoptions`
- [x] 使用 `<leader>qs` 选择并恢复完整 Neovim Session
- [x] 实际验证 Session 保存与恢复
- [x] tab-scoped workspace 暂缓，当前只保留 tab-local cwd
- [x] 配置 Neovim Window 与 tmux Pane 的连续导航
- [x] 实机验证连续导航；Explorer 响应式布局暂缓
- [x] 实机验证离开 Insert Mode 后自动切换到 ABC

完成标准：

- [ ] 按使用频率逐个恢复
- [ ] 每个能力都有明确场景和验收动作
- [ ] 通用插件配置与个人工作流逻辑分离

### 13. 插件审计、精简和最终验收

状态：DONE

每个插件回答：

1. 它解决什么具体问题？
2. 最近是否实际使用？
3. Neovim 原生能力能否满足？
4. 是否和其他插件重复？
5. 删除后的实际损失是什么？

完成标准：

- [x] 每个插件都有职责和依赖记录
- [x] 没有重复的主要能力实现
- [x] 从空数据目录可以完成首次安装
- [x] 完成启动、健康检查和真实项目验证
- [x] 文档与实际配置一致

## 推荐实装结构

目录只在对应阶段确实需要时创建：

```text
config/
  init.lua
  lua/
    core/
      options.lua
      keymaps.lua
      autocmds.lua
      lazy.lua
    plugins/
      editor.lua
      navigation.lua
      coding.lua
      lsp.lua
      git.lua
    features/
      languages/
```

暂时不创建通用 `util` 目录。只有出现真实复用或独立领域模块时再抽取。
