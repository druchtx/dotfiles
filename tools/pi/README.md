# Pi

Pi 的个人配置孵化目录。

Pi 的可版本控制配置在这里维护；运行时数据仍保留在本机的 `~/.pi/agent` 中。

## 内容

- `AGENTS.md`：Pi 全局行为规则
- `keybindings.json`：终端编辑器快捷键
- `settings.json`：Pi 全局个性化设置
- `zentui.json`：Zentui 主题配置
- `.gitignore`：忽略 Pi 的认证、会话和 package 缓存
- `PLAN.md`：集成方案和阶段计划

## 文件映射

只链接需要同步的配置文件，不接管整个 Agent 目录：

```text
tools/pi/settings.json     -> ~/.pi/agent/settings.json
tools/pi/keybindings.json  -> ~/.pi/agent/keybindings.json
tools/pi/zentui.json       -> ~/.pi/agent/zentui.json
tools/pi/AGENTS.md         -> ~/.pi/agent/AGENTS.md
```

Pi 的认证、会话、模型缓存和 package 缓存始终保留在本机，由 `tools/pi/.gitignore` 作额外保护：

```text
auth.json
sessions/
models-store.json
npm/
git/
```

> 旧版本曾把整个目录映射到 `~/.pi/agent`。切换后需要先移除旧的目录软链接，并将其中的运行时数据恢复到真实目录。

## 启用 Zentui

`settings.json` 已锁定 `npm:pi-zentui@0.21.0`，主题配置位于 `zentui.json`。链接完成后，在 Pi 中执行：

```text
/reload
/zentui
```

QEMU 由 Homebrew/Brewfile 管理。
