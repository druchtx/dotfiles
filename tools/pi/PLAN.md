# Pi 集成 dotfiles 方案

状态：规划中。本文档是当前讨论稿，不代表已经完成实施。

## 当前方向

已决定将 `tools/pi/` 作为 Pi 配置的 dotfiles 源目录，只链接受版本控制的配置文件到 `~/.pi/agent/`。认证、会话和缓存始终留在本机。Pi 仍作为一个普通开发工具放在：

```text
tools/pi/
```

原因：

- Pi 本身是终端开发工具，和 Neovim、tmux、Ghostty 更接近。
- Gondolin 是 Pi 的执行后端/Extension，不是独立的个人 AI 配置体系。
- QEMU 是 Gondolin 的宿主依赖，不需要人为制造一层 dotfiles 配置目录。

## 生命周期策略

当前采用“先实验、后归档”的方式：

### 阶段一：在 `tools/pi/` 中孵化

- Pi 配置、快捷键、Prompt、Extension 都先放在 `tools/pi/`。
- 允许频繁调整目录结构和配置格式。
- 不急着和现有 Claude/Codex 的 `ai/` 结构共享或统一。
- 配置、主题和可编辑的 Extension 源码统一放在 `tools/pi/`。
- `dfm` 只负责链接配置文件，不接管整个 Agent 目录。
- `tools/pi/.gitignore` 作为运行时文件误放入源目录时的额外保护。

### 阶段二：配置成熟后迁移到 `ai/`

当 Pi 的配置和工作流稳定后，再评估迁移到：

```text
ai/pi/
```

迁移时一次性更新：

- 资源目录
- `dfm` 脚本或 manifest entry
- README 和文档
- Extension 依赖安装路径
- 共享规则、Skills、Prompts 的边界

迁移不是现在的前置条件，也不应该阻碍 Pi 配置本身的试验。

### 阶段三：纳入一键环境构建

最终目标是新机器上执行一套标准流程即可完成环境构建。

当前完整流程是：

```bash
./bootstrap
./bin/dfm sync --force
```

未来可以再决定是否让 `./bootstrap` 直接包含 link/sync，真正做到单命令完成；这属于后续 dotfiles 流程优化，不是 Pi 配置阶段的前置条件。

职责分层：

- `Brewfile`：安装 Pi、Node、QEMU 等宿主依赖
- dotfiles：保存稳定配置和 Extension 源码
- `dfm`：链接配置、执行 setup 脚本
- `setup-pi.sh`：安装 Extension npm 依赖并完成 Pi 特有初始化
- `~/.pi/agent/`：保存本机认证、会话和运行时缓存

## 目标

1. 用 Homebrew 管理宿主环境依赖：Pi、Node、QEMU。
2. 用 dotfiles 管理稳定的 Pi 配置和自维护 Extension 源码。
3. 用 npm 仅管理 Extension 的 JavaScript 依赖。
4. 认证、会话、缓存和 VM 镜像不纳入 Git；Pi runtime 文件由 `tools/pi/.gitignore` 排除。
5. 新机器可以通过 `brew bundle` + `dfm link` 恢复环境。

## 当前状态

- Pi 已通过 Homebrew 安装。
- QEMU 已通过 Homebrew 安装，并已加入 `Brewfile`。
- 当前 Gondolin Extension 位于 `~/.pi/agent/extensions/gondolin`，尚未纳入仓库。
- Pi 全局配置位于 `~/.pi/agent/`。
- 现有 `ai/setup-ai.sh` 负责 Claude/Codex 的配置链接。
- 本方案不要求把 Pi 并入 `ai/setup-ai.sh`。

## 推荐目录结构

```text
tools/
  pi/
    PLAN.md                  # 当前讨论稿
    README.md
    AGENTS.md                # Pi 全局上下文规则
    settings.json            # Pi 全局个性化设置
    keybindings.json
    prompts/
    skills/
    themes/
    setup-pi.sh

# Extension 先在 ~/.pi/agent/extensions/ 中逐个试用，成熟后再考虑纳入这里
```

方案文档和后续 Pi 资源统一放在 `tools/pi/` 下，避免出现两套 Pi 根目录。

## 目标映射

仅将受版本控制的配置文件逐个链接到 Pi Agent 目录：

