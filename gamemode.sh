#!/usr/bin/env bash
# gamemode.sh — game-mode toggle + closed-loop RAPL PL1 governor
#               for teodor-work-nixos (Dell Precision 5570, i9-12900H + A2000)
#
# v7 — adds two PRE-LOAD subsystems around the (unchanged) v6 controller:
#      a platform-profile fan pre-spin, and a display downshift. Both are
#      saved/restored like every other knob. The governor itself is untouched.
#
#   A. FAN PRE-SPIN (platform_profile).
#      The theory "blast the fans early so the heatsink soaks heat slower" is
#      wrong on this chassis — a ~200g fin stack buys single-digit seconds of
#      runway against a 100W load, then you are in steady state and the
#      starting temperature has no memory. The REAL effect is fan RAMP LAG:
#      Dell's curve reacts to measured temp with hysteresis over tens of
#      seconds, so at game launch the die spikes while the fans are still
#      spooling — and on this host a Tjmax touch costs a multi-second clamp to
#      min frequency. Pre-spinning removes that first spike. So: right
#      instinct, wrong mechanism, real benefit.
#
#      We do NOT pin fans at max permanently. Continuous max-RPM pulls dust
#      through the fin stack around the clock, and a clogged stack is the usual
#      reason these chassis degrade over a year. Profile goes to `performance`
#      on entry and back to whatever it was on exit.
#
#      ⚠ INTERACTION WITH THE GOVERNOR: on Dell, platform_profile is the EC's
#      Thermal Management mode, and it does not only move the fan curve — it
#      re-applies the EC's own power targets. Two consequences:
#        1. Order matters. The profile is set BEFORE any PL1 write, because a
#           profile change stomps PL1.
#        2. If EC-OVERRIDE warnings start firing constantly after this change
#           and never did before, THIS is why: the EC is now asserting its own
#           limits harder. Set PLATFORM_PROFILE_GAME="" to turn it off and
#           confirm. The diagnosis path already exists; nothing was added.
#
#   B. DISPLAY DOWNSHIFT (Hyprland).
#      Everything except DP-3 is disabled and DP-3 drops 4K120@1.5 -> 1080p240@1.
#      This is not cosmetic on a PRIME-offload setup: the compositor runs on the
#      iGPU, and the iGPU sits inside the SAME RAPL package budget the governor
#      is rationing. Driving 3840x2160@120 + 3840x2160@60 + 3840x2400@60 costs
#      package watts that are then unavailable to the P-cores. Dropping to one
#      1080p240 surface hands those watts back to the thing rendering frames.
#      The dGPU also stops scanning out a 4K surface it was downscaling anyway.
#
#      Restore is via `hyprctl reload` by default — it re-reads hyprland.conf,
#      which is the actual source of truth, so nothing can drift. Caveat: reload
#      also clears OTHER runtime `hyprctl keyword` changes, notably your
#      SUPER+M red screen shader. If that matters, set HYPR_RESTORE=keyword to
#      replay the exact monitor lines captured at entry instead; that path is
#      surgical but cannot restore per-monitor bitdepth/cm/vrr settings, since
#      `hyprctl -j monitors` does not report all of them faithfully. Pick your
#      lossy edge: reload loses runtime keywords, keyword loses exotic monitor
#      attributes. Your config currently uses none of the latter, so reload is
#      the default.
#
# ─── v6 (the controller — unchanged in v7) ───────────────────────────────────
#
# v6 — architectural rewrite. v5's knobs were not merely mistuned; two of its
#      mechanisms could only ever fail in one direction, so no amount of
#      retuning would have fixed it.
#
# What v5 got wrong (from the July Deadlock log, 3375s, 33722 samples):
#
#   1. THE GATE COULD NEVER CLOSE.
#      SLAM_EMA_GATE_MC=82000 sat 6C BELOW TARGET_MC=88000. The gate was meant
#      to distinguish a genuine heat-soak from a one-frame fight burst by asking
#      "is the FILTERED temp hot?" — but the inner loop's whole job was to park
#      the filtered temp at 88C, i.e. permanently above the gate. Measured: the
#      gate was open for 90.4% of normal-play samples. Every burst to Tjmax
#      therefore counted as a soak. A burst filter whose threshold is below the
#      setpoint is not a filter.
#
#   2. THE EMERGENCY CUT WAS BELOW PLAYABLE.
#      Each "soak" slammed PL1 to EMERGENCY_PL1_MW=22000. At 22W the 12900H runs
#      1700-1900MHz and the A2000 starves to 10W / ~600MHz waiting on draw calls.
#      Result: 19 episodes, 799s below 45fps, at 59-65C — CRATERS WITH 35C OF
#      THERMAL HEADROOM UNUSED. The cure was an order of magnitude worse than
#      the disease: a Tjmax touch costs a few frames, 22W costs 30 seconds.
#
#   3. THE CEILING WAS A ONE-WAY RATCHET.
#      Every soak incremented `bad` and zeroed `clean_s`. 3 bad events in 600s
#      dropped the ceiling 3W; raising it needed 120 CONSECUTIVE clean seconds.
#      With soaks arriving every ~90s, clean_s could never reach 120. So the
#      ceiling only ever descended — and save_ceiling persisted it across
#      launches. Measured: good-phase clocks decayed 3400 -> 3000MHz and median
#      fps 140 -> 89 over one session. That is the "it gets worse all evening".
#
#   4. EC-OVERRIDE DETECTION COULD DEADLOCK RECOVERY.
#      `(( slam_active && delta > 0 )) && delta=0` forbade RAISING power while
#      readback disagreed with our write by >500mW. If the platform merely
#      ROUNDS the value (many do), slam_active latches forever and the loop is
#      permanently barred from recovering. A detector must never be able to
#      cause the condition it detects.
#
# What v6 does instead:
#
#   ONE control loop. PD on an EMA-filtered package temp, output = PL1, hard-
#   clamped to [PL1_FLOOR_MW, PL1_MAX_MW]. That is the entire controller.
#
#   - NO emergency bypass to a starvation wattage. The fast path for a real
#     climb is a LARGER DOWNWARD SLEW for that tick, still clamped to the floor.
#     Instantaneous Tjmax is the firmware's job; it clock-throttles in
#     microseconds and you never see it in a frametime graph. The governor's
#     only job is the multi-second soak the EC handles badly.
#
#   - THE FLOOR IS PLAYABLE AND ABSOLUTE. PL1 never goes below it while gaming,
#     for any reason. If the chassis genuinely cannot cool the floor, that is a
#     hardware fact (dust/paste/ambient) and the script SAYS SO loudly rather
#     than silently starving you into 25fps. See the FLOOR-STUCK warning.
#
#   - LEARNING IS A HINT, NOT A CAP. v6 persists the observed equilibrium — a
#     slow average of where PL1 actually settles when the loop is in steady
#     state — and uses it as the STARTING PL1 next launch, so a fresh session
#     converges in seconds instead of soaking on the way down. It is never a
#     ceiling, so it structurally cannot ratchet you into starvation. The
#     learned value is discarded if TARGET_MC changed since it was written.
#
#   - CONFIG IS VALIDATED AT STARTUP. The v5 bug was a self-contradiction
#     between two constants. `selftest` (run automatically before `auto`/`on`)
#     asserts the invariants and refuses to run if they don't hold.
#
#   - THERMAL vs POWER-DELIVERY is now distinguished and reported. If clocks are
#     low while the die is COLD and our PL1 is high, the limit is not thermal —
#     it's the EC, the charger, or the battery, and no sysfs write will fix it.
#     v5 conflated this with heat-soak. v6 names it: STARVED (not thermal).
#
# Honesty / limits:
#   - If the BIOS locks RAPL (MSR PACKAGE_POWER_LIMIT lock bit), our writes
#     won't stick. Detected on the first write; falls back to a static frequency
#     cap and tells you.
#   - MangoHud reports cpu_power=0 on this host (every row of every log), so it
#     cannot corroborate PL1. Use `./gamemode.sh diag`, or:
#       sudo modprobe msr && sudo turbostat --interval 1
#   - This governs SUSTAINED power. It cannot fix a power-delivery cap. It will
#     now tell you when that's what you're looking at.
#
# Usage:
#   ./gamemode.sh auto           apply profile, then govern until Ctrl-C (restores on exit)
#   ./gamemode.sh run -- CMD…    apply + govern in background while CMD runs, revert after
#   ./gamemode.sh on|off         static profile on / restore (no governor)
#   ./gamemode.sh status         live cpufreq + GPU + temps + fans + PL1/2 + learned equilibrium
#   ./gamemode.sh diag           passive watcher, no writes; Ctrl-C to stop
#   ./gamemode.sh selftest       validate the config invariants and print the envelope
#   ./gamemode.sh reset          forget the learned equilibrium
#   ./gamemode.sh mon on|off     display downshift only (test it without touching power)
#
# Launch options: nvidia-offload mangohud %command% -vulkan   (no gamemoderun)
set -uo pipefail

