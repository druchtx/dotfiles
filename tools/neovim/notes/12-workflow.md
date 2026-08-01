# 阶段 12：个人工作流

## Project、Session 和 Workspace

- Project 是一个项目目录，不是 Neovim 原生对象。
- Session 是保存到文件中的编辑器状态。
- Workspace 是我们自己组合 Project、Session 和 Tabpage 的规则。
- Tabpage 原生只管理一组 Window，不会自动隔离 Buffer。

## 当前最小项目切换

`<leader>fp` 从 `features/projects.lua` 顶部配置的目录中发现项目：

- 每一项可以是 Git 项目，也可以是包含多个项目的目录。
- 配置项自身有 `.git` 时直接加入，不再扫描其内部。
- 默认扫描 `$PROJECTS`，也直接加入 `~/.dotfiles`。
- 从每个一级目录开始，最多扫描三层。
- 找到 `.git` 文件或目录后，将其作为项目并停止深入该分支。
- 三层内没有找到 Git 仓库时，将一级目录本身作为项目。

选中后：

1. 使用 `tcd` 设置当前 Tabpage 的工作目录。
2. 在右侧打开以该目录为根的 Neo-tree。

这里使用 tab-local cwd，所以不同 Tabpage 可以位于不同项目；Buffer 仍然是
整个 Neovim 实例共享的。

暂时不恢复旧配置中的项目缓存、Session 自动恢复和 Buffer 归属管理。

## Session 持久化

Persistence 在第一次读取真实文件时加载，并在退出时自动保存当前 Session。
默认按 cwd 和 Git 分支区分 Session，至少打开一个文件 Buffer 才会保存。

插件不会自动恢复 Session。`<leader>qs` 选择并恢复一个完整的 Neovim
Session；它不接入 project picker，也不是只恢复当前 Tabpage。

只通过 project picker 打开目录不会保存 Session。Persistence 在读取至少
一个真实文件后才启动并满足默认的保存条件，以避免产生空 Session。

## 暂缓 Tab-scoped Workspace

当前只使用 tab-local cwd。Buffer 继续由整个 Neovim 实例共享，不增加
Tabpage Buffer 归属、过滤或额外的 Session 序列化。

## tmux 导航

tmux 先判断当前 Pane 是否运行 Neovim：不是则直接切换 Pane，是则把
`Ctrl-h/j/k/l` 交给 Neovim。`vim-tmux-navigator` 在 Neovim Window 内
导航，到达边界后再切换 tmux Pane。`Ctrl-\` 返回上一个 Window 或 Pane。

该链路已在真实 tmux 中验证。Neo-tree 当前固定在右侧已满足使用，暂不恢复
旧配置的响应式 Explorer 布局。

## 输入法

离开 Insert Mode 时，Neovim 异步调用本机已有的 Hammerspoon，将输入源
切换为 `com.apple.keylayout.ABC`。当前只监听 `InsertLeave`，不安装额外
输入法工具或 Neovim 插件。

## 验证

1. 新建两个 Tabpage，分别选择两个项目。
2. 在每个 Tabpage 中执行 `:pwd`，结果应该不同。
3. Neo-tree 应该显示当前选择的项目目录。
4. 切换 Tabpage 后，各自的 `:pwd` 应保持不变。
