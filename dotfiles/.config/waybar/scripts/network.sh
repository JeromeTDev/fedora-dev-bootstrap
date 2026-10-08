#!/usr/bin/env bash
set -euo pipefail

WIFI_IF="wlp5s0"

# Icons grün Gruvbox #b8bb26
ICON_CONNECTED="$HOME/.config/rofi/icons/check-green.svg"
ICON_KNOWN="$HOME/.config/rofi/icons/network-wireless-connected-symbolic-green.svg"
ICON_NEW="$HOME/.config/rofi/icons/bt-new-green.svg"

# Aktive SSID
active_ssid=$(nmcli -t -f IN-USE,SSID device wifi list ifname "$WIFI_IF" 2>/dev/null | awk -F: '$1=="*"{print $2; exit}')

# Beim Öffnen nach neuen Netzen suchen (wie Bluetooth)
nmcli device wifi rescan ifname "$WIFI_IF" >/dev/null 2>&1 &
sleep 3

# Sammle WLANs: deduplizieren nach SSID, stärkstes Signal behalten
declare -A sig_map sec_map use_map

while IFS= read -r line; do
  # Format IN-USE:SSID:SIGNAL:SECURITY, SSID kann : enthalten? nmcli escaped : als \:
  # Wir nutzen : als Trenner, aber SSID : wird zu \: -> nicht perfekt, aber selten
  # Besser direkt parsen mit awk -F:
  IFS=: read -r inuse ssid signal security <<< "$line"
  # Falls SSID leer (hidden)
  [[ -z "$ssid" ]] && ssid="<hidden>"
  # Deduplizieren
  if [[ -z "${sig_map[$ssid]+x}" ]] || (( signal > sig_map[$ssid] )); then
    sig_map["$ssid"]="$signal"
    sec_map["$ssid"]="$security"
    use_map["$ssid"]="$inuse"
  fi
done < <(nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY device wifi list ifname "$WIFI_IF" --rescan no 2>/dev/null | grep -vE '^:|^--' | grep -v '^$')

# Fallback wenn keine Liste (z.B. wifi aus)
if [[ ${#sig_map[@]} -eq 0 ]]; then
  if [[ "$(nmcli radio wifi 2>/dev/null)" == "disabled" ]]; then
    notify-send -a waybar -i network-wireless "WLAN" "WLAN deaktiviert - aktiviere..."
    nmcli radio wifi on
    sleep 2
    exec "$0"
  fi
  notify-send -a waybar -i network-wireless "WLAN" "Keine Netzwerke gefunden"
  exit 1
fi

labels=()
ssids=()
icons=()
# Sortiert nach Signalstärke absteigend
sorted_ssids=()
while IFS= read -r ssid; do
  sorted_ssids+=("$ssid")
done < <(for s in "${!sig_map[@]}"; do echo "${sig_map[$s]}:$s"; done | sort -nr | cut -d: -f2-)

for ssid in "${sorted_ssids[@]}"; do
  ssids+=("$ssid")
  labels+=("$ssid")
  inuse="${use_map[$ssid]}"
  sec="${sec_map[$ssid]}"
  if [[ "$inuse" == "*" ]]; then
    icons+=("$ICON_CONNECTED")
  elif nmcli connection show 2>/dev/null | rg -q "^$ssid[[:space:]]"; then
    icons+=("$ICON_KNOWN")
  else
    # Neu: plus, bei verschlüsselt trotzdem plus (grün)
    icons+=("$ICON_NEW")
  fi
done

# Breite dynamisch
maxlen=0
for l in "${labels[@]}"; do
  (( ${#l} > maxlen )) && maxlen=${#l}
done
em_width=$(awk -v m="$maxlen" 'BEGIN{ w=m*0.48+6; if(w<12) w=12; if(w>28) w=28; printf "%.0f", w }')

sel=$(for i in "${!labels[@]}"; do
  printf '%s\0icon\x1f%s\n' "${labels[$i]}" "${icons[$i]}"
done | rofi -dmenu -i -format i -config ~/.config/rofi/everforest.rasi -theme-str "window {width: ${em_width}em;}" -p "WLAN") || exit
[[ -z "$sel" ]] && exit
[[ "$sel" =~ ^[0-9]+$ ]] || exit

chosen="${ssids[$sel]}"
sec="${sec_map[$chosen]}"

if [[ "${use_map[$chosen]}" == "*" ]]; then
  notify-send -a waybar -i network-wireless "WLAN" "Bereits verbunden: $chosen"
  exit 0
fi

# Bekanntes Netz -> direkt verbinden
if nmcli connection show 2>/dev/null | rg -q "^$chosen[[:space:]]"; then
  if nmcli connection up id "$chosen" 2>&1 | rg -q "successfully"; then
    notify-send -a waybar -i network-wireless "WLAN" "Verbunden: $chosen"
  else
    # Fallback device connect
    nmcli device wifi connect "$chosen" 2>&1 | head -n 1 | xargs -I{} notify-send -a waybar -i network-wireless "WLAN" "{}"
  fi
else
  # Neues Netz - Passwort falls nötig
  if [[ -n "$sec" && "$sec" != "--" && "$sec" != "" ]]; then
    pass=$(rofi -dmenu -password -config ~/.config/rofi/everforest.rasi -p "Passwort für $chosen" -theme-str "window {width: 30em;}") || exit
    [[ -z "$pass" ]] && exit
    if nmcli device wifi connect "$chosen" password "$pass" 2>&1 | rg -q "successfully"; then
      notify-send -a waybar -i network-wireless "WLAN" "Verbunden: $chosen"
    else
      notify-send -a waybar -i network-wireless "WLAN" "Verbindung fehlgeschlagen: $chosen"
    fi
  else
    # Offenes Netz
    nmcli device wifi connect "$chosen" 2>&1 | head -n 1 | xargs -I{} notify-send -a waybar -i network-wireless "WLAN" "{}"
  fi
fi
