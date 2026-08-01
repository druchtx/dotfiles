# Neovim 学习记录

本文件记录实际学过、做过和验证过的内容。路线状态以
`LEARNING_PATH.md` 为准。

## 2026-07-31 — 阶段 13：插件审计、精简和最终验收

状态变化：TODO -> DOING

- 已记录所有直接插件和间接依赖的职责、依赖与删除损失。
- 当前没有重复的主要能力实现。
- 已在隔离的空 XDG 目录中完成所有锁定插件的首次安装。
- 已从零安装 Go parser、gopls 和 golangci-lint，并验证 gopls attach。
- `mason-lspconfig` 按设计在 headless 模式跳过自动安装；验收中显式安装
  gopls 后完成验证，正常交互式启动仍使用 `ensure_installed`。
- 下一步执行健康检查和最终配置核对。
- 健康检查确认 Treesitter、Mason 和 gopls 配置正常；关闭当前未使用的
  lazy.nvim LuaRocks 支持。其他语言缺失警告与当前 Go 配置无关。

### 完成确认

状态变化：DOING -> DONE

- lazy.nvim 健康检查全绿；Mason 的可选语言警告不影响当前 Go 环境。
- 最终 Go Buffer 验证通过：Filetype、parser、gopls、Blink、nvim-lint 和
  golangci-lint 均正常。
- 配置、锁文件、学习路径和审计文档已经对应。
- 从裸 Neovim 到当前最小开发配置的学习与实装路线全部完成。

## 2026-07-31 — 阶段 12：恢复个人工作流

状态变化：TODO -> DOING

- 已区分 Project、Session 和自定义 Workspace。
- 第一项只实现最小项目切换，不恢复旧配置的缓存和 Session 行为。
- `<leader>fp` 扫描可配置项目根目录中的最浅层 Git 仓库；三层内没有
  Git 仓库时回退到一级目录。
- 选中项目后使用 `tcd` 设置当前 Tabpage 的 cwd，并打开右侧 Neo-tree。
- Buffer 仍由 Neovim 全局管理，暂不实现 Tabpage Buffer 归属层。
- 加入 Persistence，读取真实文件后启用退出自动保存；不自动恢复。
- `<leader>qs` 选择并恢复完整 Neovim Session，与 project picker 保持独立。
- 已实机验证：进入项目并打开至少一个真实文件后，退出会保存 Session，
  `<leader>qs` 可以选择并恢复。
- tab-scoped workspace 暂缓，不恢复 Buffer 归属、过滤和自定义 Session
  序列化；当前 tab-local cwd 已满足基本项目隔离。
- 使用 `vim-tmux-navigator` 连接 Neovim Window 与 tmux Pane 导航；配置文件
  按能力命名为 `navigation.lua`。
- 已在真实 tmux 中验证 Window 内导航和到达边界后的 Pane 切换。
- Neo-tree 当前固定右侧已满足使用，响应式 Explorer 布局暂不增加。
- 输入法使用已有 Hammerspoon：仅在 `InsertLeave` 后异步切换到 ABC，
  不增加专用 CLI 或 Neovim 插件。
- 已实机验证离开 Insert Mode 后能够切换到 ABC。

### 完成确认

状态变化：DOING -> DONE

- 已恢复项目发现、Session、tmux 导航和输入法切换。
- tab-scoped workspace 与响应式 Explorer 明确延后，不增加旧配置复杂度。
- 进入阶段 13：插件审计、精简和最终验收。

## 2026-07-31 — 阶段 11：按实际需求扩展开发语言

状态变化：TODO -> DONE

- 当前只需要 Go，不增加其他语言。
- 已理解新增语言需要分别处理 Filetype、parser、LSP、formatter、linter、
  外部工具和运行时。
- 第二种语言出现时，将语言差异整理到 `languages/<language>.lua`；
  通用插件仍各自只配置一次。
- 不为当前唯一的 Go 配置提前增加抽象层。
- 进入阶段 12：恢复个人工作流。

## 2026-07-31 — 阶段 10：Git 基础能力

状态变化：TODO -> DOING

### 理解

- HEAD、Index、磁盘文件和 Buffer 可以同时保存不同版本。
- Gitsigns attach 到 Buffer，将行级变化组织成 hunk。
- Neo-tree 的文件级 Git 状态与 Gitsigns 的行级状态职责不同。

### 实装

- 增加阶段讲义 `notes/10-git.md`。
- 第一轮只加入 hunk 跳转、预览和行 blame。
- 快捷键由 `on_attach` 设置为 Buffer-local。
- `<leader>gs` 在 Normal Mode 暂存当前 hunk，在 Visual Mode
  暂存选中行。
- 暂不绑定整文件暂存和 reset。
- 当前使用 Neo-tree 的修改文件列表配合 Gitsigns 完成提交前逐文件审查。
- Diffview 暂不安装；等出现多文件集中审查、历史、分支比较或冲突处理
  需求时再引入。
