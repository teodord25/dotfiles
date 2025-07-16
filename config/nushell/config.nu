source ~/.cache/carapace/init.nu

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
