#!/usr/bin/env nu

def main [type: string] {
    let datetime = date now | format date "%Y-%m-%d-%H-%m-%S"
    let filename = "/home/bane/Pictures/" + $"($datetime).png"

    if $type == "p" {
        grimblast --freeze copysave area $filename
    } else if $type == "m" {
        grimblast --freeze copysave screen $filename
    } else {
        print "Usage: screenshot [p|m]"
    }
}
