#!/usr/bin/env bash
set -euo pipefail

log_info() {
  echo "[INFO] $1"
}

# DNF-Upgrade
update_dnf() {
  log_info "Starte DNF-Upgrade..."
  sudo dnf upgrade --refresh -y
  log_info "DNF-Upgrade abgeschlossen."
}

# Mise-Upgrade
update_mise() {
  log_info "Starte Mise-Upgrade..."
  # Upgrade nur der konfigurierten Versionen
  mise upgrade --bump || log_info "Keine Mise-Upgrades nötig."
  # Optional: für alle Tools auf die neueste Version
  # mise upgrade --bump || log_info "Alle Mise-Tools sind aktuell."
  log_info "Mise-Upgrade abgeschlossen."
}

# Flatpak-Upgrade
update_flatpak() {
  log_info "Starte Flatpak-Upgrade..."
  flatpak update -y
  log_info "Flatpak-Upgrade abgeschlossen."
}

# Hauptfunktion
main() {
  update_dnf
  update_mise
  update_flatpak
  log_info "Alle Updates abgeschlossen."
}

main
