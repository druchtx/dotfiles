# Dotfiles

Dotfiles are how you personalize your system. These are mine.

I personally install everything that does not need version management using [`Homebrew`](https://brew.sh), and the others using [`mise`](https://github.com/jdx/mise) for easily switching toolchain versions.

The repository is cloned from [**holman/dotfiles**](https://github.com/holman/dotfiles), **please read the README file in the original repository**.

Below are only the parts I extracted for reference when adding content.


## Components

There's a few special files in the hierarchy.

- `bin/`: Anything in `bin/` will get added to your `$PATH` and be made available everywhere.

- `topic/*.zsh`: Any files ending in `.zsh` get loaded into your environment.

- `topic/path.zsh`: Any file named `path.zsh` is loaded first and is expected to setup `$PATH` or similar.

- `topic/completion.zsh`: Any file named `completion.zsh` is loaded last and is expected to setup autocomplete.

- `topic/install.sh`: Any file named `install.sh` is executed when you run `script/install`. To avoid being loaded automatically, its extension is `.sh`, not `.zsh`.

- `topic/*.symlink`: Any file ending in `*.symlink` gets symlinked into your` $HOME`. This is so you can keep all of those versioned in your dotfiles but still keep those autoloaded files in your home directory. These get symlinked in when you run `script/bootstrap`.


## Install

⚠️ **WARING** : Be aware of what will happen before running the command,or you may mess up your Mac.

Just run the following command after removing unnecessary topics and tools.

```shell
./script/bootstrap
```