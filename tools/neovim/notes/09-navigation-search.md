# 09：文件导航与搜索

## 能力边界

```text
文件查找
-> 按文件名找到并打开文件

文本搜索
-> 在多个文件内容中查找文字

Buffer 切换
-> 切换已经载入 Neovim 的 Buffer

目录浏览
-> 查看目录结构并操作文件
```

这些是四种不同能力，不应该因为都出现在 picker 中就混为一谈。

## 路径边界

- cwd：Neovim 命令解析相对路径时使用的当前目录。
- LSP root：Language Server 分析 workspace 的边界。
- 搜索 root：一次文件或文本搜索使用的起点。

三者可以相同，但不是同一个概念。

## Picker

当前选择 Snacks Picker，只启用 Picker 功能：

```text
基础键位：
<leader>ff       查找 cwd 中的文件
<leader>sg       搜索 cwd 中的文本
<leader>bs       切换已加载的 Buffer

高频快捷入口：
<leader><space>  等同于 <leader>ff
<leader>/        等同于 <leader>sg
<leader>,        等同于 <leader>bs

<A-w>            在输入区、结果区和预览区之间切换
<A-q>            关闭 Picker
```

`fd` 提供文件列表，`rg` 提供文本搜索。Snacks 是插件集合，但当前没有
启用它的 Explorer 或 Scratch。

## Explorer

当前选择 Neo-tree，只启用 filesystem source：

```text
<leader>e  在右侧打开或关闭 cwd 的目录树
.          将当前目录设为 Neo-tree 的树根
```

- filesystem source 负责目录浏览和文件操作。
- `.` 改变树根，不改变 Neovim cwd。
- Neo-tree 在当前 Neovim 会话中保存树的状态，关闭后再次打开仍会保留
  之前的树根和展开状态。
- 文件名旁显示 Git 状态，但这不等于切换到了 git_status source。
- git_status source 是只整理 Git 变更文件的另一棵树，暂未配置入口。
- Neo-tree 的 Buffer source 与 Snacks Buffer Picker 重复，暂不使用。

Neo-tree 依赖 `nui.nvim` 构建界面，依赖 `plenary.nvim` 扫描文件系统。
