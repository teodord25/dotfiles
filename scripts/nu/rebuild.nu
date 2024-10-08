#!/usr/bin/env nu

let old_dir = $env.PWD
cd ~/dotfiles/

nvim .

# fmt
alejandra nixos/

# git diff with no context lines
git diff -U0 ~/dotfiles/.

print "NixOS Rebuilding..."
rm output.txt
touch output.txt
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
