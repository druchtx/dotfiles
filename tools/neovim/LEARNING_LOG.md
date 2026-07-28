# Neovim 学习记录

本文件记录实际学过、做过和验证过的内容。路线状态以
`LEARNING_PATH.md` 为准。

## 2026-07-29 — 阶段 4：Filetype、Syntax 与 Treesitter

状态变化：TODO -> DONE

### 理解

- 正在区分 Filetype、ftplugin、传统 Syntax、Treesitter 和 LSP。

### 实装

- 增加阶段讲义 `notes/04-filetype-syntax-treesitter.md`。
- 暂不安装 Treesitter 插件或 parser。

### 验证

- Neovim 0.12.4 原生识别 `options.lua` 的 Filetype 为 `lua`。
- Filetype detection、plugin 和 indent 均已启用。
- 当前 Lua Buffer 使用 Treesitter parser 和 highlighter。
- 当前缩进表达式为 Neovim runtime 提供的 `GetLuaIndent()`。
- Go Buffer 被识别为 `go`，并加载原生 ftplugin、indent 和传统 Syntax。
- Neovim 内置 parser 不包含 Go，当前 Go Buffer 未启动 Treesitter
  highlighter。
- 本机已有 Go 1.26.0 和 `gofmt`，尚无 `gopls`、`goimports`、
  `golangci-lint` 或 `staticcheck`。

### 未解决问题

- 需要在插件管理阶段使用 `nvim-treesitter` 管理 Go parser。

### 下一步

- 阶段 5：使用 `lazy.nvim` 管理插件和版本。

### 完成确认

- 已区分 Filetype、ftplugin、indent、传统 Syntax 和 Treesitter。
- 已确认 Neovim 不内置 Go parser。
- 已决定只管理当前实际使用的 Go parser。
- parser 实装移动到插件管理之后的独立阶段。

## 2026-07-29 — 阶段 5：lazy.nvim

状态变化：TODO -> DOING

### 理解

- 正在学习 bootstrap、plugin spec、安装目录和 lockfile。

### 实装

- 增加 `core/lazy.lua` 最小 bootstrap。
- 自动版本检查关闭，保留主动更新策略。
- 增加首个 plugin spec：`plugins/treesitter.lua`。
- 增加 `treesitter-parser-registry` 依赖。
- 将 `tree-sitter-cli` 加入 Brewfile 并安装 0.26.11。

### 验证

- 使用隔离的空 XDG data 目录成功首次下载 `lazy.nvim`。
- `lazy.nvim` 已进入 runtimepath 并成功加载。
- 真实 data 目录中的现有 `lazy.nvim` 也能启动当前配置。
- 已运行 `:checkhealth lazy`。
- 隔离 data 目录成功安装 Treesitter 及 parser registry。
- `build = ":TSUpdate"` 正常执行，并确认当前没有 parser。
- `lazy=false` 的插件和依赖在启动期均处于 loaded 状态。
- lockfile 正确记录 `lazy.nvim`、`nvim-treesitter` 和
  `treesitter-parser-registry` 三个 commit。

### 未解决问题

- lockfile 和当前重建基线尚未提交。
- 尚未执行一次 lockfile restore 演练。

### 下一步

- 提交当前重建基线后，进入阶段 6 安装 Go parser。

## 2026-07-28 — 阶段 3：编辑器原生行为

状态变化：TODO -> DOING

### 理解

- 将依次学习 Mode、Option、Keymap、Command 与 Autocmd。
- 用户已有约一年的 Neovim 使用经验，常用 Mode 和基础操作无需逐项教学。
- 后续改用快速审计方式，只深入配置重构中容易混淆的作用域、生命周期和
  依赖边界。

### 实装

- 增加阶段讲义 `notes/03-editor-behavior.md`。
- 新建 `lua/core/options.lua`，按 Global、Buffer-local defaults 和
  Window-local defaults 分类。
- 恢复经过确认的长行视觉换行设置和全局 diff 设置。
- 新建 `lua/core/keymaps.lua`，恢复不依赖插件的个人映射。
- 确定 `<leader> + 对象 + 动作` 的映射语法，`q` 表示安全退出。
- 不配置任何会强制丢弃修改的退出映射。

### 验证

- Mode 基础通过：能解释 Normal Mode 的 mapping 不影响 Insert Mode
  中输入同一个字符。
- 使用 Neovim option metadata 确认：
  - `diffopt` 为 global
  - `wrap`、`linebreak`、`breakindent` 为 window-local
  - `showbreak` 为 global-local
- 新建 Window 后成功继承四项视觉换行默认值。
- 已确认四个退出映射注册为 Normal Mode global mappings。
- 修改 Buffer 后，普通 `:bdelete` 会拒绝删除，安全退出约束生效。
- 待验证 Command 与 Autocmd。

### 未解决问题

- 自动切换英文输入法已经确认需要，但延后到个人工作流阶段。

### 下一步

