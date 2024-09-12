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

    } else if (open output.txt | lines | any { |line| $line =~ "restarting sysinit" }) {
        print "Finishing."
        $file_ready = true
        rm output.txt

    } else {
        cat output.txt
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