- 本机 lazygit 由 Homebrew 管理；Snacks 只作为 Neovim Terminal 集成层。
- 增加 `<leader>gg`，在当前 cwd 中打开 lazygit。

### 完成确认

状态变化：DOING -> DONE

- 能区分文件级 Git 状态、Buffer 行级 hunk、完整 diff view 和 Git UI。
- 已使用 Gitsigns 打通显示、导航、预览、blame 和局部暂存。
- 当前由 Neo-tree 配合 Gitsigns 完成轻量仓库审查，Diffview 延后。
- lazygit 的安装、执行与 Neovim 集成边界清晰。
- 进入阶段 11：按实际需求扩展开发语言。

## 2026-07-31 — 阶段 9：文件导航与搜索

状态变化：TODO -> DOING

### 下一步

- 区分 cwd、项目 root、文件查找、文本搜索、Buffer 切换和目录浏览。
- 使用 Snacks Picker 统一文件查找、文本搜索和 Buffer 切换。
- `<leader>ff`、`<leader>sg`、`<leader>bs` 是按能力分类的基础键位；
  `<leader><space>`、`<leader>/`、`<leader>,` 是对应的高频快捷入口。
- 保留 `<A-w>` 切换输入、结果和预览区域，使用 `<A-q>` 关闭 Picker。
- Explorer 选择 Neo-tree，不使用 Snacks Explorer。
- 当前只使用 filesystem source，通过 `<leader>e` 打开 cwd 的目录树并
  显示 Git 状态；暂不使用 Neo-tree 的 Buffer source 和 git_status source。
- Neo-tree 中 `.` 只设置树根，不改变 cwd；当前会话会保存树的状态，
  因此关闭后重新打开仍能继续之前的位置，不需要额外的 `<C-c>`。
- 复制文件名、相对路径和绝对路径属于当前 Buffer 的能力，不绑定在
  Neo-tree 中；已记录到快捷键阶段处理。

### 完成确认

状态变化：DOING -> DONE

- 能区分文件查找、文本搜索、Buffer 切换和目录浏览。
- 能区分 cwd、LSP root、搜索起点和 Explorer 自身保存的树根。
- Snacks Picker 负责查找，Neo-tree 负责目录浏览，没有启用两者重复的
  Explorer 或 Buffer source。
- 基础键位和高频入口只是同一能力的别名，不是两套实现。
- 进入阶段 10：Git 基础能力。

## 2026-07-30 — 阶段 8：补全、格式化与静态检查

状态变化：TODO -> DOING

### 理解

- `gopls` 产生候选，Neovim LSP 负责请求，补全引擎负责交互。
- `friendly-snippets` 是模板库，LuaSnip 和 `vim.snippet` 是执行引擎。
- 当前使用 Neovim 原生 `vim.snippet`，不安装 LuaSnip。

### 实装

- 增加阶段讲义 `notes/08-completion-format-lint.md`。
- 加入稳定版 `blink.cmp` 和 `friendly-snippets`。
- 启用 LSP、路径、snippet 和 Buffer 单词来源。
- 暂不启用命令行补全和自动括号。
- 增加固定的全局快捷键 `<leader>cf`，格式化当前 Buffer。
- 使用 Mason 管理 `golangci-lint`，由 `nvim-lint` 在 Go 文件保存后
  执行并发布诊断。
- 项目使用 `.golangci.yml` 管理检查规则；需要特殊版本时由项目 mise
  提供，Mason 作为 PATH 后备。

### 验证

- Blink 已成功加载，`gopls` Client 能正常 attach。
- 已确认启用 LSP、路径、snippet 和 Buffer 单词来源。
- 已确认 snippet 使用 Neovim 内置 `vim.snippet`，无需 LuaSnip。
- 已确认 `gopls` 支持 `textDocument/formatting`。
- 已验证 `<leader>cf` 能格式化 Buffer。
- Mason 已安装 `golangci-lint` 2.12.2。
- 已确认 Go Filetype 使用 `golangcilint`，并在 `BufWritePost` 触发。
- mise Go 已更新到 1.26.5，并清理损坏的 Go build cache。
- `go list std` 能识别 360 个标准库 package，`golangci-lint` 已成功
  检查当前 Go 测试项目。
- tmux 启动 Neovim 前会先加载 interactive login zsh；已实机确认
  Neovim 能继承 mise 的 Go 环境。
- 待手动验证自动菜单、LSP 候选、Buffer 补词和
  `friendly-snippets` 展开。

### 完成确认

状态变化：DOING -> DONE

- 能区分补全候选、补全 UI、snippet 模板和 snippet 引擎。
- 能区分 LSP formatting、外部 formatter、linter 和诊断显示。
- 已打通 Blink、原生 LSP formatting 和 `golangci-lint`。
- 当前选择手动格式化，不增加保存时自动格式化。
- 进入阶段 9：文件导航与搜索。

