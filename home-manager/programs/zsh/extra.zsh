# Interactive-shell setup restored after moving off oh-my-zsh.
# Sourced late (initContent) so it runs after compinit and the plugins.

# --- Emacs line editing ----------------------------------------------------
# zsh auto-selects the *vi* keymap because EDITOR=vim, which drops the standard
# readline bindings (Ctrl+A/E, Alt+B/F, Alt+Backspace = backward-kill-word,
# ...). oh-my-zsh forced emacs mode; restore it here.
bindkey -e

# --- Autosuggestions: fetch asynchronously ---------------------------------
# The history is very large, and zsh-autosuggestions searches it on every
# keystroke. Doing that synchronously blocks the line editor, which shows up as
# backspace "not deleting" and completion stalling. Async moves the search to a
# background worker so keystrokes stay instant. (Read on the first prompt, so
# setting it here is early enough.)
ZSH_AUTOSUGGEST_USE_ASYNC=1
# Don't syntax-highlight extremely long lines, keeping the editor responsive.
ZSH_HIGHLIGHT_MAXLENGTH=512

# --- Tab completion: arrow-selectable menu (like oh-my-zsh) ----------------
zmodload zsh/complist
zstyle ':completion:*' menu select                          # interactive menu
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'   # case-insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"     # colourful matches
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
setopt AUTO_MENU          # open the menu on a second Tab
setopt COMPLETE_IN_WORD   # complete from the cursor, not just the end
# Arrow keys while the completion menu is open.
bindkey -M menuselect '^[[A' up-line-or-history
bindkey -M menuselect '^[[B' down-line-or-history
bindkey -M menuselect '^[[C' forward-char
bindkey -M menuselect '^[[D' backward-char

# --- Directory navigation with Ctrl+Arrows (up / back / forward) -----------
# Browser-style history of visited directories, like oh-my-zsh's dirhistory.
setopt AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT
autoload -Uz add-zsh-hook
typeset -ga _dh_past=("$PWD") _dh_future
_dh_push() { [[ "${_dh_past[-1]}" == "$PWD" ]] || { _dh_past+=("$PWD"); _dh_future=(); } }
add-zsh-hook chpwd _dh_push
# cd without disturbing the history arrays (used by back/forward navigation).
_dh_cd() { add-zsh-hook -d chpwd _dh_push; builtin cd -- "$1" 2>/dev/null; add-zsh-hook chpwd _dh_push; }
_dh-back() {
  (( ${#_dh_past} > 1 )) || return
  _dh_future=("$PWD" "${_dh_future[@]}")
  _dh_past[-1]=()
  _dh_cd "${_dh_past[-1]}"
  zle reset-prompt
}
_dh-forward() {
  (( ${#_dh_future} )) || return
  local d="${_dh_future[1]}"
  _dh_future[1]=()
  _dh_past+=("$d")
  _dh_cd "$d"
  zle reset-prompt
}
_dh-up() { builtin cd .. 2>/dev/null; zle reset-prompt }
zle -N _dh-back
zle -N _dh-forward
zle -N _dh-up
# Common xterm-style Ctrl+Arrow sequences (COSMIC Terminal uses these).
bindkey '^[[1;5D' _dh-back      # Ctrl+Left  : previous directory
bindkey '^[[1;5C' _dh-forward   # Ctrl+Right : next directory
bindkey '^[[1;5A' _dh-up        # Ctrl+Up    : parent directory
