#
# Defines tmux aliases and provides for auto launching it at start-up.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#   Colin Hebert <hebert.colin@gmail.com>
#   Georges Discry <georges@discry.be>
#   Xavier Cambar <xcambar@gmail.com>
#

# Return if requirements are not found.
if (( ! $+commands[tmux] )); then
  return 1
fi

#
# Auto Start
#

if ([[ "$TERM_PROGRAM" = 'iTerm.app' ]] && \
  zstyle -t ':prezto:module:tmux:iterm' integrate \
); then
  _tmux_iterm_integration='-CC'
fi

if [[ -z "$TMUX" && -z "$EMACS" && -z "$VIM" && -z "$INSIDE_EMACS" && "$TERM_PROGRAM" != "vscode" && "$TERMINAL_EMULATOR" != "JetBrains-JediTerm" ]] && ( \
  ( [[ -n "$SSH_TTY" ]] && zstyle -t ':prezto:module:tmux:auto-start' remote ) ||
  ( [[ -z "$SSH_TTY" ]] && zstyle -t ':prezto:module:tmux:auto-start' local ) \
); then
  tmux start-server

  # Create a 'prezto' session if no session has been defined in tmux.conf.
  if ! tmux has-session 2> /dev/null; then
    # Add tmuxinator support
    # zstyle -t doesn't work, so use zstyle -s as workaround -- Louis 2022/0923
    zstyle -s ':prezto:module:tmux:tmuxinator' name mux_project_name
    muxFailed=0

    if ( command -v tmuxinator >/dev/null 2>&1 ) && [[ -n "$mux_project_name" ]]; then
      # Check if project ${mux_project_name} existing
      if [[ $(tmuxinator list | tail -n 1) =~ $mux_project_name ]]; then
        # Command "tmuxinator ${mux_project_name}" and check result
        tmuxinator $mux_project_name 2> /dev/null

        if [[ $? != 0 ]]; then
          # If $? != 0 then something wrong
          muxFailed=1
        fi
      else
        # No $mux_project_name available
        muxFailed=1
      fi
    fi

    if [[ ${muxFailed} != 0 ]]; then
      # Something wrong in tmuxinator, create default session
      zstyle -s ':prezto:module:tmux:session' name tmux_session || tmux_session='prezto'
      tmux \
        new-session -d -s "$tmux_session" \; \
        set-option -t "$tmux_session" destroy-unattached off &> /dev/null
    fi
  fi

  # Attach to the 'prezto' session or to the last session used. (detach first)
  exec tmux $_tmux_iterm_integration attach-session -d

  # TODO
  # mux session needs to be detached twice to work, need to fix this
  # -- Louis 2022/0925
fi

#
# Aliases
#

alias tmuxa="tmux $_tmux_iterm_integration new-session -A"
alias tmuxl='tmux list-sessions'
