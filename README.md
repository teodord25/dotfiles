# dotfiles

NixOS system config + app configs for two hosts:

| host     | machine                          | user     |
|----------|----------------------------------|----------|
| `work`   | JetBrains laptop (Intel/Nvidia)  | `teodor` |
| `gaming` | desktop PC (AMD CPU + AMD GPU)   | `bane`   |

## Layout

- `nixos/hosts/<name>/` — per-host entrypoint + hardware config
- `nixos/modules/core/` — applied to every host
- `nixos/modules/profiles/` — opt-in features, picked per host
  (`gaming.nix` + `performance.nix` are gaming-host only)
- `nixos/modules/packages/` — package sets
- `config/` — app configs, stowed into `~/.config` (see `.stowrc`)
- `config/hypr/hosts/` — per-host Hyprland config; `setup/config.sh`
  links the right one to `~/.config/hypr/host.conf`
- `scripts/`, `services/`, `fonts/`, `wallpapers/` — what it says

## Setup

```sh
./setup.sh                      # stow configs, fonts, tmux, tridactyl
./scripts/sh/rebuild.sh gaming  # or: work
```

## Gaming host extras

- HDR toggle: `SUPER+U` (or `scripts/sh/hdr.sh on|off|toggle`);
  in-game HDR via Steam launch options:
  `gamescope --hdr-enabled -f -- %command%`
- `gamemoderun %command%` pins CPU governor + AMD GPU perf level
- `lact` for fan curves / power limits
