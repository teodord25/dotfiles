$env.config = {
	show_banner: false,
	completions: {
		quick: true
		partial: true
		algorithm: "fuzzy"
	}
}

$env.PATH = ($env.PATH |
	split row (char esep) |
	prepend /home/myuser/.apps |
	append /usr/bin/env
)

$env.path ++= ["~/.cargo/bin"]
$env.path ++= ["~/.local/bin"]

alias rebuild = bash -c /home/bane/dotfiles/scripts/sh/rebuild.sh
alias ga = git add
alias gc = git commit
alias gs = git status
alias gp = git push
alias gl = git log
alias vi = nvim
alias nv = nvim
alias nd = nix develop
alias td = rg "TODO:"

mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
