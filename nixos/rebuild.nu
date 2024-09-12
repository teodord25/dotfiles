#!/usr/bin/env nu

let old_dir = $env.PWD
cd ~/dotfiles/nixos/

nvim .

# fmt
alejandra .

# git diff with no context lines
git diff -U0 ~/dotfiles/nixos/.

print "NixOS Rebuilding..."
sudo tmux new-session -d -s nixos-rebuild "nixos-rebuild switch --flake /home/bane/dotfiles/nixos/#main &> output.txt"

mut file_ready = false
while ($file_ready == false) {
    if (open output.txt | lines | any { |line| $line =~ "restarting" }) {
        print "Config is fine, rebuilding..."
        $file_ready = true

    } else if (open output.txt | lines | any { |line| $line =~ "error" }) {
        print "Config invalid, error:"
        $file_ready = true
        cat output.txt

    } else {
        print "Waiting..."
        sleep 1sec
    }
}

open output.txt | lines | each { |line|
    if $line =~ "err" {
        cat nixos-switch.log
        print "Error detected: $line"
        input "error innit"
        rm output.txt
        exit 1
    }
}

let gen = PAGER=cat nixos-rebuild list-generations 
	| lines
	| where $it =~ "\\d+\\scurrent"
	| first
	| split column ' '
	| get column1
	| get 0

let msg = $"NixOS Rebuild - Generation ($gen)"

git commit -am $msg
cd $old_dir
