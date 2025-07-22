let extra_paths = [
    ~/.apps
    ~/.cargo/bin
    ~/.local/bin
]

$env.path = ($env.path | prepend $extra_paths)

alias rebuild = bash -c /home/bane/dotfiles/scripts/sh/rebuild.sh
alias ga = git add
alias gc = git commit
alias gs = git status
alias gp = git push
alias gl = git log
alias gw = git switch
alias gm = git merge
alias gb = git branch

alias vi = nvim
alias nv = nvim
alias nd = nix develop
alias td = rg "TODO:"

mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")

mkdir ~/.cache/carapace
carapace _carapace nushell | save --force ~/.cache/carapace/init.nu
