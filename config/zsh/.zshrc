eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

eval "$(zoxide init --cmd cd zsh)"

setopt vi

alias rb="~/dotfiles/scripts/sh/rebuild.sh"
alias ga="git add"
alias gc="git commit"
alias gs="git status"
alias gp="git push"
alias gl="git log"

alias gca="git commit --amend"

alias gw="git switch"
alias gm="git merge"
alias gb="git branch"

alias gb="git branch"

alias gsh="git stash"
alias gsa="git stash apply"
alias gsl="git stash clear"

alias gd="git diff"
alias gds="git diff --staged"

alias grs="git restore --staged"

alias vi="nvim"
alias nv="nvim"
alias nd="nix develop"
alias td="rg "TODO:""

alias ti="touch .git/index"

alias t="tmux"
alias n="nvim"
alias c="clear"

alias dev="~/dotfiles/scripts/sh/tmux/dev.sh"

export EDITOR="nvim"