# ─── static profile knobs ────────────────────────────────────────────────────
CPU_EPP=balance_performance
CPU_GOV=powersave       # correct for intel_pstate+HWP; EPP is the real lever
CPU_MIN_KHZ=1600000     # modest floor. NOTE: a binding RAPL PL1 overrides this,
                        #   which is exactly how we detect power starvation —
                        #   see STARVE_KHZ. Setting it high just hides the signal.
GPU_WATTS=35            # NOTE: the A2000's hw ceiling is 45W, not 35W — an
                        #   earlier comment here claimed 35W and was wrong. 35 is
                        #   kept deliberately: the GPU never throttled in either
                        #   log (max 75C, p99 34W), so the 10W it gives up costs
                        #   nothing and keeps that heat out of a chassis we are
                        #   already fighting. Raise it only after the CPU side
                        #   is settled.

# ─── fan pre-spin (platform_profile) ─────────────────────────────────────────
PLATFORM_PROFILE_GAME=performance
                        # first of these that the platform actually offers wins.
                        # Set to "" to disable this subsystem entirely — do that
                        # first if EC-OVERRIDE warnings appear after upgrading.
PLATFORM_PROFILE_FALLBACKS="balanced-performance balanced"
PRESPIN_S=10            # seconds to hold the profile before launching in `run`
                        #   mode. Sized to Dell's ramp, not to heatsink mass:
                        #   the fans need ~8-15s to reach commanded RPM. Longer
                        #   buys nothing, it just makes you wait.

# ─── display downshift (Hyprland) ────────────────────────────────────────────
MONITOR_SWITCH=1        # 0 disables the whole display subsystem
GAME_MONITOR=DP-3       # the one that stays on (ASUS XG32UCWMG)
GAME_MODE_LINE="1920x1080@240,0x0,1"
                        # appended to GAME_MONITOR. Matches the commented line
                        #   already in your hyprland.conf, so this is the config
                        #   you had, just applied on demand.
HYPR_RESTORE="${HYPR_RESTORE:-reload}"
                        # reload  = `hyprctl reload`, exact w.r.t. hyprland.conf,
                        #           but clears runtime keywords (red shader).
                        # keyword = replay captured monitor lines, keeps runtime
                        #           keywords, loses exotic monitor attributes.

# ─── controller knobs (integer math; temps in m°C, power in mW) ──────────────
TARGET_MC=85000         # setpoint for the FILTERED temp. Your chassis
                        #   demonstrably sustains 91-93C at 3400MHz / ~120fps
                        #   (good-phase median 88C, p90 92C). v5 aimed at 88 and
                        #   left headroom on the table for no benefit.
FASTCUT_OFFSET_MC=8000  # unfiltered temp >= Tjmax-this  -> use SLEW_DOWN_FAST
                        #   this tick instead of the PD output. Still floored.
INTERVAL=2              # seconds per control tick
EMA_DIV=8               # IIR strength; time constant ~= EMA_DIV*INTERVAL = 16s

# PD gains, in real units:
KP_NUM=2; KP_DEN=1      # 1C above setpoint      -> trim 2W this tick
KD_NUM=6; KD_DEN=1      # 1C/tick of rise        -> trim 3W this tick (the brake)
SLEW_UP_MW=1500         # max watts ADDED per tick   (gentle)
SLEW_DOWN_MW=4000       # max watts CUT per tick     (assertive)
SLEW_DOWN_FAST_MW=9000  # max watts CUT on a fast-cut tick (near Tjmax)
WRITE_QUANTUM_MW=500    # only touch sysfs when PL1 moved >= this

# PL1 envelope (mW).
PL1_FLOOR_MW=30000      # ABSOLUTE floor while gaming. Your own Tuesday logs put
                        #   ~28W at ~80C median / ~105fps, so 30W is inside
                        #   known-playable with margin. PL1 NEVER goes below
                        #   this — see the design note above. If you see
                        #   sustained FLOOR-STUCK warnings, the chassis can't
                        #   cool 30W that day; clean the fan before lowering it.
PL1_START_MW=31000      # opening PL1 if nothing has been learned yet
PL1_MAX_MW=33000        # fallback hw ceiling if RAPL doesn't expose max_power_uw
PL1_TOL_MW=2000         # readback within this of target counts as honoured.
                        #   Deliberately loose: platforms round. v5's 500mW was
                        #   tight enough that rounding latched slam_active.

# equilibrium learning (a HINT for next launch — never a cap):
EQ_BAND_MC=2000         # |ema - TARGET| <= this counts as "steady state"
EQ_DIV=64               # averaging strength for the learned equilibrium
EQ_MIN_SAMPLES=30       # don't persist until we've seen this many steady ticks
EQ_SAVE_EVERY_S=60      # how often to flush the learned value to disk

