#!/usr/bin/env bash

main() {
    local type="$1"
    local datetime=$(date "+%Y-%m-%d-%H-%M-%S")
    local filename="$HOME/Pictures/Screenshots/${datetime}.png"

    mkdir -p "$HOME/Pictures/Screenshots"

    if [[ "$type" == "p" ]]; then
        grimblast --freeze copysave area "$filename"
    elif [[ "$type" == "m" ]]; then
        grimblast --freeze copysave screen "$filename"
    else
        echo "Usage: screenshot [p|m]"
    fi
}

main "$@"
