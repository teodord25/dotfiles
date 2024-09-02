#!/usr/bin/env nu

let old_dir = $env.PWD
cd ~/nixos/

nvim .

# fmt
alejandra .

# git diff with no context lines
git diff -U0 ~/nixos/.

print "NixOS Rebuilding..."

# if something errors cat log file
sudo nixos-rebuild switch --flake /home/bane/nixos/#main | lines | each { |it| 
    if $it =~ "err" { cat nixos-switch.log }
}

let gen = PAGER=cat nixos-rebuild list-generations 
	| lines
	| where $it =~ "\\d+\\scurrent"
	| first
	| split column ' '
	| get column1
	| get 0

let msg = $"gen ($gen)"

git commit -am $msg
cd $old_dir