- 完成阶段 3 的 Command 与 Autocmd 审计。

### Autocmd 审计

- 旧 Markdown spell Autocmd 仅用于覆盖 LazyVim 默认行为，不恢复。
- 插件相关 Autocmd 延后到对应插件阶段。
- 自动切换英文输入法记录在 `TODO.md`，延后到阶段 11；旧 Hammerspoon
  实现只作为参考，实装前需要比较更轻量、可靠的方案。
- 当前最小配置不注册 Autocmd，也不创建空的 `core/autocmds.lua`。

### 完成确认

状态变化：DOING -> DONE

- Mode 基础无需继续展开。
- Option 已按功能组织，并理解 Global、Buffer、Window 和 global-local
  的两个分类维度。
- Keymap 已区分原生全局映射、buffer-local 映射和插件映射。
- Command 作为操作入口，当前无需创建自定义用户命令。
- Autocmd 已完成事件、条件、callback 和 augroup 的职责审计。

## 2026-07-28 — 阶段 2：Buffer、Window 与 Tabpage

状态变化：TODO -> DOING

### 理解

- 正在学习 Buffer、Window 与 Tabpage 的职责和多对多关系。

### 实装

- 增加阶段讲义 `notes/02-buffers-windows-tabpages.md`。
- 本阶段暂不增加编辑器配置。

### 验证

- 最小配置启动时存在 1 个 Buffer、1 个 Window 和 1 个 Tabpage。
- 初始 Buffer 没有文件名，证明 Buffer 不一定对应磁盘文件。

### 未解决问题

- 需要完成三个对象的动手实验和理解检查。

### 下一步

- 开始阶段 3：Mode、Option、Keymap、Command 与 Autocmd。

### 完成确认

状态变化：DOING -> DONE

- 能解释空白启动时仍存在一个未关联磁盘文件的 `[No Name]` Buffer。
- 能解释 Window 管理 Buffer 的显示方式，而不拥有 Buffer。
- 能解释 `:close` 关闭 Window，`:bdelete` 删除 Buffer。
- 能解释 Tabpage 是 Window 布局容器，不是文件标签。
- 能解释同一个 Buffer 可被不同 Window 和不同 Tabpage 共享，未保存的
  内存修改也会在所有视图中立即可见。

## 2026-07-28 — 阶段 1：启动流程与配置加载

状态变化：TODO -> DOING

### 理解

- 已确认配置目录、XDG 数据目录和 runtimepath 的实际值。
- 正在学习 `init.lua`、runtimepath 与 Lua `require` 的关系。

### 实装

- 增加无副作用的 `learning.startup` Lua 模块。
- 在 `init.lua` 中加载模块并验证双方看到相同的配置根目录。
- 增加阶段讲义 `notes/01-startup-and-loading.md`。

### 验证

- 正常启动成功加载 `learning.startup`。
- 显式 `-u /absolute/path/to/init.lua` 成功加载模块。
- `-u NONE` 启动确认个人模块未加载。
- `stdpath("config")` 返回标准软链接目录，而 `$MYVIMRC` 返回解析后的
  仓库文件路径；二者指向同一文件但字符串不同。

### 未解决问题

- 需要完成讲义末尾的理解检查后才能把阶段状态改为 `DONE`。

### 下一步

- 开始阶段 2：Buffer、Window 与 Tabpage。

### 完成确认

状态变化：DOING -> DONE

- 能解释软链接为何让仓库中的 `init.lua` 成为默认配置入口。
- 能区分 `config` 中的个人配置与 `data` 中的插件和持久数据。
- 能把 `require("core.options")` 映射为
  `lua/core/options.lua`。
- 能解释 runtimepath 提供搜索根目录，`require` 指定 Lua 模块。
- 能使用 `nvim -u NONE` 跳过个人配置，并据此隔离配置问题。

## 记录模板

复制以下模板到文件顶部，并填写实际结果：

```markdown
## YYYY-MM-DD — 阶段 N：主题

状态变化：TODO -> DOING

### 理解

-

### 实装

-

### 验证

- 命令：
- 结果：

### 未解决问题

-

### 下一步

-
```

## 2026-07-28 — 阶段 0：建立安全的重建工作区

状态变化：TODO -> DONE

### 理解

- 重建过程需要与 `main` 隔离。
- 旧配置只作为行为和需求参考，不直接作为新架构的起点。
- manifest 管理的是 `tools/neovim/config`，因此备份后仍需保留该目录。

### 实装

- 从 `main` 创建并切换到 `dev/neovim`。
- 将旧配置完整移动到
  `tools/_backup/neovim-20260728-0800/config`。
- 创建只有说明注释的最小 `config/init.lua`。

### 验证

- 使用隔离的 XDG config、data、cache 和 state 目录进行 headless 启动。
- 最小配置启动成功。
- `git diff --check` 通过。

### 未解决问题

- Neovim 重建基线尚未提交。

### 下一步

- 开始阶段 1：启动流程与配置加载。