```text
tools/pi/settings.json     -> ~/.pi/agent/settings.json
tools/pi/keybindings.json  -> ~/.pi/agent/keybindings.json
tools/pi/zentui.json       -> ~/.pi/agent/zentui.json
tools/pi/AGENTS.md         -> ~/.pi/agent/AGENTS.md
```

认证、会话、模型缓存和 package 缓存保留在本机的 `~/.pi/agent/`，不由 `dfm` 迁移或接管。

## Tmux 与 Pi 快捷键

当前 `tools/tmux/tmux.conf` 已经使用无 Prefix 的 `Ctrl+h/j/k/l` 在 pane 之间切换，并且只对 Vim/fzf 等进程把按键转发给应用。Pi 在 tmux 中通常显示为 `node` 进程，因此直接把 `Ctrl+h/j/k/l` 配给 Pi 会被 tmux 拦截。

Pi 只自定义左右移动，保留 Pi/Neovim 习惯的删除和 tmux pane 快捷键。

最终决定：

- `Ctrl+b`：左
- `Ctrl+f`：右
- 上下：使用方向键
- `Ctrl+d`：保留 Pi 默认的向前删除字符
- `Ctrl+u`：不作为上下移动，保留 Pi 默认行为
- 禁用 `Ctrl+d` 在空输入框中的退出动作
- `Ctrl+h/j/k/l` 保留给 tmux pane 切换
- 选择列表仍使用方向键
- 不修改 tmux 的 Pi 进程识别规则

## QEMU 是否需要 `tools/qemu/`

当前不需要。

现有 Gondolin Extension 调用 `VM.create()` 时使用默认 QEMU backend，没有读取任何 QEMU 配置文件。QEMU 在这里是一个宿主机可执行依赖，应该只由 Homebrew/Brewfile 管理：

```ruby
brew 'qemu'
```

因此暂时不创建：

```text
tools/qemu/
```

只有在未来确实维护 QEMU 参数、机器级启动脚本或专用 wrapper 时，才考虑创建对应目录。

## Gondolin 是否需要 `tools/gondolin/`

当前也不需要独立目录。

Gondolin 的持久化内容实际上是 Pi Extension 的源码和依赖声明，因此放在：

```text
tools/pi/extensions/gondolin/
```

而不是：

```text
tools/gondolin/
```

当前 Extension 内部的 `/workspace` 挂载、VM 创建方式和工具路由都是源码的一部分，没有独立的 Gondolin 配置文件。

Gondolin 的 VM 镜像缓存位于类似下面的运行时目录，不纳入 dotfiles：

```text
~/.cache/gondolin/images/
```

如果以后需要配置 VMM backend、镜像、网络策略或挂载规则，再考虑增加：

```text
tools/pi/gondolin.json
```

但它仍然属于 Pi 配置，不需要单独的 `tools/gondolin/`。

## Settings 策略

Pi 没有 `settings.override.json` 这个配置文件。官方支持的是：

- 全局：`~/.pi/agent/settings.json`
- 项目级：项目目录下的 `.pi/settings.json`

项目级 settings 会覆盖全局 settings。`AGENTS.override.md` 只适用于上下文文件，不适用于 settings。

配置文件通过 `dotfiles.json` 逐个链接：

```text
tools/pi/settings.json     -> ~/.pi/agent/settings.json
tools/pi/keybindings.json  -> ~/.pi/agent/keybindings.json
tools/pi/zentui.json       -> ~/.pi/agent/zentui.json
tools/pi/AGENTS.md         -> ~/.pi/agent/AGENTS.md
```

这样不会接管 `~/.pi/agent`，Pi 的认证、会话和缓存可以继续由本机管理。`tools/pi/settings.json` 直接保存个人个性化配置，而不是使用 `settings.defaults.json` 这种额外抽象。`zentui.json` 保存 Zentui 的界面配置。

需要接受的副作用是：Pi 可能写入 `lastChangelogVersion` 等运行时字段，从而让 dotfiles 工作树产生小的变更。如果后续觉得烦，再改成由 setup 脚本合并配置的方案。

初始希望管理的设置包括：

- `defaultProvider`
- `defaultModel`
- `defaultThinkingLevel`
- `externalEditor: "nvim"`
- `compaction`
- `retry`
- `enabledModels`
- 必要的 `packages` / `skills` / `extensions` 配置

## Plan Mode Extension

Pi 官方仓库提供了一个 plan-mode 示例 Extension。当前策略是先放在用户目录中逐个试用，不纳入 dotfiles：

