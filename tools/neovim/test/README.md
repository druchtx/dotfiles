# Neovim Test Cases

Run the headless regression suite from the repository root:

```sh
nvim --headless \
  --cmd 'set rtp^=/Users/druchtx/.dotfiles/tools/neovim/config' \
  -u /Users/druchtx/.dotfiles/tools/neovim/config/init.lua \
  '+luafile tools/neovim/test/headless.lua' \
  +qa
```

The suite covers:

- Lua syntax checks for every custom file under `tools/neovim/config/lua`.
- Startup options that affect wrapping and diff behavior.
- Custom module loadability for `config.*`, plugin modules, and shared helpers.
- Git helper behavior inside a temporary repository and outside repositories.
- Tab workspace project tracking with a temporary tab and directory.
- Project picker scanning of direct child project directories.
- Markdown autocmd behavior for disabling spell checking.
- Diffview commands, Snacks project command, and key Neovim mappings.

For a broader manual smoke test, run:

```sh
nvim --headless \
  --cmd 'set rtp^=/Users/druchtx/.dotfiles/tools/neovim/config' \
  -u /Users/druchtx/.dotfiles/tools/neovim/config/init.lua \
  '+Lazy! load all' \
  '+checkhealth' \
  +qa
```
