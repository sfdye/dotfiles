# sfdye's dotfiles

## Features

- Ubuntu & macOS friendly
- Features organized by _topics_, easy to add/remove
- Install macOS apps from `homebrew` and `mas-cli`
- zsh with sensible defaults
- vscode
- vim 
- iterm (automatically keep preference in sync)
- git (with `hub` extension)
- python environment out of the box (virtualenv/virtualenvwrapper/pipenv)
- ruby/go/conda/docker/awscli
- A lot of useful aliases
- ...

## Components

- **bin/**: Anything in `bin/` will get added to your `$PATH` and be made
  available everywhere.
- **Brewfile**: This is a list of applications for [Homebrew Cask](https://caskroom.github.io) to install: things like Chrome and 1Password and stuff. Might want to edit this file before running any initial setup.
- **topic/\*.zsh**: Any files ending in `.zsh` get loaded into your
  environment.
- **topic/path.zsh**: Any file named `path.zsh` is loaded first and is
  expected to setup `$PATH` or similar.
- **topic/completion.zsh**: Any file named `completion.zsh` is loaded
  last and is expected to setup autocomplete.
- **topic/install.sh**: Any file named `install.sh` is executed when you run `script/install`. To avoid being loaded automatically, its extension is `.sh`, not `.zsh`.
- **topic/\*.symlink**: Any file ending in `*.symlink` gets symlinked into
  your `$HOME`. This is so you can keep all of those versioned in your dotfiles
  but still keep those autoloaded files in your home directory. These get
  symlinked in when you run `script/bootstrap`.

## How to use

```bash
git clone https://github.com/sfdye/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Set up git
# gitconfig.local.symlink will be ignored by git, so you don't need to
# worry about credentials beigin commited accidently
cp git/gitconfig.local.symlink.example git/gitconfig.local.symlink

# The fun begins
script/bootstrap
```

If you wanna set up git, renamegitconfig.local.symlink.example

This will symlink the appropriate files in `.dotfiles` to your home directory.
Everything is configured and tweaked within `~/.dotfiles`.

The main file you'll want to change right off the bat is `zsh/zshrc.symlink`,
which sets up a few paths that'll be different on your particular machine.

## How to go from here

```bash
# Modify zshrc.symlink, add a new topic (e.g. java), delete some apps from Brewfile, you name it

# Load changes in your terminal
reload!
```

## Inspired by these awesome dotfiles

- https://github.com/mihaliak/dotfiles
- https://github.com/nicksp/dotfiles
- https://github.com/holman/dotfiles
- https://github.com/sapegin/dotfiles
- https://github.com/kennethreitz/dotfiles
