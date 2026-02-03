eval "$(starship init zsh)"

if [ -z "$SSH_AUTH_SOCK" ]; then
  eval $(ssh-agent -s)
  ssh-add ~/.ssh/id_ed25519_github
  ssh-add ~/.ssh/id_ed25519_jetbrains
fi
