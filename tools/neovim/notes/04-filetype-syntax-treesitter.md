# 04：Filetype、Syntax 与 Treesitter

## 本阶段目标

区分四个容易混在一起的概念：

- Filetype：当前 Buffer 中是什么类型的文本
- ftplugin：针对某个 Filetype 的编辑器设置
- Syntax：传统的规则匹配高亮系统
- Treesitter：把文本解析成语法树的结构化系统

## 当前裸配置的实际状态

使用 Neovim 0.12.4 打开 `options.lua`：

```text
filetype=lua
filetype detection=ON
filetype plugin=ON
filetype indent=ON
Treesitter parser=true
Treesitter highlighter=true
传统 Lua syntax=none
indentexpr=GetLuaIndent()
```

这些结果来自当前 Neovim 运行时，不依赖第三方插件。

## 1. Filetype

Filetype 是 Buffer 的局部属性：

```lua
vim.bo.filetype
```

Neovim可以根据以下信息检测它：

- 文件名和扩展名
- 文件路径
- shebang
- 文件内容
- 用户规则

例如：

```text
init.lua    -> lua
README.md   -> markdown
Dockerfile  -> dockerfile
```

Filetype 本身只是一个标签。设置为 `lua` 不等于已经拥有 Treesitter、
LSP、formatter 或 linter。

## 2. ftplugin 和 indent

检测到 Filetype 后，Neovim 可以加载对应的运行时文件：

```text
ftplugin/lua.lua
indent/lua.vim
```

ftplugin 常用于设置：

- comment 规则
- Buffer-local options
- Filetype 特有命令或映射

indent 脚本负责计算自动缩进。它不等于 formatter。

## 3. 传统 Syntax

传统 Syntax 主要使用 Vim 的 pattern 和 region 规则识别文本：

```text
关键字规则
字符串规则
注释区域规则
```

它主要解决高亮，不建立完整语法树。

## 4. Treesitter

Treesitter 使用某种语言的 parser 把文本解析成语法树：

```text
源代码
-> parser
-> syntax tree
-> query
-> highlight capture / textobject / navigation
```

需要区分：

- Neovim Treesitter API：Neovim 原生能力
- parser：每种语言单独需要的解析器
- query：从语法树中选择结构节点的规则
- `nvim-treesitter`：管理和集成 parser/query 的第三方插件

有 parser 不代表所有功能自动存在。高亮、textobject、选择和导航还需要
对应 query 和启用逻辑。

## 5. 与 LSP 的边界

Treesitter 主要理解单个 Buffer 中的语法结构：

- 这是函数还是字符串
- 某节点的范围是什么
- 结构化高亮和选择

LSP 理解项目和语言语义：

- 这个名字引用了哪个定义
- 类型是什么
- 跨文件引用在哪里
- 如何重命名符号

```text
Treesitter -> 语法结构
LSP        -> 项目语义
```

二者互补，不互相替代。

## 当前决策

- 保留 Neovim 原生 Filetype detection、ftplugin 和 indent。
- 不手动启用重复的传统 Syntax 配置。
- 暂不安装 `nvim-treesitter`。
- 等确认实际语言清单后，再决定哪些 parser 和 Treesitter 功能需要管理。

## Go 实例

当前机器：

```text
Go             1.26.0
go             已安装
gofmt          已安装
gopls          未安装
goimports      未安装
golangci-lint  未安装
staticcheck    未安装
```

裸 Neovim 打开 Go Buffer：

```text
filetype        go
commentstring   // %s
indentexpr      GoIndent(v:lnum)
传统 Syntax     go
Treesitter      没有 Go parser，未启动 highlighter
```

因此当前链路是：

```text
Go 文件
-> 原生 Filetype detection
-> 原生 Go ftplugin
-> 原生 Go indent
-> 传统 Go Syntax 高亮
```

缺少的是：

```text
Go Treesitter parser
-> 结构化高亮和后续 Treesitter 功能
```

Neovim 0.12.4 内置 C、Lua、Markdown、Vimscript、Vimdoc 和 query
parser，不内置 Go parser。官方本地帮助建议额外 parser 手动安装，或由
`nvim-treesitter` 等插件管理。

当前决定：

- 不手动编译并把 Go parser 放进配置仓库。
- 在插件管理阶段加入 `nvim-treesitter`，先只管理 Go parser。
- `gopls` 属于 LSP 阶段。
- `gofmt` 和可能的 `goimports` 属于格式化阶段。
- linter 只有确认实际需求后再选择。

## 本阶段帮助页

```vim
:help filetype
:help filetype-detect
:help ftplugin
:help indent-expression
:help syntax
:help treesitter
:help treesitter-parsers
```

## 完成前需要能够说明

1. Filetype 为什么只是 Buffer 标签，而不是完整语言支持？
2. ftplugin、indent 和 formatter 的职责有什么区别？
3. 传统 Syntax 与 Treesitter 的差异是什么？
4. Neovim Treesitter API、parser 和 `nvim-treesitter` 插件分别是什么？
5. Treesitter 为什么不能代替 LSP？