```text
~/.pi/agent/extensions/plan-mode/
```

来源是与当前 Pi `v0.84.3` 匹配的官方 Git tag：

```text
https://github.com/earendil-works/pi/tree/v0.84.3/packages/coding-agent/examples/extensions/plan-mode
```

包含：

- `/plan`：切换只读 Plan mode
- `/todos`：查看计划进度
- `Ctrl+Alt+P`：切换 Plan mode
- Plan mode 下禁用 `edit`/`write`
- Plan mode 下限制 bash 为只读命令 allowlist
- 执行计划时恢复完整工具，并用 `[DONE:n]` 跟踪进度

它不是独立 npm 包，也没有额外 npm 依赖；它依赖 Pi 自带的 Extension API。等试用确认有价值后，再决定是否将源码纳入 `tools/pi/extensions/`。

## Gondolin Extension 策略

推荐把当前 Extension 源码复制到：

```text
tools/pi/extensions/gondolin/
```

提交：

- `index.ts`
- `package.json`
- `package-lock.json`

不提交：

- `node_modules/`
- VM 状态
- Pi session
- API 凭据

`setup-pi.sh` 负责：

1. 检查 Homebrew、Node 和 QEMU。
2. 为 `~/.pi/agent/extensions/gondolin` 创建精确的 Extension 链接。
3. 使用 Homebrew Node 执行 `npm ci --ignore-scripts`。
4. 提供 `status`、`link`、`unlink`，并且全部幂等。
5. 不覆盖 `~/.pi/agent/extensions` 下其他第三方 Extension。

不建议把整个 `~/.pi/agent/extensions` 目录链接到仓库。

## dotfiles 集成方式

首选新增独立脚本：

```text
tools/pi/setup-pi.sh
```

并在 `dotfiles.json` 增加：

```json
{
  "source": "tools/pi/setup-pi.sh",
  "type": "script"
}
```

这个脚本负责 Pi 特有的流程：

- 配置文件链接或合并
- 本地 Extension 路径配置
- Gondolin Extension 的 npm 依赖安装
- Homebrew/QEMU/Node 检查
- `status/link/unlink` 生命周期

Pi 官方支持在 `settings.json` 的 `extensions` 数组里加载本地 Extension 文件或目录：

```json
{
  "extensions": [
    "~/path/to/dotfiles/tools/pi/extensions/plan-mode"
  ]
}
```

因此，后续优先考虑把 `tools/pi/extensions/plan-mode` 和 `tools/pi/extensions/gondolin` 作为仓库源文件，并通过 settings 的 `extensions` 配置加载，而不是复制到 `~/.pi/agent/extensions`。

需要注意：全局 `~/.pi/agent/settings.json` 中的本地路径必须在不同机器上可解析。若路径不稳定，就由 `setup-pi.sh` 生成/更新，或者退回精确的 Extension 软链接方案。

`-e` 只适合一次性测试；`packages` 适合 npm/git 形式的可安装包，和本地 Extension 路径不是一回事。

现有 `ai/setup-ai.sh` 保持只管理 Claude/Codex，避免职责继续膨胀。

## Skills 和 Prompts

现有 `ai/shared/skills/*.md` 是普通 Markdown，还不是 Pi 的 Agent Skills 标准结构。Pi Skill 通常需要：

```text
skill-name/
  SKILL.md
```

并包含 `name`、`description` frontmatter。

因此第一阶段不直接复用全部共享 Skills：

1. 先建立 Pi 专用 `tools/pi/skills/`。
2. 确定哪些共享内容值得转换后，再迁移为标准 Skill。
3. 避免复制 Claude/Codex 的规则造成多份真相。
4. 后续再评估通过 Pi 的 `settings.skills` 读取 `~/.claude/skills` 或 `~/.codex/skills`。

### Prompt Templates 待办

暂不创建 Prompt Template，先记录候选，等 Pi 基础配置稳定后再统一设计：

- [ ] `/review`：代码审查
- [ ] `/commit`：生成 commit message
- [ ] `/explain`：解释报错或代码
- [ ] `/test`：生成或补充测试
- [ ] `/security`：安全检查

## 明确不纳入版本控制的内容

```text
~/.pi/agent/auth.json
~/.pi/agent/sessions/
~/.pi/agent/models-store.json
~/.pi/agent/npm/
~/.pi/agent/git/
~/.cache/gondolin/
**/node_modules/
```

