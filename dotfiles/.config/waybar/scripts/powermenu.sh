#!/usr/bin/env bash
set -euo pipefail

# Icons grün Gruvbox #b8bb26 links wie bei microphone/bluetooth/network
labels=("Lock" "Suspend" "Logout" "Reboot" "Shutdown")
icons=(
  "$HOME/.config/rofi/icons/power-lock-green.svg"
  "$HOME/.config/rofi/icons/power-suspend-green.svg"
  "$HOME/.config/rofi/icons/power-logout-green.svg"
  "$HOME/.config/rofi/icons/power-reboot-green.svg"
  "$HOME/.config/rofi/icons/power-shutdown-green.svg"
)

# Breite dynamisch an Textlänge (max 8 chars, daher klein, aber mit Icon + Padding)
maxlen=0
for l in "${labels[@]}"; do
  ((${#l} > maxlen)) && maxlen=${#l}
done
em_width=$(awk -v m="$maxlen" 'BEGIN{ w=m*0.48+6; if(w<12) w=12; if(w>28) w=28; printf "%.0f", w }')

choice_idx=$(for i in "${!labels[@]}"; do
  printf '%s\0icon\x1f%s\n' "${labels[$i]}" "${icons[$i]}"
done | rofi -dmenu -i -format i -config ~/.config/rofi/everforest.rasi -theme-str "window {width: ${em_width}em;}" -p "Power") || exit
[[ -z "$choice_idx" ]] && exit
[[ "$choice_idx" =~ ^[0-9]+$ ]] || exit

choice="${labels[$choice_idx]}"

confirm() {
  local prompt="$1"
  local ans
  ans=$(printf "Nein\nJa" | rofi -dmenu -i -config ~/.config/rofi/everforest.rasi -theme-str "window {width: 18em;}" -p "$prompt") || return 1
  [[ "$ans" == "Ja" ]]
}

# Brave sauber beenden. Ohne das stirbt der Browser beim Reboot per SIGKILL
# (logind KillUserProcesses=no) und schreibt seine Session-Cookies nie auf Platte.
quit_brave() {
  pgrep -x brave >/dev/null || return 0
  pkill -TERM -x brave
  for _ in $(seq 100); do
    pgrep -x brave >/dev/null || return 0
    sleep 0.1
  done
  pkill -KILL -x brave 2>/dev/null || true
}

case "$choice" in
Lock)
  swaylock
  ;;
Suspend)
  systemctl suspend
  ;;
Logout)
  if confirm "Abmelden?"; then
    quit_brave
    swaymsg exit
  fi
  ;;
Reboot)
  if confirm "Neustarten?"; then
    quit_brave
    systemctl reboot
  fi
  ;;
Shutdown)
  if confirm "Ausschalten?"; then
    quit_brave
    systemctl poweroff
  fi
  ;;
esac
