#!/usr/bin/env bash

set -euo pipefail

power_on() {
  timeout 5 bluetoothctl power on >/dev/null
}

# `bluetoothctl power toggle` gibt es in bluez 5.87 nicht -> manuell umschalten
case "${1:-}" in
  on) power_on ;;
  off) bluetoothctl power off >/dev/null ;;
  toggle)
    if timeout 5 bluetoothctl show 2>/dev/null | rg -q 'Powered: yes'; then
      bluetoothctl power off >/dev/null
    else
      power_on
    fi
    ;;
  *) echo "Nutzung: $0 {on|off|toggle}" >&2; exit 1 ;;
esac