#!/usr/bin/env bash
set -euo pipefail

# Farben
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m" # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

# --- DNF Update ---
log_info "Starte DNF-Update..."
if sudo dnf --setopt=plugins=1 upgrade --assumeyes; then
  log_info "DNF-Update abgeschlossen."
else
  log_error "DNF-Update fehlgeschlagen!"
fi

echo

# --- Mise Update ---
log_info "Starte Mise-Update..."
if mise upgrade; then
  log_info "Mise-Update abgeschlossen."
else
  log_warn "Mise-Update fehlgeschlagen oder keine Updates vorhanden."
fi

echo

# --- Flatpak Update ---
log_info "Starte Flatpak-Update..."
if flatpak update --assumeyes; then
  log_info "Flatpak-Update abgeschlossen."
else
  log_warn "Flatpak-Update fehlgeschlagen oder keine Updates vorhanden."
fi

echo
log_info "Alle Updates abgeschlossen."
