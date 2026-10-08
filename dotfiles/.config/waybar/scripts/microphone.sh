#!/usr/bin/env bash
set -euo pipefail

# Korrektes Parsen: '*' für aktives Gerät behalten (vorher ging es via rg -o verloren)
mapfile -t sources < <(wpctl status | sed -n '/^Audio$/,/^Video$/p' | sed -n '/Sources:/,/Filters:/p' | grep -E '[0-9]+\.' | grep -v "(V4L2)" | sed -E 's/^[^0-9*]*//' | sed 's/[[:space:]]*\[vol.*//')

[[ ${#sources[@]} -eq 0 ]] && { notify-send -a waybar -i audio-input-microphone "Mikrofon" "Keine Quellen gefunden"; exit 1; }

labels=()
ids=()
icons=()
for line in "${sources[@]}"; do
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
    icons+=("$HOME/.config/rofi/icons/mic-green.svg")
  fi
done

# Rofi-Breite dynamisch an längsten Text anpassen (statt fix 15% in everforest.rasi:23)
maxlen=0
for l in "${labels[@]}"; do
  (( ${#l} > maxlen )) && maxlen=${#l}
done
# + Icon (24px) + Padding + Prompt; 0.6em pro Zeichen bei JetBrainsMono 13, min 20em, max 45em
em_width=$(awk -v m="$maxlen" 'BEGIN{ w=m*0.48+6; if(w<12) w=12; if(w>28) w=28; printf "%.0f", w }')

sel=$(for i in "${!labels[@]}"; do
  printf '%s\0icon\x1f%s\n' "${labels[$i]}" "${icons[$i]}"
done | rofi -dmenu -i -format i -config ~/.config/rofi/everforest.rasi -theme-str "window {width: ${em_width}em;}" -p "Mikrofon") || exit
[[ "$sel" =~ ^[0-9]+$ ]] || exit

wpctl set-default "${ids[$sel]}"
wpctl set-mute "@DEFAULT_AUDIO_SOURCE@" 0
name="${labels[$sel]}"
notify-send -a waybar -i audio-input-microphone "Mikrofon" "Standard: $name"
