# 07：原生 LSP 与外部 Language Server

## 职责

```text
Mason
-> 安装和管理 gopls

nvim-lspconfig
-> 提供 gopls 的 cmd、Filetype 和 root 配置

mason-lspconfig
-> 连接 Mason package 和 LSP config
-> 调用 vim.lsp.enable("gopls")

Neovim 原生 LSP Client
-> 启动 gopls
-> attach Buffer
-> 发送请求并处理结果

gopls
-> 分析 Go workspace
-> 返回定义、引用、类型、诊断和修改
```

## 当前范围

- 只安装并启用 `gopls`
- 使用 `nvim-lspconfig` 的默认 Go 配置
- 使用 Neovim 原生 LSP Client 和默认 capabilities
- 暂不加入补全、格式化、linter 或 DAP

## 管理入口

```vim
:Mason
:MasonInstall gopls
:MasonUninstall gopls
:MasonUpdate
:MasonLog
```

`lazy-lock.json` 锁定 Neovim 插件版本，不锁定 Mason 安装的外部工具版本。

## 状态与进程

```vim
:checkhealth vim.lsp
:lsp restart gopls
:lsp stop gopls
:lsp disable gopls
:lsp enable gopls
```

Neovim 0.12 已提供原生 `:lsp` 命令，因此当前 `nvim-lspconfig` 不注册
旧的 `:LspInfo` 等别名。使用 `:checkhealth vim.lsp` 查看配置、Client、
root 和 Buffer attach 状态。