# diagnosis thresholds (reporting only — these never actuate anything):
STARVE_KHZ=2000000      # clocks below this...
STARVE_COOL_MC=15000    # ...while EMA is this far BELOW target = not thermal
FLOOR_STUCK_S=120       # this long at the floor and still over target = warn

# PL2 (short burst) — a fixed step above current PL1; 0 = leave as-is.
PL2_HEADROOM_MW=8000

# fallback static cap used ONLY if RAPL turns out to be BIOS-locked:
LOCKED_FALLBACK_CAP_KHZ=2800000

# profile restored by `off` if no saved state exists (work/idle baseline)
CPU_CAP_OFF_KHZ=3100000
CPU_EPP_OFF=power
CPU_GOV_OFF=powersave
# ─────────────────────────────────────────────────────────────────────────────

STATE="${XDG_RUNTIME_DIR:-/tmp}/gamemode.state"
LEARN_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/gamemode"
LEARN="$LEARN_DIR/equilibrium"
RAPL_BASE=/sys/class/powercap
RAPL=""            # resolved by find_rapl()
C_PL1=""; C_PL2=""  # resolved constraint indices (do NOT assume 0 and 1)

shopt -s nullglob
CPUS=(/sys/devices/system/cpu/cpu*/cpufreq)
shopt -u nullglob

w()   { local node=$1 val=$2 c
        for c in "${CPUS[@]}"; do echo "$val" | sudo tee "$c/$node" >/dev/null 2>&1 || true; done; }
rd()  { cat "${CPUS[0]}/$1" 2>/dev/null; }
gq()  { nvidia-smi --query-gpu="$1" --format=csv,noheader,nounits 2>/dev/null | head -1 | tr -d ' '; }
int() { local v=${1%.*}; echo "${v:-}"; }
fans(){ sensors 2>/dev/null | awk '/[Ff]an/ && /RPM/ {gsub(":",""); printf "%s=%s ", tolower($1), $2}'; }
ac_online(){ cat /sys/class/power_supply/AC*/online 2>/dev/null | head -1; }

# highest current clock across all cores — the honest "is the CPU being fed?"
# signal. cpu0 alone parks on an E-core and reads low for innocent reasons.
max_cur_khz() {
  local c v m=0
  for c in "${CPUS[@]}"; do
    v=$(cat "$c/scaling_cur_freq" 2>/dev/null) || continue
    [[ -n "$v" ]] && (( v > m )) && m=$v
  done
  echo "$m"
}

# ─── config validation ───────────────────────────────────────────────────────
# The v5 failure was a self-contradiction between two constants that each looked
# reasonable alone. Every invariant below is one that, if violated, produces a
# controller that cannot work no matter how the other knobs are set.
selftest() {
  local fail=0
  chk() { if eval "$1"; then printf '  ok    %s\n' "$2"; else printf '  FAIL  %s\n' "$2"; fail=1; fi; }
  echo "── selftest ──"
  chk '(( PL1_FLOOR_MW < PL1_START_MW ))'        "floor ($((PL1_FLOOR_MW/1000))W) < start ($((PL1_START_MW/1000))W)"
  chk '(( PL1_START_MW <= PL1_MAX_MW ))'         "start <= max ($((PL1_MAX_MW/1000))W)"
  chk '(( PL1_FLOOR_MW >= 28000 ))'              "floor >= 28W (below this the log shows unplayable 25-30fps)"
  chk '(( TARGET_MC < 100000 - FASTCUT_OFFSET_MC ))' "setpoint ($((TARGET_MC/1000))C) below fast-cut threshold"
  # FASTCUT_OFFSET_MC is an offset BELOW Tjmax, so a dropped zero moves the
  # fast-cut the WRONG way and nothing else in the config contradicts it. These
  # two bound it from both sides: too close to the setpoint and it fires on
  # every other tick (a permanent brake, not a guard); too close to Tjmax and
  # the EC's clamp has already fired by the time we react.
  chk '(( 100000 - FASTCUT_OFFSET_MC >= TARGET_MC + 4000 ))' \
      "fast-cut ($(( (100000-FASTCUT_OFFSET_MC)/1000 ))C) >= 4C above setpoint"
  chk '(( 100000 - FASTCUT_OFFSET_MC <= 95000 ))' \
      "fast-cut <= 95C (at 98C the EC clamp has already fired)"
  chk '(( TARGET_MC >= 80000 ))'                 "setpoint not absurdly conservative"
  chk '(( SLEW_DOWN_MW >= SLEW_UP_MW ))'         "cut faster than we recover"
  chk '(( SLEW_DOWN_FAST_MW >= SLEW_DOWN_MW ))'  "fast-cut is the fastest path down"
  chk '(( EQ_BAND_MC > 0 && EQ_DIV > 1 ))'       "equilibrium averaging is sane"
  chk '(( EMA_DIV >= 2 ))'                       "filter actually filters"
  chk '(( INTERVAL >= 1 ))'                      "tick interval >= 1s"
  chk '(( PL1_TOL_MW >= 1000 ))'                 "readback tolerance loose enough to survive platform rounding"
  # v7 invariants. Same rule as above: only things that make the feature
  # incapable of working, not things that are merely mistuned.
  chk '(( PRESPIN_S >= 0 && PRESPIN_S <= 60 ))'  "pre-spin ${PRESPIN_S}s is in [0,60] (fans reach RPM in ~8-15s; more is dead time)"
  chk '[[ "$HYPR_RESTORE" == reload || "$HYPR_RESTORE" == keyword ]]' \
      "HYPR_RESTORE=$HYPR_RESTORE is one of reload|keyword"
  if (( MONITOR_SWITCH )); then
    # A downshift we cannot undo is worse than no downshift: it strands you on
    # one monitor at the wrong resolution with no path back.
    chk '[[ -n "$GAME_MONITOR" && -n "$GAME_MODE_LINE" ]]' "game monitor + mode line both set"
    chk '[[ "$GAME_MODE_LINE" == *,*,* ]]'       "mode line looks like WxH@R,POS,SCALE"
    chk 'command -v hyprctl >/dev/null'          "hyprctl on PATH (needed to undo the downshift, not just apply it)"
    if [[ "$HYPR_RESTORE" == keyword ]]; then
      chk 'command -v jq >/dev/null'             "jq present (HYPR_RESTORE=keyword parses hyprctl -j)"
    fi
  fi
  echo "  ── envelope: PL1 in [$((PL1_FLOOR_MW/1000)), $((PL1_MAX_MW/1000))]W, setpoint $((TARGET_MC/1000))C,"
  echo "     filter tau ~$((EMA_DIV*INTERVAL))s, fast-cut at Tjmax-$((FASTCUT_OFFSET_MC/1000))C"
  echo "  ── note: v6 has no soak gate and no ceiling AIMD. Both were removable"
  echo "     because the floor is playable; there is nothing left to ratchet."
  (( fail )) && { echo "  selftest FAILED — refusing to run."; return 1; }
  echo "  selftest passed."
  return 0
}

