# Neovim Configuration Guide

## Current architecture

This directory contains the repository-managed Neovim configuration. It is
currently built on top of `LazyVim`, with `lazy.nvim` responsible for plugin
specification, loading, and lockfile management.

The configuration is intentionally being developed as an explicit, opinionated
setup. When implementing or changing a user-facing behavior, do not assume
that a LazyVim default, plugin default, default keymap, or default option is
part of this project's contract. If the behavior matters to this setup, define
it explicitly in the repository configuration.

This also applies to the long-term migration plan: after the configuration is
well understood, it may be simplified toward a smaller LazyVim-only setup.
Until that decision is made, preserve the current explicit definitions rather
than silently depending on upstream defaults.

## Entry points and directory responsibilities

- `config/init.lua`: minimal startup entry point. It loads core options,
  bootstraps the plugin system, and then loads core keymaps.
- `config/lua/core/`: startup-level Neovim configuration that is independent of
  individual plugin features. Put global options, native autocmds, keymaps,
  and lazy.nvim bootstrap/import configuration here.
- `config/lua/plugins/`: user-facing plugin features, grouped by domain. A
  plugin file should make the feature and its public behavior easy to find.
  Keep plugin specifications and feature-level configuration here.
- `config/lua/utils/`: focused implementation helpers and integration modules.
  These modules may be tightly coupled to one feature or plugin when that
  keeps the feature file readable. Keep dependency direction clear: helpers
  should not import their owning feature, and avoid cycles between helpers.
- `config/lazy-lock.json`: lazy.nvim plugin version lockfile. Update it only
  when plugin resolution intentionally changes.
- `config/lazyvim.json`: LazyVim metadata.
- `config/stylua.toml`: Lua formatting configuration.
- `aliases.zsh`: shell aliases related to Neovim; it is outside the Lua
  runtime configuration.

Plugin feature groups currently include:

- `plugins/coding/`: completion, language tooling, linting, terminals, Git,
  and database integrations.
- `plugins/editor/`: bufferline, statusline, indentation, pairs, and saving.
- `plugins/navigation/`: explorer, picker, and navigation keymaps.
- `plugins/tools/`: tool-oriented integrations and commands.
- `plugins/workspace/`: dashboard, project entry points, scratch areas, and
  session behavior.
- `plugins/theme.lua`: colorscheme and theme integration.

## LazyVim and import rules

`core/lazy.lua` must import plugin specifications in this order:

1. `lazyvim.plugins`
2. Any `lazyvim.plugins.extras`
3. This configuration's `plugins` imports

When adding a plugin feature, place it in the appropriate domain directory and
make sure its namespace is imported by `core/lazy.lua`. Do not add a second
bootstrap path for lazy.nvim or LazyVim.

Use `opts` for declarative plugin configuration when possible. Use `config`
or a helper setup function only when behavior requires imperative wiring,
autocmds, or callbacks. A module under `utils/` is not a plugin: requiring it
only loads its definitions. If it installs autocmds or global behavior, give it
an explicit setup call from the startup path and document why it must run
early.

## Project-specific behavior

- Global options and native mappings must be explicitly defined in
  `core/options.lua` and `core/keymaps.lua`.
- Features should define their own keymaps and options instead of relying on
  LazyVim's current defaults.
- `utils/tabpage.lua` owns the tabpage/buffer relationship model. All tabpages
  in one Neovim process form an implicit workspace; there is no separate
  project abstraction in this core module. Bufferline consumes this model for
  its active-tab buffer filter and visual tab indicator.
- `utils/session.lua` exposes the concrete session capability API (`setup`,
  `list`, `restore`, `load`, `save`, `delete`, and `rename`) and owns the
  persistence/tabpage integration. The plugin spec should remain a readable
  LazyVim-style declaration of options, picker UI, commands, and keymaps.
- `utils/tabpage.lua` exposes tabpage state snapshot/save/restore APIs and does
  not own the session plugin lifecycle.
- `utils/buffer.lua` owns disk-version tracking and safe buffer saves. The
  editor save plugin initializes it and owns the keymap.
- `utils/explorer.lua` owns the responsive Explorer layout and option builder.
  The navigation plugin owns Snacks Explorer commands, keymaps, and the final
  picker call.
- Plugin-specific utils such as `bufferline.lua` and `diffview.lua` may expose
  option builders and behavior APIs, but their plugin specs must perform the
  third-party `setup()` call and assemble user-facing commands and mappings.
- Session workflow priority is: list/select/restore, save manually or from the
  exit hook, then delete and rename. Session paths to skip are configured by
  the editable `ignored_paths` list in
  `plugins/workspace/session.lua`; do not add new hard-coded `tmp.` checks.
- Buffer cleanup must preserve a buffer still referenced by another tabpage.
  Do not introduce detached/orphaned buffer states without an explicit design
  decision.

## Change guidelines

- Read the existing feature and its helpers before editing.
- Prefer a small, focused module over adding feature logic to a generic helper.
- Keep public APIs typed and documented, especially in `utils/` modules.
- Preserve unrelated working-tree changes and do not remove backups unless
  explicitly requested.
- For plugin-specific customization, keep the visible feature declaration in
  `plugins/` and move complex implementation details to a clearly named helper
  in `utils/`.
- Do not add a new abstraction merely to mirror a LazyVim or plugin concept;
  add one only when this configuration has its own behavior or contract.

## Validation

Run targeted checks after changes:

```sh
nvim -u tools/neovim/config/init.lua -i NONE -n --headless '+qa!'
luac -p <changed-lua-file>
git diff --check -- tools/neovim/config
```

For changes involving tabpage state, buffer cleanup, sessions, or UI layout,
also run a focused headless behavior check and verify the behavior manually in
Neovim when it affects visible layout or keymaps.
