#!/usr/bin/env bash
set -euo pipefail

# PulseAudio/Sink-Auswahl wie microphone.sh - grüne Icons links, dynamische Breite
mapfile -t sinks < <(wpctl status | sed -n '/^Audio$/,/^Video$/p' | sed -n '/Sinks:/,/Sources:/p' | grep -E '[0-9]+\.' | sed -E 's/^[^0-9*]*//' | sed 's/[[:space:]]*\[vol.*//')

[[ ${#sinks[@]} -eq 0 ]] && { notify-send -a waybar -i audio-volume-high "Lautsprecher" "Keine Senken gefunden"; exit 1; }

labels=()
ids=()
icons=()
for line in "${sinks[@]}"; do
  if [[ "$line" =~ ^\ *\*\ *([0-9]+)\.[[:space:]]+(.*) ]]; then
    name="${BASH_REMATCH[2]}"
    name="${name%"${name##*[![:space:]]}"}"
    labels+=("$name")
    ids+=("${BASH_REMATCH[1]}")
    icons+=("$HOME/.config/rofi/icons/check-green.svg")
  elif [[ "$line" =~ ^\ *([0-9]+)\.[[:space:]]+(.*) ]]; then
    name="${BASH_REMATCH[2]}"
    name="${name%"${name##*[![:space:]]}"}"
    labels+=("$name")
    ids+=("${BASH_REMATCH[1]}")
    icons+=("$HOME/.config/rofi/icons/sink-inactive-green.svg")
  fi
done

maxlen=0
for l in "${labels[@]}"; do
  (( ${#l} > maxlen )) && maxlen=${#l}
done
em_width=$(awk -v m="$maxlen" 'BEGIN{ w=m*0.48+6; if(w<12) w=12; if(w>28) w=28; printf "%.0f", w }')

sel=$(for i in "${!labels[@]}"; do
  printf '%s\0icon\x1f%s\n' "${labels[$i]}" "${icons[$i]}"
done | rofi -dmenu -i -format i -config ~/.config/rofi/everforest.rasi -theme-str "window {width: ${em_width}em;}" -p "Lautsprecher") || exit
[[ -z "$sel" ]] && exit
[[ "$sel" =~ ^[0-9]+$ ]] || exit

wpctl set-default "${ids[$sel]}"
# Optional unmute nach Wechsel
# wpctl set-mute "@DEFAULT_AUDIO_SINK@" 0
name="${labels[$sel]}"
notify-send -a waybar -i audio-volume-high "Lautsprecher" "Standard: $name"
