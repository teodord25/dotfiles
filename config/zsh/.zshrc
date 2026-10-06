export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

eval "$(starship init zsh)"
eval "$(zoxide init --cmd cd zsh)"

setopt vi

alias rb="~/dotfiles/scripts/sh/rebuild.sh"
alias ga="git add"
alias gc="git commit"
alias gs="git status"
alias gu="git branch -vv | grep -E 'ahead|^[^[]*$' | grep -v '^$'"
alias gp="git push"
alias gl="git log"

alias gca="git commit --amend"

alias gw="git switch"
alias gm="git merge"
alias gb="git branch"

alias gsh="git stash"
alias gsa="git stash apply"
alias gsl="git stash clear"

alias gd="git diff"
alias gdd="git diff | delta"

alias gds="git diff --staged"
alias gdsd="git diff --staged | delta"

alias grs="git restore --staged"

function ggrep() {
    git log --grep="$*"
}

alias vi="nvim"
alias nv="nvim"
alias nd="nix develop"
alias td='rg "TODO:"'

alias ti="touch .git/index"

alias t="tmux"
alias n="nvim"
alias c="clear"

alias dev="~/dotfiles/scripts/sh/tmux/dev.sh"

export EDITOR="nvim"


alias shell-bevy='nix-shell $HOME/dotfiles/shells/bevy.nix'

diane-pick() {
  fd -e md -e txt . "${1:-.}" \
    | fzf -m --preview 'bat --color=always {}' \
    | xargs -r -I{} diane drop --file {}
}


NEXT_FILE=~/.next
TODO_FILE=~/.todo

# next "x"  -> add a mid-flight item ("work on this tmr")
# next      -> edit the next list (delete lines when done)
next() {
  if (( $# )); then
    print -r -- "$*" >> $NEXT_FILE
  else
    ${EDITOR:-nvim} $NEXT_FILE
  fi
}

# todo      -> open the backlog
# todo "x"  -> append to the backlog without opening it
todo() {
  if (( $# )); then
    touch $TODO_FILE
    local tmp=$(mktemp "$TODO_FILE.XXXXXX") || return 1
    { print -r -- "[$(date '+%Y-%m-%d %H:%M')] $*"; cat $TODO_FILE } > $tmp \
      && mv $tmp $TODO_FILE
  else
    ${EDITOR:-nvim} $TODO_FILE
  fi
}

# print the next list on every new shell
if [[ -s $NEXT_FILE ]]; then
  print -P "%F{yellow}next:%f"
  sed 's/^/  /' $NEXT_FILE
fi

# right prompt: next count (yellow, red above 3) + backlog count (grey)
_work_prompt() {
  local n=$(grep -c . $NEXT_FILE 2>/dev/null)
  local t=$(grep -c . $TODO_FILE 2>/dev/null)
  local p=""
  if   (( n > 3 )); then p="%F{red}▸ $n%f"
  elif (( n > 0 )); then p="%F{yellow}▸ $n%f"; fi
  (( t > 0 )) && p+="${p:+  }%F{8}$t todos in todos file bro...%f"
  RPROMPT=$p
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _work_prompt


capsctrl() {
  local svc=kanata-default.service
  local bin=$(systemctl cat $svc | grep -oE '/nix/store/[^ ]+/bin/kanata' | head -1)
  sudo systemctl stop $svc
  {
    sudo $bin -c ~/.config/kanata/plain.kbd
  } always {
    sudo systemctl start $svc
  }
}
