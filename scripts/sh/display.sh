#!/usr/bin/env bash
# display.sh — monitor mode control for the gaming host. Replaces hdr.sh.
#
# Usage: display.sh [res|comp|desktop|cinema|status|reprobe]   (default: status)
#
#   res      toggle resolution: 1080p480 <-> 4K240  (run after flipping the OSD)
#   comp     1920x1080@480, SDR 8-bit, VRR  — Deadlock / competitive
#   desktop  3840x2160@240, SDR 10-bit, VRR — daily driver
#   cinema   3840x2160@240, HDR 10-bit, VRR — E33 / film
#   status   what's actually applied right now
#   reprobe  force the kernel to re-read the monitor's EDID (needs root)
#
# The XG32UCWMG's dual-mode switch is in the monitor's OSD and rewrites the
# EDID. Hyprland caches the old mode list until it sees a hotplug event, so
# after flipping the OSD it often keeps driving the previous resolution.
# `res` handles that: it applies the target mode, verifies it landed, and
# escalates through a DPMS cycle and then a DRM reprobe if it didn't.
#
# There is deliberately no standalone HDR toggle: HDR is a property of the
# named modes, so every mode string lives in exactly one place below.
#
# Override the target monitor with DISPLAY_MONITOR=DP-1 if autodetect misses.

set -euo pipefail

# ── monitor selection ────────────────────────────────────────────────────────
# Never trust array order — on a two-output desk .[0] can be the Dell, and
# then apply_stubborn will fight a panel that has no 480Hz mode.

MODEL_MATCH="${DISPLAY_MODEL_MATCH:-XG32UCWMG}"

pick_monitor() {
    local by_model
    by_model="$(hyprctl -j monitors all |
        jq -r --arg m "$MODEL_MATCH" \
            'first(.[] | select((.model // "") | test($m; "i")) | .name) // empty')"
    if [[ -n "$by_model" ]]; then
        echo "$by_model"
        return 0
    fi
    echo "display.sh: no monitor matching '$MODEL_MATCH'; falling back to first output" >&2
    hyprctl -j monitors all | jq -r '.[0].name'
}

MON="${DISPLAY_MONITOR:-$(pick_monitor)}"
[[ -n "$MON" && "$MON" != "null" ]] || {
    echo "display.sh: could not determine a monitor (is Hyprland up?)" >&2
    exit 1
}

STATE="${XDG_RUNTIME_DIR:-/tmp}/hypr-display-mode"

# ── mode definitions ─────────────────────────────────────────────────────────
# tail = everything after "MONITOR,WxH@R,"
#
# comp is deliberately 8-bit: at 1080p480 forcing 10-bit can push the link into
# DSC for no visible gain in an SDR competitive title.

COMP_RES="1920x1080@480"
COMP_TAIL="auto,1,cm,srgb,vrr,2"

DESKTOP_RES="3840x2160@240"
DESKTOP_TAIL="auto,2,bitdepth,10,cm,srgb,vrr,0"

CINEMA_RES="3840x2160@240"
CINEMA_TAIL="auto,2,bitdepth,10,cm,hdr,sdrbrightness,1.2,sdrsaturation,0.98,vrr,2"

# ── helpers ──────────────────────────────────────────────────────────────────

mon_json() {
    hyprctl -j monitors all | jq -e --arg mon "$MON" '.[] | select(.name == $mon)'
}

note() {
    command -v notify-send >/dev/null && notify-send -t 2500 "display" "$*" || true
    echo "$*"
}

warn() {
    command -v notify-send >/dev/null && notify-send -u normal -t 4000 "display" "$*" || true
    echo "display.sh: $*" >&2
}

die() {
    command -v notify-send >/dev/null && notify-send -u critical "display" "$*" || true
    echo "display.sh: $*" >&2
    exit 1
}

list_modes() { mon_json | jq -r '.availableModes[]' | sort -u | tr '\n' ' '; }

have_mode() { # $1 = WxH@R — tolerant of fractional EDID refresh rates
    local w h r
    w="${1%%x*}"
    h="${1#*x}"; h="${h%%@*}"
    r="${1##*@}"
    mon_json | jq -e --argjson w "$w" --argjson h "$h" --argjson r "$r" '
        .availableModes[]
        | capture("^(?<w>\\d+)x(?<h>\\d+)@(?<r>[\\d.]+)")
        | select((.w|tonumber) == $w and (.h|tonumber) == $h)
        | select((((.r|tonumber) - $r) | fabs) < 1.5)
    ' >/dev/null 2>&1
}

active_wh() { mon_json | jq -r '"\(.width)x\(.height)"'; }
active_res() { mon_json | jq -r '"\(.width)x\(.height)@\(.refreshRate | round)"'; }

