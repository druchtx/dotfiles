# 阶段 13：插件审计

## 直接能力插件

| 插件 | 职责 | 依赖 | 删除后的损失 |
| --- | --- | --- | --- |
| lazy.nvim | 安装、加载并锁定插件版本 | Git | 失去当前插件管理入口 |
| nvim-treesitter | 安装 parser 并驱动语法解析 | treesitter-parser-registry | 失去当前语法高亮链路 |
| mason-lspconfig | 连接 Mason 与 Neovim LSP 配置 | mason.nvim、nvim-lspconfig | 需要手动安装并启用 gopls |
| mason-tool-installer | 声明并安装非 LSP 工具 | mason.nvim | 需要手动安装 golangci-lint |
| blink.cmp | 汇总并显示补全候选 | friendly-snippets | 失去补全菜单、Buffer 补词和 snippet |
| nvim-lint | 调用 linter 并发布诊断 | golangci-lint | 保存 Go 文件后不再自动 lint |
| Snacks | 文件、文本、Buffer、项目 Picker 和 lazygit 终端 | fd、rg、lazygit | 失去统一 Picker 和 lazygit 入口 |
| Neo-tree | 浏览目录并显示文件级 Git 状态 | nui.nvim、plenary.nvim | 失去常驻目录树 |
| Gitsigns | 当前 Buffer 的 hunk、blame 和局部暂存 | Git | 失去行级 Git 工作流 |
| Persistence | 自动保存并选择完整 Session | 原生 `:mksession` | 需要手动保存和加载 Session |
| vim-tmux-navigator | 跨 Neovim Window 与 tmux Pane 导航 | tmux 配置 | 导航在 Neovim 边界中断 |

## 只作为依赖的插件

| 插件 | 被谁使用 | 职责 |
| --- | --- | --- |
| treesitter-parser-registry | nvim-treesitter | 提供 parser 注册信息 |
| mason.nvim | mason-lspconfig、mason-tool-installer | 安装并暴露外部开发工具 |
| nvim-lspconfig | mason-lspconfig | 提供 LSP Server 启动配置 |
| friendly-snippets | blink.cmp | 提供现成 snippet 模板 |
| nui.nvim | Neo-tree | 提供 Neovim UI 组件 |
| plenary.nvim | Neo-tree | 提供通用 Lua 工具函数 |

## 审计结论

- 当前没有重复的 Picker、Explorer、补全、Session 或 Git 主实现。
- Snacks 的两份插件 spec 会被 lazy.nvim 合并为一个插件实例。
- Mason 只管理编辑器工具；语言运行时与项目特殊版本继续交给 mise。
- Diffview、调试器、测试运行器和多语言配置都因暂无需求而未加入。
- 外部程序不由 lazy.nvim 锁定版本，需要分别由 Homebrew、Mason 或 mise 管理。
- 当前插件不需要 LuaRocks，因此关闭 lazy.nvim 的 Rocks 支持。

## 空环境验收

使用独立的 XDG config、data、state 和 cache 目录完成验证，没有读取或修改
日常 Neovim 数据。所有锁定插件均能从零安装，Go parser、gopls 和
golangci-lint 安装成功，gopls 能 attach 到 Go Buffer。

`mason-lspconfig` 在 headless 模式会主动跳过 `ensure_installed`；测试中显式
安装 gopls 后继续验证。正常交互式 Neovim 不受这一限制。

## 最终验收

- lazy.nvim 健康检查通过，LuaRocks 支持因没有使用而关闭。
- Mason 能识别 mise 提供的 Go，并保持 PATH `append` 策略。
- Go Buffer 的 parser、gopls、Blink、nvim-lint 和 golangci-lint 全部通过。
- 其他语言工具缺失只产生可选警告，不属于当前配置范围。
