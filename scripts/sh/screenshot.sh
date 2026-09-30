#!/usr/bin/env bash

main() {
    local type="$1"
    local datetime
    datetime=$(date "+%Y-%m-%d-%H-%M-%S")
    local filename="$HOME/Pictures/Screenshots/${datetime}.png"

    mkdir -p "$HOME/Pictures/Screenshots"

    annotate() {
        satty --filename - \
              --output-filename "$filename" \
              --copy-command wl-copy \
              --early-exit
    }

    case "$type" in
        p)  grimblast --freeze copysave area "$filename" ;;
        m)  grimblast --freeze copysave screen "$filename" ;;
        pa) grimblast --freeze save area - | annotate ;;
        ma) grimblast --freeze save screen - | annotate ;;
        *)  echo "Usage: screenshot [p|m|pa|ma]" ;;
    esac
}

main "$@"
