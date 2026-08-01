# 08：补全、格式化与静态检查

## 补全链路

```text
gopls
-> 返回语义补全和 LSP snippet

blink.cmp
-> 自动触发、聚合来源、排序和显示候选

vim.snippet
-> 展开 snippet 并在 placeholder 之间跳转

friendly-snippets
-> 提供额外的现成 snippet 模板
```

## 当前补全来源

- `lsp`：`gopls` 返回的语义候选
- `path`：文件和目录路径
- `snippets`：`friendly-snippets` 模板
- `buffer`：当前 Buffer 中已经出现的单词

暂不启用命令行补全、自动括号和 LuaSnip。

## 当前按键

```text
Ctrl-Space  显示补全
Ctrl-n      下一项
Ctrl-p      上一项
Ctrl-y      接受
Ctrl-e      关闭
Tab         snippet 下一 placeholder，否则 fallback
Shift-Tab   snippet 上一 placeholder，否则 fallback
```

## 格式化与静态检查

```text
formatter
-> 改写代码排版

linter
-> 分析代码并报告问题

LSP
-> 通信协议，可以承载格式化请求和诊断结果
```

三者不是并列的同一种东西。Formatter 和 linter 是能力，LSP 是编辑器与
Language Server 之间的通信方式。

以 Go 为例：

- `gofmt`：只负责标准格式化。
- `goimports`：格式化并整理 import。
- `staticcheck`：检查可疑代码和常见错误。
- `golangci-lint`：统一运行多个 linter。
- `gopls`：通过 LSP 向 Neovim 提供格式化、诊断等能力。

## Go 静态检查

```text
mason-tool-installer
-> 确保 Mason 已安装 golangci-lint

nvim-lint
-> 保存 Go 文件后运行 golangci-lint
-> 解析命令输出

vim.diagnostic
-> 显示检查结果
```

Mason 只负责外部工具；`nvim-lint` 负责执行和解析。当前不自动更新
`golangci-lint`，主动执行 `:MasonToolsUpdate` 时才更新。

项目检查规则放在 `.golangci.yml`。Mason 的工具目录追加到 PATH：
项目环境或 mise 已提供工具时优先使用，找不到时才使用 Mason 版本。

## 手动格式化

`<leader>cf` 是固定的全局快捷键。执行时由 `vim.lsp.buf.format()` 查找当前
Buffer 中支持格式化的 LSP Client。

```text
<leader>cf
-> 发送 formatting 请求
-> Language Server 返回 TextEdit
-> Neovim 修改当前 Buffer
```

格式化只修改 Buffer，不会自动写入磁盘。整理 imports 仍属于独立的 Code
Action，不在这个快捷键中处理。