# ─── RAPL plumbing ───────────────────────────────────────────────────────────
# Do not assume intel-rapl:0 / constraint_0. Find the package zone, then find
# the constraint actually NAMED long_term / short_term.
find_rapl() {
  local z n
  for z in "$RAPL_BASE"/intel-rapl:*; do
    n=$(cat "$z/name" 2>/dev/null)
    [[ "$n" == package-* || "$n" == package ]] || continue
    RAPL="$z"; break
  done
  [[ -n "$RAPL" ]] || return 1
  local i
  for i in 0 1 2 3; do
    n=$(cat "$RAPL/constraint_${i}_name" 2>/dev/null)
    [[ "$n" == long_term  ]] && C_PL1=$i
    [[ "$n" == short_term ]] && C_PL2=$i
  done
  [[ -n "$C_PL1" ]] || C_PL1=0
  [[ -n "$C_PL2" ]] || C_PL2=1
  [[ -e "$RAPL/constraint_${C_PL1}_power_limit_uw" ]]
}
pl_uw() { cat "$RAPL/constraint_${1}_power_limit_uw" 2>/dev/null; }
pl_mw() { local uw; uw=$(pl_uw "$1"); [[ -n "$uw" ]] && echo "$((uw/1000))" || echo ""; }
pl_w()  { local mw; mw=$(pl_mw "$1"); [[ -n "$mw" ]] && echo "$((mw/1000))" || echo "?"; }

pl1_hw_max_mw() {
  local uw; uw=$(cat "$RAPL/constraint_${C_PL1}_max_power_uw" 2>/dev/null)
  if [[ -n "$uw" && "$uw" -gt 0 ]]; then echo "$((uw/1000))"; else echo "$PL1_MAX_MW"; fi
}
# returns 0 if the write stuck, 1 if the platform overrode it, 2 if unreadable
pl1_write_mw() {
  local mw=$1 rb diff
  echo "$((mw*1000))" | sudo tee "$RAPL/constraint_${C_PL1}_power_limit_uw" >/dev/null 2>&1
  rb=$(pl_mw "$C_PL1"); [[ -z "$rb" ]] && return 2
  diff=$(( rb - mw )); (( diff<0 )) && diff=$(( -diff ))
  (( diff <= PL1_TOL_MW ))
}
pl2_write_mw() { echo "$(( $1*1000 ))" | sudo tee "$RAPL/constraint_${C_PL2}_power_limit_uw" >/dev/null 2>&1; }

# ─── temperature ─────────────────────────────────────────────────────────────
TEMP_NODE=""; TJMAX_MC=100000
find_temp_node() {
  local h crit
  for h in /sys/class/hwmon/hwmon*; do
    [[ "$(cat "$h/name" 2>/dev/null)" == coretemp ]] || continue
    [[ -r "$h/temp1_input" ]] || continue          # temp1 = "Package id 0" here
    TEMP_NODE="$h/temp1_input"
    crit=$(cat "$h/temp1_crit" 2>/dev/null || cat "$h/temp1_max" 2>/dev/null)
    [[ -n "$crit" && "$crit" -gt 0 ]] && TJMAX_MC=$crit
    return 0
  done
  return 1
}
pkg_temp_mc() { local t; t=$(cat "$TEMP_NODE" 2>/dev/null); echo "${t:-0}"; }

# ─── learned equilibrium (a starting hint, never a cap) ──────────────────────
load_equilibrium() {
  local v="" tgt="" hwmax; hwmax=$(pl1_hw_max_mw)
  (( hwmax > PL1_MAX_MW )) && hwmax=$PL1_MAX_MW
  if [[ -r "$LEARN" ]]; then
    v=$(sed -n 's/^EQ_MW=//p'     "$LEARN" 2>/dev/null | head -1)
    tgt=$(sed -n 's/^TARGET_MC=//p' "$LEARN" 2>/dev/null | head -1)
    # a value learned against a different setpoint is meaningless — drop it.
    [[ "$tgt" != "$TARGET_MC" ]] && v=""
  fi
  [[ -z "$v" ]] && v=$PL1_START_MW
  (( v > hwmax ))        && v=$hwmax
  (( v < PL1_FLOOR_MW )) && v=$PL1_FLOOR_MW
  echo "$v"
}
save_equilibrium() {
  mkdir -p "$LEARN_DIR" 2>/dev/null || true
  printf 'EQ_MW=%s\nTARGET_MC=%s\n# updated %s\n' "$1" "$TARGET_MC" "$(date -Is)" \
    > "$LEARN" 2>/dev/null || true
}

