# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal fork of [Prezto](https://github.com/sorin-ionescu/prezto), a Zsh configuration framework. The branch `myprezto` contains Louis's customizations on top of the upstream `master`.

## Development Workflow

To test changes without affecting the live shell configuration:

```sh
mkdir devel-zprezto && cd devel-zprezto
git clone --recursive <this-repo> .zprezto
ZDOTDIR=$(pwd)
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
# Launch isolated Zsh session:
ZDOTDIR=/path/to/devel-zprezto zsh
```

Update submodules: `zprezto-update` (defined in `init.zsh`)

## Architecture

### Module System

Modules live in `modules/<name>/` and are loaded via `pmodload` (defined in `init.zsh:74-158`). Load order matters and is declared in `runcoms/zpreztorc` via:

```zsh
zstyle ':prezto:load' pmodule 'environment' 'editor' ... 'fzf-tab'
```

Each module follows this structure:
- `init.zsh` — sourced at load time
- `functions/` — auto-loaded functions (added to `fpath`)
- `README.md` — required for contributions

### Configuration

All preferences use Zsh's `zstyle` system, not environment variables. The primary config file is `runcoms/zpreztorc`. Custom aliases live in `runcoms/zsh_aliases` (~600 lines).

The custom prompt theme is `nshiu` (`zstyle ':prezto:module:prompt' theme 'nshiu'`). Git aliases from the git module are skipped (`zstyle ':prezto:module:git:alias' skip 'yes'`) in favor of custom aliases.

### Submodules

Key external dependencies (in `.gitmodules`):
- `contrib/fzf-tab` — fuzzy tab completion
- `modules/autosuggestions` — zsh-autosuggestions
- `modules/syntax-highlighting` — zsh-syntax-highlighting
- `modules/completion/external` — zsh-completions
- `modules/prompt/external/powerlevel10k` — (shallow clone)

### Customizations vs Upstream

Local additions on top of upstream `sorin-ionescu/prezto`:
- `runcoms/zsh_aliases` — extensive custom aliases
- Custom `nshiu` prompt theme
- `ya` wrapper for yazi (file manager with `$YAZI_CWD` integration)
- `chafa` as CLI image viewer
- `fzf-tab` contrib module enabled with custom keybindings and preview settings

## Code Style

Follows [Google Shell Style Guide](https://google.github.io/styleguide/shell.xml) with these additions:
- Use local variables whenever possible
- Prefer `zstyle` over environment variables for configuration
- Prefer `(( ... ))` over `[[ ... ]]` for arithmetic
- Use the `function` keyword to define functions
- 80-char limit can be waived for readability
