
# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# User configuration

# PATHs (important: gem path must be before alias)
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="/opt/homebrew/lib/ruby/gems/3.4.0/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Aliases
alias ls="colorls"

# Powerlevel10k config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Compilation flags
export LDFLAGS="-L/opt/homebrew/opt/zlib/lib -L/opt/homebrew/opt/jpeg/lib" 
export CPPFLAGS="-I/opt/homebrew/opt/zlib/include -I/opt/homebrew/opt/jpeg/include"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# rbenv (only if installed)
if command -v rbenv >/dev/null; then
  eval "$(rbenv init - zsh)"
fi

# Git helper functions
cb() {
  if [ $# -lt 2 ]; then
    echo "❌ Usage: cb <prefix> <branch-name-parts...>"
    return 1
  fi
  local prefix="$1"
  shift
  local suffix=$(echo "$*" | tr ' ' '-')
  git checkout -b "$prefix/$suffix"
}

cm() {
  if [ $# -lt 1 ]; then
    echo "❌ Usage: cm <commit message parts...>"
    return 1
  fi
  local first_word="$1"
  shift
  local rest="$*"
  if [ -z "$rest" ]; then
    git commit -m "${first_word}:"
  else
    git commit -m "${first_word}: ${rest}"
  fi
}

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# To customize prompt, run `p10k configure` or edit ~/dotfiles/zsh/.p10k.zsh.
[[ ! -f ~/dotfiles/zsh/.p10k.zsh ]] || source ~/dotfiles/zsh/.p10k.zsh
