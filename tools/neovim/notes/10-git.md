# 10：Git 基础能力

## 状态层次

```text
HEAD
-> 已提交版本

Index
-> 已暂存版本

磁盘文件
-> Working Tree 中已经保存的版本

Buffer
-> Neovim 内存中的当前版本
```

保存 Buffer 只更新磁盘文件；暂存更新 Index；提交才产生新的 HEAD。

## Gitsigns

Gitsigns attach 到 Git 仓库中的文件 Buffer，提供行级 diff 和 hunk。
当前只启用读取与导航能力：

```text
]h           下一个 hunk
[h           上一个 hunk
<leader>gp  预览当前 hunk
<leader>gb  查看当前行 blame
<leader>gs  暂存当前 hunk
```

这些键位是 Buffer-local，只会出现在 Gitsigns 成功 attach 的 Buffer。
Visual Mode 下的 `<leader>gs` 只暂存选中行。暂不绑定整文件暂存和会
修改 Buffer 的 reset 操作。

Neo-tree 显示文件级 Git 状态；Gitsigns 显示当前 Buffer 的行级状态。

## Git UI

```text
<leader>gg  在 cwd 中打开 lazygit
```

`lazygit` 是 Homebrew 管理的外部程序，负责提交、分支、stash、rebase
和远程操作。Snacks 只负责在 Neovim Terminal Window 中启动它。
