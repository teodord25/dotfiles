#!/usr/bin/env nu

let old_dir = $env.PWD
cd ~/dotfiles/nixos/

nvim .

# fmt
alejandra .

# git diff with no context lines
git diff -U0 ~/dotfiles/nixos/.

print "NixOS Rebuilding..."
sudo tmux new-session -d -s nixos-rebuild "nixos-rebuild switch --flake /home/bane/dotfiles/nixos/#main --option eval-cache false &> output.txt"

mut file_ready = false
while ($file_ready == false) {
    if (open output.txt | lines | any { |line| $line =~ "error" }) {
        print "----------------------"
        print "Config invalid, error:"
        print "----------------------"
        cat output.txt
        exit 1

    } else if (open output.txt | lines | any { |line| $line =~ "evaluating" }) {
        print "Evaluating..."

    } else if (open output.txt | lines | any { |line| $line =~ "building" }) {
        print "Config is fine."
        print "Building..."

    } else if (open output.txt | lines | any { |line| $line =~ "restarting sysinit" }) {
        print "Built."
        print "Restarting stuff..."
        $file_ready = true
        rm output.txt

    } else {
        print "Doing other stuff..."
        sleep 1sec
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
