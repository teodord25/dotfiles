let carapace_completer = {|spans|
	carapace $spans.0 nushell $spans | from json
}

$env.config = {
	show_banner: false,
	completions: {
		quick: true
		partial: true
		algorithm: "fuzzy"
		external: {
			enable: true
			max_results: 100
			completer: $carapace_completer
		}
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
alias nd = nix develop
