# 06：为 Go 加入 Treesitter

## 目标

只为 Go 安装：

- parser
- queries
- Treesitter highlighter

暂不启用 Treesitter indent、fold、textobjects 或 autotag。

## 安装时与启动时

插件安装或更新时：

```text
lazy.nvim build
-> 更新语言清单中已经安装的 parser/query
```

日常启动时：

```text
nvim-treesitter 进入 runtimepath
-> 异步检查语言清单，只安装缺失的 parser/query
-> 注册 Go FileType Autocmd
-> 已全部安装时不访问 registry 或网络
```

打开 Go Buffer 时：

```text
FileType=go
-> vim.treesitter.start(buffer, "go")
-> 加载 Go parser
-> 加载 Go highlight query
-> 启动 Neovim 原生 Treesitter highlighter
```

## 为什么不用每次启动 install

parser 安装由需求清单驱动：

- 启动时在后台补齐缺失的 parser
- 插件更新时同步更新 parser/query
- 已全部安装时立即跳过，不做 registry 或网络检查
- 新机器通过 lazy.nvim 安装即可恢复能力

`install(languages)` 和 `update(languages)` 分属不同生命周期：

- `install` 在配置加载时异步确保清单完整，已有 parser 会直接跳过
- `update` 在插件 build 时更新已有 parser/query

安装完成后会重新检查已经打开的 Buffer，避免直接打开一种新语言时，因
parser 尚未安装完成而错过首次高亮。

安装失败时统一提示使用 `:TSLog` 查看下载或编译错误。

新增普通语言时，只扩展配置顶部的清单：

```lua
local languages = { "go", "lua", "python" }
```

这个清单同时用于安装 parser/query，以及匹配对应的 Filetype。少数 parser
名称与 Filetype 不同的语言，需要单独建立映射，遇到时再处理。

## 当前未启用

- Treesitter indent：继续使用原生 `GoIndent(v:lnum)`
- Treesitter folds：尚未确认需要
- Treesitter textobjects：尚未确认需要
- autotag：Go 不需要

这些功能不能因为插件支持就默认开启。
