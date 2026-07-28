# 05：使用 lazy.nvim 管理插件和版本

## 职责

`lazy.nvim` 是插件管理器，负责：

- 下载插件源码
- 把插件加入 runtimepath
- 根据 plugin spec 决定加载时机
- 执行插件安装或更新步骤
- 生成和恢复 `lazy-lock.json`

它不提供 IDE 功能，也不是 LazyVim。

```text
lazy.nvim = 插件管理器
LazyVim   = 建立在 lazy.nvim 上的一整套预制配置
```

## Bootstrap

`core/lazy.lua` 的执行顺序：

```text
计算 stdpath("data")/lazy/lazy.nvim
-> 如果目录不存在，使用 git clone 下载 stable 分支
-> 把 lazy.nvim 加到 runtimepath 前部
-> require("lazy").setup(...)
```

插件管理器本身必须在 plugin spec 生效前存在，因此 bootstrap 不能由
插件管理器自己完成。

## 当前目录

```text
配置：
~/.config/nvim/lua/core/lazy.lua

插件管理器源码：
~/.local/share/nvim/lazy/lazy.nvim

未来的功能插件：
~/.local/share/nvim/lazy/<plugin-name>

版本锁：
~/.config/nvim/lazy-lock.json
```

配置和 lockfile 进入 Git；下载的插件源码不进入 dotfiles。

## 当前策略

- 使用 `lazy.nvim` 的 `stable` 分支完成 bootstrap。
- 不启用后台版本检查。
- 由用户主动检查和更新插件。
- plugin spec 默认不设置 `version`，具体版本由 lockfile 锁定 commit。
- 每次更新后执行对应功能验证，再提交新的 lockfile。

## Lockfile

`lazy-lock.json` 记录已安装插件的 commit。它解决：

```text
配置声明需要哪个插件
        +
lockfile 记录实际验证过的 commit
        =
其他机器可恢复相同插件版本
```

常用命令：

```vim
:Lazy
:Lazy check
:Lazy update
:Lazy restore
:checkhealth lazy
```

## 待学习

- plugin spec 的最小字段
- `opts` 与 `config`
- `dependencies`
- `event`、`cmd`、`keys` 与 lazy-loading
- 哪些插件不应该 lazy-load

## 第一个 plugin spec

Treesitter 拆成独立文件：

```text
lua/plugins/treesitter.lua
```

```lua
return {
  "neovim-treesitter/nvim-treesitter",
  dependencies = {
    "neovim-treesitter/treesitter-parser-registry",
  },
  lazy = false,
  build = ":TSUpdate",
}
```

字段职责：

- 仓库名：声明插件源码
- `dependencies`：先安装 parser registry
- `lazy = false`：该插件明确不支持 lazy-loading
- `build`：安装或更新插件后执行 parser/query 更新命令

这里没有调用 parser 安装或启用 Go 高亮；这些属于下一阶段的功能配置。
