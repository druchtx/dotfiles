# 03：Mode、Option、Keymap、Command 与 Autocmd

## 本阶段目标

理解 Neovim 原生配置中五种不同职责：

- Mode：当前按键如何被解释
- Option：编辑器当前采用什么设置
- Keymap：在某种 Mode 下把按键映射成什么操作
- Command：明确要求 Neovim 执行一次操作
- Autocmd：指定事件发生时自动执行操作

## 1. Mode

Neovim 是 modal editor。同一个按键在不同 Mode 中具有不同语义。

常用 Mode：

| Mode | 用途 | 常见进入方式 | 常见离开方式 |
|---|---|---|---|
| Normal | 导航和操作文本 | 启动默认进入 | - |
| Insert | 插入文字 | `i`、`a`、`o` | `<Esc>` |
| Visual | 选择文字 | `v` | `<Esc>` |
| Visual Line | 按整行选择 | `V` | `<Esc>` |
| Visual Block | 按矩形区域选择 | `<C-v>` | `<Esc>` |
| Command-line | 输入 Ex command | `:` | `<Enter>` 或 `<Esc>` |
| Replace | 覆盖已有文字 | `R` | `<Esc>` |
| Terminal-job | 将按键发送给终端进程 | 在终端 Buffer 中进入输入 | `<C-\><C-n>` |

查询当前 Mode：

```vim
:lua print(vim.api.nvim_get_mode().mode)
```

常见内部缩写：

```text
n = Normal
i = Insert
v = Visual
V = Visual Line
^V = Visual Block
c = Command-line
R = Replace
t = Terminal-job
```

Mode 决定按键的解释上下文。例如：

```text
Normal 中按 i -> 进入 Insert
Insert 中按 i -> 插入字符 i
Visual 中按 i -> 进入选择区域内部的文本对象操作
```

## 2. Option

Option 是控制编辑器行为的设置。

主要作用域：

- global：整个 Neovim 实例
- buffer-local：每个 Buffer 可以不同
- window-local：每个 Window 可以不同
- global-local：有全局默认值，也允许局部覆盖

Lua 中常用入口：

```lua
vim.opt
vim.opt_global
vim.opt_local
vim.bo
vim.wo
```

本节会通过具体 Option 学习作用域，不提前批量复制旧配置。

### 当前配置的作用域分类

```text
Global
└── diffopt

Buffer-local defaults
└── 暂无

Window-local defaults
├── wrap
├── linebreak
├── breakindent
└── showbreak
    ├── 局部作用域：Window
    └── 取值机制：global-local，可使用全局后备值
```

当前实现位于 `lua/core/options.lua`。

四个换行设置只改变 Window 如何显示长行，不会向 Buffer 插入换行符，
也不会修改磁盘文件。

`diffopt` 控制整个 Neovim 实例的 diff 行为，因此属于 Global。

对于局部 Option，需要区分：

- 作用域：值归属于 Buffer 还是 Window
- 设置时机：启动默认、FileType 事件或某个临时 Window

例如 `shiftwidth` 是 buffer-local；FileType autocmd 只是常见的设置时机，
并不是它成为 buffer-local 的原因。

## 3. Keymap

Keymap 是：

> 在指定 Mode 和作用域中，把一组按键映射为一个操作。

Lua API：

```lua
vim.keymap.set(mode, lhs, rhs, opts)
```

需要理解：

- mapping 属于哪个 Mode
- global 还是 buffer-local
- 是否允许递归展开
- 右侧是按键、命令还是 Lua callback
- 描述信息如何帮助发现快捷键

### 当前个人映射语法

使用：

```text
<leader> + 对象 + 动作
```

其中 `q` 表示安全退出：

```text
<leader>bq      Quit buffer
<leader>wq      Quit window
<leader><tab>q  Quit tabpage
<leader>qq      Quit Neovim
```

这些映射不使用 `!`，遇到未保存修改时应由 Neovim 拒绝操作。

插件相关映射不进入 `core/keymaps.lua`，而是在对应插件加入时定义。

## 4. Command

Command 是一次明确的操作请求，例如：

```vim
:write
:edit README.md
:bdelete
:set number
```

可以创建用户命令：

```lua
vim.api.nvim_create_user_command("Example", function()
  print("example")
end, {})
```

Command 只有在被调用时执行。

## 5. Autocmd

Autocmd 是事件驱动的自动操作：

```text
某个 event 发生
-> pattern 或 buffer 条件匹配
-> 执行 callback 或 command
```

例如：

```lua
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.lua",
  callback = function()
    -- 保存 Lua 文件前执行
  end,
})
```

需要理解：

- event
- pattern 或 buffer
- augroup
- callback
- 触发时机和副作用

## 职责对比

```text
Mode     -> 当前按键处于什么解释上下文
Option   -> 编辑器采用什么设置
Keymap   -> 某个 Mode 下按键执行什么
Command  -> 用户明确请求执行一次什么
Autocmd  -> 某个事件发生时自动执行什么
```

## 本阶段帮助页

```vim
:help vim-modes
:help options
:help map.txt
:help user-commands
:help autocmd.txt
```

## 完成前需要能够回答

1. 为什么同一个按键在不同 Mode 中行为不同？
2. global、buffer-local 和 window-local Option 有什么区别？
3. Keymap 为什么必须明确 Mode 和作用域？
4. Command 与 Keymap 是什么关系？
5. Autocmd 与普通 Command 最大的区别是什么？
