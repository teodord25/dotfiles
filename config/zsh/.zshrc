eval "$(starship init zsh)"

# persist agent to file so it works with new windows
agent_file="$HOME/.ssh/agent.env"
if [ -f "$agent_file" ]; then
  eval "$(cat "$agent_file")" > /dev/null
fi
if ! kill -0 "$SSH_AGENT_PID" 2>/dev/null; then
  eval "$(ssh-agent -s)" > "$agent_file"
  ssh-add ~/.ssh/id_ed25519_github
  ssh-add ~/.ssh/id_ed25519_jetbrains
fi

setopt vi
