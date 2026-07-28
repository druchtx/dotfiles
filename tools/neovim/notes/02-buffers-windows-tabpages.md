# 02：Buffer、Window 与 Tabpage

## 本阶段目标

理解 Neovim 中三个最重要的界面对象：

- Buffer：内存中的文本内容
- Window：显示 Buffer 的视图
- Tabpage：一组 Window 的布局

它们之间不是一对一关系。

## 启动时的实际状态

使用当前最小配置启动 Neovim，即使没有打开文件，也已经存在：

```text
1 个 Buffer
1 个 Window
1 个 Tabpage
```

启动时的 Buffer 没有文件名，是一个空 Buffer。这说明 Buffer 不等于
磁盘文件。

## 核心关系

```text
Tabpage
└── Window
    └── 显示一个 Buffer
```

更完整的情况可能是：

```text
Tabpage 1
├── Window A -> Buffer 1
└── Window B -> Buffer 2

Tabpage 2
└── Window C -> Buffer 1
```

同一个 Buffer 可以被多个 Window 显示。一个 Window 在某个时刻只显示
一个 Buffer，但可以切换成另一个 Buffer。

## 1. Buffer

Buffer 是 Neovim 在内存中管理的一份文本内容。

它可能：

- 对应磁盘上的文件
- 是尚未保存的新文件
- 是帮助页
- 是终端内容
- 是插件生成的临时界面

常用命令：

```vim
:edit path/to/file
:enew
:buffers
:buffer {number}
:bnext
:bprevious
:bdelete
```

重要区别：

- `:edit` 把文件内容读入 Buffer
- `:enew` 创建不对应文件的新 Buffer
- `:bdelete` 删除 Buffer
- 关闭 Window 不一定删除其中显示的 Buffer

## 2. Window

Window 是 Buffer 的显示视图，不是 macOS 应用窗口。

Window 保存与显示有关的状态，例如：

- 当前显示哪个 Buffer
- 光标位置
- 滚动位置
- Window-local options
- Window 尺寸和布局

常用命令：

```vim
:split
:vsplit
:close
:only
```

同一个 Buffer 可以同时出现在两个 Window 中。在其中一个 Window 修改
文本，另一个 Window 会看到同一份 Buffer 的变化。

## 3. Tabpage

Tabpage 是一组 Window 的布局容器。

它不是传统编辑器中“一个标签对应一个文件”的 tab。一个 Tabpage 可以
同时包含多个 Window，每个 Window 又显示一个 Buffer。

常用命令：

```vim
:tabnew
:tabedit path/to/file
:tabnext
:tabprevious
:tabclose
```

是否需要把 Tabpage 扩展成个人 workspace，是后续工作流设计问题，不能
先把它误认为文件标签。

## 动手实验

### 实验 A：Buffer 不等于文件

启动 Neovim，不打开任何文件：

```sh
nvim
```

运行：

```vim
:buffers
:enew
:buffers
```

观察没有文件名的 Buffer。

### 实验 B：一个 Buffer 可以有多个 Window

运行：

```vim
:vsplit
```

两个 Window 此时显示同一个 Buffer。在一侧输入文本，另一侧会显示相同
变化。

### 实验 C：关闭 Window 不等于删除 Buffer

先打开一个文件，再拆分 Window：

```vim
:edit README.md
:vsplit
:close
:buffers
```

关闭一个 Window 后，`README.md` 对应的 Buffer 仍然存在。

### 实验 D：Tabpage 是 Window 布局

运行：

```vim
:tabnew
:vsplit
```

当前 Tabpage 中存在两个 Window。切回前一个 Tabpage：

```vim
:tabprevious
```

会恢复前一个 Tabpage 自己的 Window 布局。

## 本阶段帮助页

```vim
:help windows-intro
:help buffers
:help window
:help tab-page
:help :bdelete
:help :close
```

## 完成前需要能够回答

1. Buffer 是否一定对应磁盘文件？
2. Window 与 Buffer 是什么关系？
3. 关闭 Window 是否等于删除 Buffer？
4. Tabpage 为什么不是传统的文件标签？
5. 同一个 Buffer 能否同时显示在多个 Window 中？