## 2026-07-30 — 阶段 7：原生 LSP 与 gopls

状态变化：TODO -> DOING

### 理解

- Treesitter 负责 Buffer 的语法结构，`gopls` 负责 Go workspace 语义。
- Neovim 原生 LSP Client 负责进程、协议、请求和结果。
- LSP root 决定 workspace 边界以及 Client 是否复用。
- Server 与 Client 会在初始化时交换 capabilities。
- mise 管理语言运行时，Mason 管理编辑器使用的外部开发工具。

### 实装

- 增加阶段讲义 `notes/07-lsp.md`。
- 加入 `mason.nvim`、`mason-lspconfig.nvim` 和 `nvim-lspconfig`。
- 当前只声明安装并自动启用 `gopls`。

### 验证

- Mason 已安装 `gopls`。
- Neovim 中 `gopls` 路径为
  `~/.local/share/nvim/mason/bin/gopls`。
- 打开测试 `main.go` 后，`gopls` Client 成功 attach。
- LSP root 为包含 `go.mod` 的 `tools/neovim`。
- Server 支持 definition 和 rename 请求。
- 当前 `nvim-lspconfig` 检测到 Neovim 0.12 原生 `:lsp` 后不注册
  `:LspInfo`；状态检查使用 `:checkhealth vim.lsp`。

### 下一步

- 阶段 8：补全、格式化与静态检查。

### 完成确认

状态变化：DOING -> DONE

- 能区分 Mason、`nvim-lspconfig`、`mason-lspconfig`、Neovim LSP
  Client 和 `gopls` 的职责。
- 能解释 Filetype、root、Client、Buffer attach 和 capabilities 的关系。
- 能使用 `:checkhealth vim.lsp`、`vim.lsp.get_clients()` 和 LSP 日志
  分层排错。
- 已验证 Mason `gopls`、项目 root、Buffer attach、definition 和 rename。
- 已理解 Hover、Rename 和诊断由 `gopls` 返回，由 Neovim 展示或应用。
- 项目本地工具优先、Mason 后备的需求已记录到 `TODO.md`。

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

- 阶段 6：安装并启用 Go Treesitter parser。

### 完成确认

状态变化：DOING -> DONE

- 已提交包含 `lazy-lock.json` 的最小重建基线。
- 已在全新 XDG data 目录执行 `:Lazy restore`。
- `lazy.nvim`、`nvim-treesitter` 和 registry 的实际 HEAD 均与 lockfile
  一致。
- bootstrap 的 stable commit 与 lockfile 在 restore 后统一。

## 2026-07-29 — 阶段 6：Go Treesitter

状态变化：TODO -> DOING

### 理解

- 下一步只处理 Go parser、query 和 highlighter。

### 实装

- 为 `nvim-treesitter` 增加 parser registry 依赖。
- 配置加载时异步补齐语言清单中缺失的 parser/query，避免阻塞启动。
- plugin build 更新清单中已经安装的 parser/query。
- Go Filetype 通过 Autocmd 启动原生 Treesitter highlighter。
- 清理真实 data 目录中旧配置遗留的 43 个非 Go parser。

### 验证

- 干净临时 data 目录只安装了 Go parser 和 query。
- Go Filetype 成功启动 Treesitter highlighter。
- Go 缩进仍使用原生 `GoIndent(v:lnum)`。
- `:checkhealth nvim-treesitter` 已运行。
- 真实 data 目录的 parser 清单为 `{ "go" }`。

### 未解决问题

- 无。

### 下一步

- 阶段 7：理解 Neovim 原生 LSP client 与外部 `gopls` 的边界。

### 复查

- 阶段暂不标记完成，继续讲清新增语言的配置方式。
- 语言清单同时驱动 parser 安装和 Filetype highlighter。
- 新增普通语言只需在清单中增加名称。
- 普通启动不更新 parser；插件 build 时才执行更新。
- parser 安装完成后重新检查已打开 Buffer，处理首次安装时的时序问题。
- 安装失败时引导使用 `:TSLog` 查看详细错误。

### 完成确认

状态变化：DOING -> DONE

- 能解释 parser、query、Filetype、Buffer 和 highlighter 的关系。
- 能通过统一语言清单声明需要管理的 parser。
- 能区分启动时补齐缺失 parser、插件 build 时更新 parser，以及打开
  Buffer 时启用 Treesitter。
- 已卸载实验用的 `gomod`、`gosum`、`gowork`、`gotmpl`、`python` 和
  `javascript`，真实环境只保留 `go`。
- Treesitter 语言状态助手已记录到 `TODO.md`。
- 进入阶段 7：原生 LSP 与外部 Language Server。

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