# ─── platform_profile (fan curve bias) ───────────────────────────────────────
# Two paths exist depending on kernel version: the newer per-device class node
# and the legacy firmware node. Probe both rather than assuming; on 6.14+ the
# firmware node is a compat shim that can disappear.
PP_NODE=""
find_platform_profile() {
  local p
  for p in /sys/class/platform-profile/platform-profile-*/profile \
           /sys/firmware/acpi/platform_profile; do
    [[ -r "$p" ]] && { PP_NODE="$p"; return 0; }
  done
  return 1
}
pp_choices() {
  [[ -n "$PP_NODE" ]] || return 1
  if [[ "$PP_NODE" == /sys/firmware/* ]]; then
    cat /sys/firmware/acpi/platform_profile_choices 2>/dev/null
  else
    cat "${PP_NODE%/profile}/choices" 2>/dev/null
  fi
}
pp_get() { cat "$PP_NODE" 2>/dev/null; }
pp_set() {
  local want=$1 rb
  echo "$want" | sudo tee "$PP_NODE" >/dev/null 2>&1
  rb=$(pp_get); [[ "$rb" == "$want" ]]
}
# pick the first requested profile the platform actually advertises.
pp_pick() {
  local avail c
  avail=" $(pp_choices) "
  for c in $PLATFORM_PROFILE_GAME $PLATFORM_PROFILE_FALLBACKS; do
    [[ "$avail" == *" $c "* ]] && { echo "$c"; return 0; }
  done
  return 1
}
apply_platform_profile() {
  [[ -n "$PLATFORM_PROFILE_GAME" ]] || return 0
  find_platform_profile || { echo "  fans: no platform_profile node — pre-spin unavailable on this kernel."; return 0; }
  local want; want=$(pp_pick) || {
    echo "  fans: none of '$PLATFORM_PROFILE_GAME $PLATFORM_PROFILE_FALLBACKS' offered (have: $(pp_choices)) — leaving as-is."
    return 0; }
  local cur; cur=$(pp_get)
  if [[ "$cur" == "$want" ]]; then
    echo "  fans: platform_profile already '$want'"
  elif pp_set "$want"; then
    echo "  fans: platform_profile $cur -> $want  (pre-spin; PL1 is written after this, since a profile change stomps it)"
  else
    echo "  ⚠  fans: platform_profile write to '$want' didn't stick (held '$(pp_get)')."
  fi
}
restore_platform_profile() {
  local saved=${1:-}
  [[ -n "$saved" ]] || return 0
  find_platform_profile || return 0
  [[ "$(pp_get)" == "$saved" ]] && return 0
  pp_set "$saved" && echo "  fans: platform_profile restored -> $saved" \
                  || echo "  ⚠  fans: couldn't restore platform_profile to '$saved'."
}

# ─── Hyprland display downshift ──────────────────────────────────────────────
# hyprctl must run as the SESSION user, never under sudo — it needs
# HYPRLAND_INSTANCE_SIGNATURE and the user's XDG_RUNTIME_DIR socket.
hypr_alive() { command -v hyprctl >/dev/null 2>&1 && hyprctl version >/dev/null 2>&1; }

# List monitor names, one per line.
# Do NOT grep '"name"' out of the JSON: each monitor object also contains nested
# activeWorkspace/specialWorkspace objects that have their own "name" key, so a
# naive grep returns workspace names ("1", "") as if they were outputs and you
# end up issuing `hyprctl keyword monitor 1,disable`. Use jq (structural), and
# fall back to the plain-text form, whose lines begin "Monitor <name> (ID n):".
hypr_monitor_names() {
  if command -v jq >/dev/null 2>&1; then
    hyprctl -j monitors all 2>/dev/null | jq -r '.[].name' 2>/dev/null && return 0
  fi
  hyprctl monitors all 2>/dev/null | sed -n 's/^Monitor \([^ ]*\) (ID .*/\1/p'
}

# capture current monitor lines in hyprland.conf syntax (for HYPR_RESTORE=keyword)
hypr_capture_monitors() {
  command -v jq >/dev/null 2>&1 || return 1
  hyprctl -j monitors all 2>/dev/null | jq -r '
    .[] |
    if (.disabled // false) then "\(.name),disable"
    else
      "\(.name),\(.width)x\(.height)@\((.refreshRate*100|round)/100),\(.x)x\(.y),\(.scale)"
      + (if ((.transform // 0) != 0) then ",transform,\(.transform)" else "" end)
    end' 2>/dev/null | paste -sd';' -
}

monitors_game() {
  (( MONITOR_SWITCH )) || return 0
  if ! hypr_alive; then
    echo "  display: no live Hyprland session — skipping downshift (this is not fatal)."
    return 0
  fi
  local names n applied=0
  names=$(hypr_monitor_names)
  [[ -z "$names" ]] && { echo "  ⚠  display: couldn't enumerate monitors — skipping."; return 0; }
  # Bring the keeper up FIRST. Disabling every other head before the survivor is
  # confirmed alive is how you end up with zero outputs and a session you can
  # only recover blind.
  if ! hyprctl keyword monitor "$GAME_MONITOR,$GAME_MODE_LINE" >/dev/null 2>&1; then
    echo "  ⚠  display: '$GAME_MONITOR,$GAME_MODE_LINE' was rejected — leaving all monitors alone."
    return 0
  fi
  for n in $names; do
    [[ "$n" == "$GAME_MONITOR" ]] && continue
    hyprctl keyword monitor "$n,disable" >/dev/null 2>&1 && applied=$(( applied + 1 ))
  done
  # NB: $applied counts every non-keeper head we asserted 'disable' on, including
  # any that were already off. Re-disabling is a no-op, so the loop is
  # idempotent; the number is "heads held off", not "heads newly turned off".
  echo "  display: $GAME_MONITOR -> $GAME_MODE_LINE, $applied other head(s) held off"
  echo "           (iGPU scanout load leaves the RAPL package budget the governor is rationing)"
}

monitors_restore() {
  (( MONITOR_SWITCH )) || return 0
  hypr_alive || return 0
  if [[ "$HYPR_RESTORE" == keyword && -n "${HYPR_MONS:-}" ]]; then
    local line
    # Re-enable everything first, THEN reapply disables, so we never pass
    # through a zero-output state.
    while IFS= read -r line; do
      [[ "$line" == *,disable ]] && continue
      hyprctl keyword monitor "$line" >/dev/null 2>&1
    done < <(tr ';' '\n' <<<"$HYPR_MONS")
    while IFS= read -r line; do
      [[ "$line" == *,disable ]] || continue
      hyprctl keyword monitor "$line" >/dev/null 2>&1
    done < <(tr ';' '\n' <<<"$HYPR_MONS")
    echo "  display: monitors replayed from captured state (runtime keywords kept)"
  else
    hyprctl reload >/dev/null 2>&1 \
      && echo "  display: hyprctl reload — monitors back per hyprland.conf (runtime keywords cleared)" \
      || echo "  ⚠  display: hyprctl reload failed; run it yourself to get your monitors back."
  fi
}

gpu_throttle() {
  nvidia-smi -q -d PERFORMANCE 2>/dev/null \
    | awk -F: '/Clocks Event Reasons/{f=1;next} f && /: *Active/ {gsub(/^ +| +$/,"",$1); printf "%s,",$1} f && /^$/{exit}' \
    | sed 's/,$//'
}
set_gpu_limit() {
  local want=$1 max
  max=$(int "$(gq power.max_limit)")
  if [[ -z "$max" ]]; then
    echo "  GPU: not visible (PRIME offload asleep) — will re-arm after launch in 'run' mode."
    return 0
  fi
  (( want > max )) && want=$max
  sudo nvidia-smi -pm 1 >/dev/null 2>&1 || true
  sudo nvidia-smi -pl "$want" >/dev/null 2>&1 \
    && echo "  GPU: power limit -> ${want}W (hw max ${max}W)" \
    || echo "  GPU: couldn't set ${want}W (card asleep?)."
}

save_state() {
  [[ -f "$STATE" ]] && return 0
  local pp="" mons=""
  find_platform_profile >/dev/null 2>&1 && pp=$(pp_get)
  if (( MONITOR_SWITCH )) && [[ "$HYPR_RESTORE" == keyword ]] && hypr_alive; then
    mons=$(hypr_capture_monitors) || mons=""
    [[ -z "$mons" ]] && echo "  ⚠  display: capture failed — falling back to 'reload' on restore."
  fi
  { echo "GOV=$(rd scaling_governor)"
    echo "EPP=$(rd energy_performance_preference)"
    echo "MIN=$(rd scaling_min_freq)"
    echo "MAX=$(rd scaling_max_freq)"
    echo "GPU=$(int "$(gq power.limit)")"
    echo "PL1_UW=$(pl_uw "$C_PL1")"
    echo "PL2_UW=$(pl_uw "$C_PL2")"
    echo "PP=$pp"
    echo "HYPR_MONS='$mons'"
  } > "$STATE"
}

apply_base_profile() {
  save_state
  # ORDER IS LOAD-BEARING: platform_profile first. On Dell it re-applies the
  # EC's own power targets, so setting it after a PL1 write silently undoes it.
  apply_platform_profile
  monitors_game
  w scaling_governor "$CPU_GOV"
  w energy_performance_preference "$CPU_EPP"
  w scaling_min_freq "$CPU_MIN_KHZ"
  # Uncap frequency: PL1 is the sole limiter, so a stale freq cap would mask it.
  w scaling_max_freq "$(cat "${CPUS[0]}/cpuinfo_max_freq" 2>/dev/null || echo "$CPU_CAP_OFF_KHZ")"
  set_gpu_limit "$GPU_WATTS"
  local f0; f0=$(fans)
  [[ "$f0" == *"=0 "* ]] && echo "  ⚠  A FAN READS 0 RPM ($f0) — fix that before trusting any of this."
  [[ "$(ac_online)" == 0 ]] && echo "  ⚠  ON BATTERY — the EC will power-cap regardless of PL1."
}

profile_on() {
  echo "── game mode ON (static) ──"
  apply_base_profile
  if find_rapl; then
    local hwmax; hwmax=$(pl1_hw_max_mw)
    (( hwmax > PL1_MAX_MW )) && hwmax=$PL1_MAX_MW
    local c; c=$(load_equilibrium)
    pl1_write_mw "$c" \
      && echo "  PL1: static -> $((c/1000))W (use 'auto' for the governor)" \
      || echo "  PL1: write didn't stick (RAPL may be BIOS-locked)."
    # `auto` bounds PL2; `on` did not, which left the SHORT-TERM limit at
    # whatever the platform defaults to. PL1 only governs a ~28s average, so an
    # unbounded PL2 lets a bursty workload sit near Tjmax regardless of PL1 —
    # and it made `on` and `auto` non-comparable, which defeats the whole point
    # of the static test. Mirror the governor exactly.
    if (( PL2_HEADROOM_MW > 0 )); then
      local p2=$(( c + PL2_HEADROOM_MW )); (( p2 > hwmax )) && p2=$hwmax
      pl2_write_mw "$p2" && echo "  PL2: static -> $((p2/1000))W"
    fi
  else
    echo "  PL1: no RAPL package zone — power control unavailable on this host."
  fi
}

profile_off() {
  echo "── game mode OFF (restoring) ──"
  find_rapl >/dev/null 2>&1 || true
  if [[ -f "$STATE" ]]; then
    # shellcheck disable=SC1090
    . "$STATE"
    w scaling_governor "${GOV:-$CPU_GOV_OFF}"
    w energy_performance_preference "${EPP:-$CPU_EPP_OFF}"
    w scaling_min_freq "${MIN:-$(cat "${CPUS[0]}/cpuinfo_min_freq" 2>/dev/null || echo 400000)}"
    w scaling_max_freq "${MAX:-$CPU_CAP_OFF_KHZ}"
    [[ -n "${GPU:-}" ]] && sudo nvidia-smi -pl "$GPU" >/dev/null 2>&1 || true
    if [[ -n "$RAPL" ]]; then
      [[ -n "${PL1_UW:-}" ]] && echo "$PL1_UW" | sudo tee "$RAPL/constraint_${C_PL1}_power_limit_uw" >/dev/null 2>&1 || true
      [[ -n "${PL2_UW:-}" ]] && echo "$PL2_UW" | sudo tee "$RAPL/constraint_${C_PL2}_power_limit_uw" >/dev/null 2>&1 || true
    fi
    restore_platform_profile "${PP:-}"
    monitors_restore
    echo "  restored: gov=${GOV:-?} epp=${EPP:-?} cap=$(( ${MAX:-0}/1000 ))MHz gpu=${GPU:-?}W pl1=$(( ${PL1_UW:-0}/1000000 ))W"
    rm -f "$STATE"
  else
    w scaling_min_freq "$(cat "${CPUS[0]}/cpuinfo_min_freq" 2>/dev/null || echo 400000)"
    w scaling_governor "$CPU_GOV_OFF"
    w energy_performance_preference "$CPU_EPP_OFF"
    w scaling_max_freq "$CPU_CAP_OFF_KHZ"
    local def; def=$(int "$(gq power.default_limit)")
    [[ -n "$def" ]] && sudo nvidia-smi -pl "$def" >/dev/null 2>&1 || true
    # No saved profile to return to, so we don't guess one — but monitors ALWAYS
    # get put back. A stranded single-1080p desktop is the one failure here that
    # you cannot fix with the machine you're looking at.
    HYPR_RESTORE=reload monitors_restore
    echo "  no saved state — restored work baseline (PL1 and platform_profile left as-is)."
  fi
}

locked_fallback() {
  echo "  ⚠  RAPL PL1 is not writable (BIOS lock?). Falling back to a static"
  echo "     $((LOCKED_FALLBACK_CAP_KHZ/1000))MHz frequency cap — the governor needs RAPL unlocked."
  echo "     Try: sudo modprobe msr; check BIOS for 'Package Power Limit' / CFG-lock,"
  echo "     or msr-tools to clear the lock."
  w scaling_max_freq "$LOCKED_FALLBACK_CAP_KHZ"
  echo "── holding static cap; Ctrl-C to restore ──"
  while :; do sleep "$INTERVAL"; done
}

# ─── the governor ────────────────────────────────────────────────────────────
governor_loop() {
  find_temp_node || { echo "auto: can't find coretemp hwmon — bailing."; return 1; }
  find_rapl      || { echo "auto: no RAPL package zone — bailing.";      return 1; }

  local hwmax; hwmax=$(pl1_hw_max_mw)
  (( hwmax > PL1_MAX_MW )) && hwmax=$PL1_MAX_MW
  local fastcut_mc=$(( TJMAX_MC - FASTCUT_OFFSET_MC ))
  local pl1; pl1=$(load_equilibrium)
  (( pl1 > hwmax )) && pl1=$hwmax

  if ! pl1_write_mw "$pl1"; then locked_fallback; return 0; fi
  local written=$pl1

  # IIR accumulator: acc holds ema*EMA_DIV. This form never freezes the way
  # `ema += (t-ema)/DIV` does once the difference drops below DIV.
  local t_mc; t_mc=$(pkg_temp_mc)
  local acc=$(( t_mc * EMA_DIV )) ema=$t_mc ema_prev=$t_mc
  local eq_acc=0 eq_n=0 eq_last_save=0
  local floor_since=0 tick=0 override_n=0 starve_n=0
  local start_s; start_s=$(date +%s)

  echo "── governor v6: PD-on-filtered-temp  setpoint=$((TARGET_MC/1000))C  Tjmax=$((TJMAX_MC/1000))C"
  echo "   PL1 envelope [$((PL1_FLOOR_MW/1000)),$((hwmax/1000))]W  start=$((pl1/1000))W (learned)  tau=$((EMA_DIV*INTERVAL))s"
  echo "   no soak gate, no ceiling ratchet — the floor is playable by construction ──"

  while :; do
    t_mc=$(pkg_temp_mc)
    local now; now=$(date +%s)
    local note="" warn=""

    # ---- filter, then PD on the FILTERED signal only -------------------------
    acc=$(( acc - acc / EMA_DIV + t_mc ))
    ema=$(( acc / EMA_DIV ))
    local d=$(( ema - ema_prev )); ema_prev=$ema
    local err=$(( ema - TARGET_MC ))                    # +ve = too hot
    local delta=$(( -(err * KP_NUM / KP_DEN) - (d * KD_NUM / KD_DEN) ))

    # fast path: an UNFILTERED excursion near Tjmax gets the big downward slew
    # for this tick. It does NOT get a special target — the floor still holds.
    local slew_down=$SLEW_DOWN_MW
    if (( t_mc >= fastcut_mc )); then
      slew_down=$SLEW_DOWN_FAST_MW
      (( delta > 0 )) && delta=0
      note="fast-cut $((t_mc/1000))C"
    fi
    (( delta >  SLEW_UP_MW ))  && delta=$SLEW_UP_MW
    (( delta < -slew_down ))   && delta=$(( -slew_down ))

    pl1=$(( pl1 + delta ))
    (( pl1 > hwmax ))        && pl1=$hwmax
    (( pl1 < PL1_FLOOR_MW )) && pl1=$PL1_FLOOR_MW      # absolute, no exceptions

    # ---- write (quantized) --------------------------------------------------
    local diff=$(( pl1 - written )); (( diff<0 )) && diff=$(( -diff ))
    if (( diff >= WRITE_QUANTUM_MW )); then
      pl1_write_mw "$pl1" || warn+=" PL1-WRITE-REJECTED"
      written=$pl1
      if (( PL2_HEADROOM_MW > 0 )); then
        local pl2=$(( pl1 + PL2_HEADROOM_MW )); (( pl2 > hwmax )) && pl2=$hwmax
        pl2_write_mw "$pl2" || true
      fi
    fi

    # ---- diagnosis (reporting only; never actuates) -------------------------
    # (a) is the platform holding a different PL1 than we asked for?
    local pl1_cur; pl1_cur=$(pl_mw "$C_PL1")
    if [[ -n "$pl1_cur" ]]; then
      local off=$(( pl1_cur - pl1 )); (( off<0 )) && off=$(( -off ))
      if (( off > PL1_TOL_MW )); then
        override_n=$(( override_n + 1 ))
        warn+=" EC-OVERRIDE(want $((pl1/1000))W, holds $((pl1_cur/1000))W)"
      fi
    fi
    # (b) low clocks while COLD = not a thermal problem. v5 mistook this for
    #     heat-soak and cut power, which made it worse. Name it instead.
    local mk; mk=$(max_cur_khz)
    if (( mk > 0 && mk < STARVE_KHZ && ema < TARGET_MC - STARVE_COOL_MC )); then
      starve_n=$(( starve_n + 1 ))
      if (( starve_n == 5 )); then
        warn+=" STARVED-NOT-THERMAL($((mk/1000))MHz @ $((ema/1000))C, PL1=$((pl1/1000))W)"
        warn+=" [check: AC=$(ac_online), charger wattage, EC cap — no sysfs write fixes this]"
      fi
    else
      starve_n=0
    fi
    # (c) pinned at the floor and STILL over setpoint = genuine cooling deficit.
    if (( pl1 <= PL1_FLOOR_MW && err > 0 )); then
      (( floor_since == 0 )) && floor_since=$now
      if (( now - floor_since >= FLOOR_STUCK_S )); then
        warn+=" FLOOR-STUCK($((now-floor_since))s at $((PL1_FLOOR_MW/1000))W, still $((ema/1000))C)"
        warn+=" [chassis can't cool the floor today — dust/paste/ambient, not a tuning problem]"
        floor_since=$now
      fi
    else
      floor_since=0
    fi

    # ---- learn the equilibrium (hint for next launch, never a cap) ----------
    local aerr=$err; (( aerr<0 )) && aerr=$(( -aerr ))
    if (( aerr <= EQ_BAND_MC )); then
      if (( eq_n == 0 )); then eq_acc=$(( pl1 * EQ_DIV )); else
        eq_acc=$(( eq_acc - eq_acc / EQ_DIV + pl1 ))
      fi
      eq_n=$(( eq_n + 1 ))
      if (( eq_n >= EQ_MIN_SAMPLES && now - eq_last_save >= EQ_SAVE_EVERY_S )); then
        save_equilibrium "$(( eq_acc / EQ_DIV ))"; eq_last_save=$now
      fi
    fi

    # ---- output -------------------------------------------------------------
    if [[ -n "$warn" ]]; then
      printf '%(%H:%M:%S)T  ⚠%s\n' -1 "$warn"
    elif [[ -n "$note" ]]; then
      printf '%(%H:%M:%S)T  %s  ema=%d.%dC pl1=%dW\n' -1 "$note" \
        $((ema/1000)) $(( (ema%1000)/100 )) $((pl1/1000))
    elif (( tick % 15 == 0 )); then
      printf '%(%H:%M:%S)T  temp=%dC ema=%d.%dC pl1=%dW clk=%dMHz%s\n' -1 \
        $((t_mc/1000)) $((ema/1000)) $(( (ema%1000)/100 )) $((pl1/1000)) $(( mk/1000 )) \
        "$( (( eq_n >= EQ_MIN_SAMPLES )) && printf ' eq=%dW' $(( eq_acc/EQ_DIV/1000 )) )"
    fi
    tick=$(( tick + 1 ))
    sleep "$INTERVAL"
  done
}

auto_mode() {
  selftest || exit 1
  sudo -v || { echo "need sudo"; exit 1; }
  ( while kill -0 "$$" 2>/dev/null; do sudo -n true 2>/dev/null; sleep 50; done ) &
  local keep=$!
  trap 'echo; profile_off; kill "$keep" 2>/dev/null' EXIT INT TERM
  echo "── game mode AUTO ──"
  apply_base_profile
  # `auto` doesn't launch anything, so it can't dwell for you — but the pre-spin
  # only works if you actually wait. Say so rather than pretending it's automatic.
  [[ -n "$PLATFORM_PROFILE_GAME" ]] && (( PRESPIN_S > 0 )) && \
    echo "   pre-spin: give the fans ~${PRESPIN_S}s before you launch, or use 'run --' which waits for you."
  governor_loop
}

run_wrapped() {
  shift
  [[ $# -eq 0 ]] && { echo "run: nothing after --"; exit 1; }
  selftest || exit 1
  sudo -v || { echo "need sudo"; exit 1; }
  ( while kill -0 "$$" 2>/dev/null; do sudo -n true 2>/dev/null; sleep 50; done ) &
  local keep=$! gov=""
  trap 'profile_off; kill "$keep" "${gov:-}" 2>/dev/null' EXIT INT TERM
  echo "── game mode AUTO (wrapped) ──"
  apply_base_profile
  governor_loop & gov=$!
  # THE PRE-SPIN. This dwell is the entire point of the platform_profile change:
  # it lets the fans reach commanded RPM before the first frame, so the launch
  # spike doesn't touch Tjmax and eat a multi-second EC clamp. Skipped if the
  # profile subsystem is off, because then there's nothing to spin up for.
  if (( PRESPIN_S > 0 )) && [[ -n "$PLATFORM_PROFILE_GAME" ]]; then
    echo "── pre-spin: holding ${PRESPIN_S}s for fans to reach speed (fans: $(fans))"
    sleep "$PRESPIN_S"
    echo "   fans now: $(fans)"
  fi
  echo "── launching: $* ──"
  ( sleep 8; set_gpu_limit "$GPU_WATTS" >/dev/null 2>&1 ) &
  "$@"
}

status() {
  find_rapl >/dev/null 2>&1 || true
  echo "── cpufreq (cpu0) ──"
  echo "  driver  $(rd scaling_driver)"
  echo "  gov     $(rd scaling_governor)"
  echo "  epp     $(rd energy_performance_preference)"
  echo "  floor   $(( $(rd scaling_min_freq)/1000 ))MHz"
  echo "  cap     $(( $(rd scaling_max_freq)/1000 ))MHz"
  echo "  max cur $(( $(max_cur_khz)/1000 ))MHz  (highest across all cores)"
  if find_temp_node; then echo "  cputemp $(( $(pkg_temp_mc)/1000 ))C  (Tjmax $((TJMAX_MC/1000))C)"; fi
  if [[ -n "$RAPL" ]]; then
    echo "  PL1/PL2 $(pl_w "$C_PL1")W / $(pl_w "$C_PL2")W   ($RAPL, constraints $C_PL1/$C_PL2)"
  else
    echo "  PL1/PL2 no RAPL package zone found"
  fi
  if [[ -r "$LEARN" ]]; then
    echo "  learned $(( $(load_equilibrium)/1000 ))W equilibrium hint  ($LEARN)"
  else
    echo "  learned (none yet — run 'auto' to learn the equilibrium)"
  fi
  echo "  fans    $(fans)"
  if find_platform_profile; then
    echo "  profile $(pp_get)   (offered: $(pp_choices | tr '\n' ' '))"
  else
    echo "  profile no platform_profile node on this kernel"
  fi
  echo "  AC      $([[ $(ac_online) == 1 ]] && echo online || echo OFFLINE/unknown)"
  echo "── displays ──"
  if hypr_alive; then
    hyprctl -j monitors all 2>/dev/null | jq -r '
      .[] | if (.disabled // false) then "  \(.name)  disabled"
            else "  \(.name)  \(.width)x\(.height)@\((.refreshRate*100|round)/100)  scale \(.scale)" end' \
      2>/dev/null || echo "  (jq unavailable — run: hyprctl monitors all)"
  else
    echo "  no live Hyprland session"
  fi
  echo "── gpu (A2000) ──"
  if [[ -n "$(int "$(gq power.max_limit)")" ]]; then
    nvidia-smi --query-gpu=power.draw,power.limit,power.max_limit,temperature.gpu,utilization.gpu \
      --format=csv,noheader 2>/dev/null \
      | awk -F', ' '{printf "  draw %s | limit %s | hwmax %s | temp %s | util %s\n",$1,$2,$3,$4,$5}'
    local tr; tr=$(gpu_throttle)
    echo "  throttle reasons: ${tr:-none}"
  else
    echo "  asleep / not in use (PRIME offload) — launch a game to wake it."
  fi
}

diag() {
  echo "── diag: passive watch, no writes (Ctrl-C to stop) ──"
  find_temp_node; find_rapl >/dev/null 2>&1 || true
  local base_pl1 pl1 pl2 tr f ac mk t line last=""
  base_pl1=$(pl_w "$C_PL1")
  echo "  baseline PL1=${base_pl1}W  Tjmax=$((TJMAX_MC/1000))C"
  echo "  watching for: PL1 changes, GPU throttle, dead fans, battery,"
  echo "                and cold-but-slow (= power delivery, not heat)"
  while :; do
    pl1=$(pl_w "$C_PL1"); pl2=$(pl_w "$C_PL2"); tr=$(gpu_throttle)
    f=$(fans); ac=$(ac_online); mk=$(max_cur_khz); t=$(( $(pkg_temp_mc)/1000 ))
    line="temp=${t}C clk=$((mk/1000))MHz PL1=${pl1}W PL2=${pl2}W gpu=[${tr:-none}] ${f}ac=${ac:-?}"
    local alert=""
    [[ "$pl1" != "$base_pl1" ]]              && alert+=" PL1-CHANGED(${base_pl1}->${pl1}W)"
    [[ -n "$tr" && "$tr" != *Idle* ]]        && alert+=" GPU-THROTTLE(${tr})"
    [[ "$f" == *"=0 "* ]]                    && alert+=" FAN-DEAD"
    [[ "$ac" == 0 ]]                         && alert+=" ON-BATTERY"
    (( mk > 0 && mk < STARVE_KHZ && t < 75 )) && alert+=" COLD-AND-SLOW(not thermal)"
    if [[ -n "$alert" ]]; then
      printf '%(%H:%M:%S)T  ⚠%s   %s\n' -1 "$alert" "$line"
    elif [[ "$line" != "$last" ]]; then
      printf '%(%H:%M:%S)T  %s\n' -1 "$line"
    fi
    last="$line"
    sleep 1
  done
}

# display switch in isolation — no sudo, no power writes. Use this to confirm
# the downshift and (more importantly) the RESTORE work before you trust them
# inside a gaming session.
mon_only() {
  case "${1:-}" in
    on)  MONITOR_SWITCH=1; monitors_game ;;
    off) MONITOR_SWITCH=1
         if [[ "$HYPR_RESTORE" == keyword && -f "$STATE" ]]; then
           # shellcheck disable=SC1090
           . "$STATE"
         fi
         monitors_restore ;;
    *)   echo "usage: $0 mon {on|off}"; return 1 ;;
  esac
}

reset_learned() {
  [[ -f "$LEARN" ]] && { rm -f "$LEARN"; echo "forgot learned equilibrium ($LEARN)."; } \
                    || echo "no learned equilibrium to forget."
}

case "${1:-status}" in
  auto)     auto_mode ;;
  on)       shift || true; selftest && sudo -v && profile_on ;;
  off)      shift || true; sudo -v && profile_off ;;
  status)   status ;;
  diag)     diag ;;
  selftest) find_rapl >/dev/null 2>&1; find_temp_node >/dev/null 2>&1; selftest ;;
  reset)    reset_learned ;;
  mon)      shift; mon_only "${1:-}" ;;
  run)      run_wrapped "$@" ;;
  *) echo "usage: $0 {auto|on|off|status|diag|selftest|reset|mon on|off|run -- CMD...}"; exit 1 ;;
esac