尤其是 `auth.json` 可能包含 OAuth token，绝不能进入 dotfiles。

## Homebrew/npm 管理边界

计划由 Homebrew 管理：

```text
pi-coding-agent
node
qemu
```

当前 `qemu` 已在 `Brewfile`。后续可以考虑显式加入 `brew 'node'`，让 Node 不仅作为 Pi 的传递依赖存在。

计划由 npm 管理：

```text
@earendil-works/gondolin
```

它是 Pi Extension 的运行依赖，不是系统级工具。当前依赖安装报告了一个传递依赖 `undici` 的 audit warning，需要在正式长期使用前重新确认版本和修复策略。

## 实施阶段

### 阶段 0：确认决策

- [x] Pi 根目录使用 `tools/pi/`
- [x] 使用 `settings.json` 保存个人个性化配置，暂不引入 defaults/override 抽象
- [ ] 确定是否显式将 `node` 加入 `Brewfile`
- [ ] 确定 Gondolin 是否作为仓库内源码维护
- [ ] 确定是否第一阶段就迁移共享 Skills
- [x] 将本方案文档放在 `tools/pi/PLAN.md`

### 阶段 1：基础配置

- [x] 创建 Pi 全局 `AGENTS.md`
- [x] 创建 `keybindings.json`，使用 `Ctrl+b/f` 左右移动并禁用 `Ctrl+d` 退出
- [x] 配置 `nvim` 为外部编辑器
- [x] 配置基础模型、思考级别和 compaction
- [x] 将 Pi settings 和 keybindings 登记到 `dotfiles.json`
- [ ] 执行 `dfm link` 并验证普通 Pi 启动

### 阶段 2：Plan Mode Extension

- [x] 找到官方 `plan-mode` 示例
- [x] 使用与当前 Pi `v0.84.3` 匹配的 tag
- [x] 确认暂不纳入 dotfiles
- [ ] 放入 `~/.pi/agent/extensions/plan-mode` 试用
- [ ] 验证 `/plan`、`/todos`、`Ctrl+Alt+P`
- [ ] 评估官方示例是否需要个性化修改
- [ ] 试用后再决定是否迁移到 `tools/pi/extensions/`

### 阶段 3：Gondolin

- [ ] 将 Extension 源码放入 `tools/pi/extensions/gondolin`
- [ ] 设计 `tools/pi/setup-pi.sh`
- [ ] 使用 Homebrew Node 安装依赖
- [ ] 接入 `dotfiles.json`
- [ ] 验证链接、卸载和重新链接不会影响其他 Extension

### 阶段 4：验证

- [ ] `./bin/dfm status`
- [ ] `pi` 启动时能加载 Pi 全局规则
- [ ] Gondolin 中 `uname` 显示 Linux
- [ ] `/workspace` 正确映射当前项目
- [ ] 项目文件写入能回到宿主机
- [ ] Pi 普通启动不会修改仓库中的运行时状态
- [ ] `auth.json`、sessions、缓存和 VM 镜像未被纳入 Git

### 阶段 5：可选增强

- [ ] Agent Skills 标准化
- [ ] Pi 专用 prompt templates
- [x] 自定义 keybindings / theme（Zentui）
- [ ] Git checkpoint Extension
- [ ] SRT 与 Gondolin 的使用场景区分
- [ ] 评估 Gondolin 的可选 `krun` backend

## 验收标准

最终希望做到：

```bash
brew bundle --file=main/Brewfile
./bin/dfm link
cd 任意项目
pi
```

即可获得：

- 可复现的 Pi 个人配置
- Neovim 外部编辑器
- tmux 兼容的快捷键
- 可选的 Gondolin 工具隔离
- 不泄露凭据、不提交会话、不污染 dotfiles

## 当前明确不做的事情

- 不创建 `tools/qemu/`，因为当前 QEMU 没有需要持久化的配置。
- 不创建独立的 `tools/gondolin/`，因为它属于 Pi Extension。
- 不把 `auth.json` 放进仓库。
- 不自动迁移所有 Claude/Codex rules。
- 不把认证、会话和缓存纳入 Git。
- 配置文件逐个链接，不接管或迁移整个 `~/.pi/agent`。
- 不把 Gondolin 的 `node_modules` 提交到 Git。