# find the DRM connector sysfs node for this output, e.g. /sys/class/drm/card1-DP-1
connector_path() {
    local p
    for p in /sys/class/drm/card*-"${MON}"; do
        [[ -e "$p/status" ]] && { echo "$p"; return 0; }
    done
    return 1
}

do_reprobe() {
    local conn
    conn="$(connector_path)" || return 1
    # forces the kernel to re-read the EDID and emit a hotplug uevent
    if [[ -w "$conn/status" ]]; then
        echo detect >"$conn/status"
    else
        # needs a NOPASSWD sudoers rule, otherwise this rung is unreachable
        sudo -n sh -c "echo detect > '$conn/status'" 2>/dev/null || return 1
    fi
    sleep 1
    return 0
}

set_mode() { # $1 = WxH@R, $2 = tail  — no guard, just do it
    hyprctl keyword monitor "$MON,$1,$2" >/dev/null
    sleep 0.4
}

# apply a mode and escalate until the active resolution actually matches
apply_stubborn() { # $1 = label, $2 = WxH@R, $3 = tail
    local want_wh="${2%@*}"

    have_mode "$2" || warn "$MON isn't advertising $2 yet — trying anyway.
Advertised: $(list_modes)"

    set_mode "$2" "$3"
    [[ "$(active_wh)" == "$want_wh" ]] && { echo "$1" >"$STATE"; note "$1 — $(active_res)"; return; }

    # 1st escalation: DPMS cycle, which forces a fresh modeset
    warn "stale mode list — cycling DPMS"
    hyprctl dispatch dpms off "$MON" >/dev/null || true
    sleep 1
    hyprctl dispatch dpms on "$MON" >/dev/null || true
    sleep 1
    set_mode "$2" "$3"
    [[ "$(active_wh)" == "$want_wh" ]] && { echo "$1" >"$STATE"; note "$1 — $(active_res)"; return; }

    # 2nd escalation: force the kernel to re-read the EDID
    warn "still stale — forcing DRM reprobe"
    if do_reprobe; then
        set_mode "$2" "$3"
        [[ "$(active_wh)" == "$want_wh" ]] && { echo "$1" >"$STATE"; note "$1 — $(active_res)"; return; }
    fi

    die "could not reach $2. Active: $(active_res)
Advertised: $(list_modes)
Try: sudo sh -c 'echo detect > $(connector_path 2>/dev/null || echo /sys/class/drm/cardN-$MON)/status'"
}

# ── main ─────────────────────────────────────────────────────────────────────

case "${1:-status}" in

res)
    # flip to whichever side we're not on; preserve the HDR choice on the 4K side
    if [[ "$(active_wh)" == "1920x1080" ]]; then
        if [[ "$(cat "$STATE" 2>/dev/null)" == "cinema" ]]; then
            apply_stubborn cinema "$CINEMA_RES" "$CINEMA_TAIL"
        else
            apply_stubborn desktop "$DESKTOP_RES" "$DESKTOP_TAIL"
        fi
    else
        apply_stubborn comp "$COMP_RES" "$COMP_TAIL"
    fi
    ;;

comp) apply_stubborn comp "$COMP_RES" "$COMP_TAIL" ;;
desktop) apply_stubborn desktop "$DESKTOP_RES" "$DESKTOP_TAIL" ;;
cinema) apply_stubborn cinema "$CINEMA_RES" "$CINEMA_TAIL" ;;

reprobe)
    do_reprobe && note "reprobed $MON — $(list_modes)" || die "reprobe failed (need root, or connector not found)"
    ;;

status)
    mon_json | jq -r '
        "monitor:    \(.name)  (\(.model))",
        "active:     \(.width)x\(.height)@\(.refreshRate)",
        "format:     \(.currentFormat)",
        "colour:     \(.colorManagementPreset)   sdrBrightness=\(.sdrBrightness)",
        "vrr:        \(.vrr)",
        "tearing:    \(.activelyTearing)   blockedBy: \(.tearingBlockedBy)",
        "scanout:    \(.directScanoutTo)   blockedBy: \(.directScanoutBlockedBy)",
        "hw cursors: \(.hardwareCursorsInUse)"
    '
    echo "last set:   $(cat "$STATE" 2>/dev/null || echo '(none)')"
    echo "connector:  $(connector_path 2>/dev/null || echo '(not found)')"
    echo "panel side: $(have_mode "$COMP_RES" && echo '1080p/480' || echo '4K/240')"
    ;;

*)
    echo "usage: display.sh [res|comp|desktop|cinema|status|reprobe]"
    exit 2
    ;;
esac
