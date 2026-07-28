# 01：启动流程与配置加载

## 本机事实

当前环境：

```text
Neovim: 0.12.4
配置入口: ~/.config/nvim/init.lua
仓库目录: tools/neovim/config
```

`~/.config/nvim` 是指向仓库目录的软链接：

```text
~/.config/nvim -> ~/.dotfiles/tools/neovim/config
```

因此，Neovim 使用的是标准配置位置，同时配置内容由 dotfiles
仓库管理。

## 1. Neovim 如何找到 init.lua

默认情况下，Neovim 根据 XDG 目录规则计算配置根目录：

```lua
vim.fn.stdpath("config")
```

在当前机器上结果是：

```text
/Users/druchtx/.config/nvim
```

Neovim 启动时从该目录读取 `init.lua`。可以使用以下命令确认：

```vim
:echo stdpath("config")
:echo $MYVIMRC
```

`stdpath("config")` 是配置目录；`$MYVIMRC` 是这次启动实际加载的
用户配置文件。

在当前软链接结构下，两者的字面路径不同：

```text
stdpath("config") = /Users/druchtx/.config/nvim
$MYVIMRC          = /Users/druchtx/.dotfiles/tools/neovim/config/init.lua
```

前者保留标准配置目录，后者记录解析软链接后实际加载的文件。它们指向
同一份配置，但不应直接用字符串相等判断。

## 2. XDG 目录分别存放什么

当前机器上的默认值：

| 调用 | 路径 | 用途 |
|---|---|---|
| `stdpath("config")` | `~/.config/nvim` | 用户配置 |
| `stdpath("data")` | `~/.local/share/nvim` | 插件和持久数据 |
| `stdpath("state")` | `~/.local/state/nvim` | 状态、日志和 ShaDa |
| `stdpath("cache")` | `~/.cache/nvim` | 可重建缓存 |

配置不应把插件下载到 `config`。以后 `lazy.nvim` 默认会把插件放在
`data` 目录下。

## 3. runtimepath 是什么

runtimepath 是 Neovim 搜索运行时文件的一组有序目录，可以查看：

```vim
:set runtimepath?
```

当前用户配置目录位于 runtimepath 的前部，Neovim 自带的 runtime
位于中间，`after/` 目录位于后部。

它影响的内容包括：

- `plugin/`
- `autoload/`
- `ftplugin/`
- `syntax/`
- `colors/`
- `lua/`
- `after/`

可以把 runtimepath 理解为“Neovim 到哪些根目录寻找运行时资源”，
而不是 Lua 模块文件的完整路径列表。

## 4. require 如何找到自己的 Lua 模块

当前入口包含：

```lua
local startup = require("learning.startup")
```

因为配置根目录在 runtimepath 中，Neovim 会把模块名转换为候选路径：

```text
learning.startup
-> lua/learning/startup.lua
-> lua/learning/startup/init.lua
```

本次命中：

```text
tools/neovim/config/lua/learning/startup.lua
```

模块返回一个 Lua table。`init.lua` 取得该 table，并验证模块看到的
配置目录与入口看到的目录一致。

`require` 默认只加载同一模块一次，结果缓存在：

```lua
package.loaded["learning.startup"]
```

## 5. 如何跳过个人配置启动

排查“问题来自 Neovim 还是个人配置”时，可以运行：

```sh
nvim -u NONE
```

`-u NONE` 不读取用户 init 文件，也不进行 plugin 初始化。

还可以指定某一个配置文件：

```sh
nvim -u /absolute/path/to/init.lua
```

这在隔离测试配置时非常有用。

## 6. 本阶段常用帮助

这些帮助页是当前安装版本最直接的资料：

```vim
:help initialization
:help standard-path
:help runtimepath
:help lua-require
:help -u
```

## 心智模型

```text
启动 nvim
  -> 根据 XDG 规则确定 stdpath("config")
  -> 读取 config/init.lua
  -> config 目录已经在 runtimepath 中
  -> require("learning.startup")
  -> 查找 runtimepath 下的 lua/learning/startup.lua
  -> 执行一次并缓存到 package.loaded
```

## 动手检查

在 Neovim 中依次运行：

```vim
:echo stdpath("config")
:echo $MYVIMRC
:set runtimepath?
:lua print(vim.inspect(require("learning.startup")))
:lua print(package.loaded["learning.startup"] ~= nil)
```

然后在终端运行：

```sh
nvim -u NONE
```

观察跳过个人配置后，编辑器是否仍能正常启动。

## 完成前需要能够回答

1. 为什么仓库中的 `config/init.lua` 会被 Neovim 加载？
2. `stdpath("config")` 和 `stdpath("data")` 各自保存什么？
3. `require("learning.startup")` 对应哪个文件？
4. runtimepath 与 Lua `require` 是什么关系？
5. 如何启动一个不加载个人配置的 Neovim？
