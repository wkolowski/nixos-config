#!/bin/sh
set -eu

# A function for printing useful information.
BLUE="$(printf '\033[1;34m')"
RESET="$(printf '\033[0m')"

info()
{
  printf '%s==> %s %s\n' "$BLUE" "$*" "$RESET"
}

# Input the restic password only once, instead of once per operation.
. /etc/nixos/backup/input_restic_password.sh

# Backup directories.
CLOUD="/run/media/wk/backup/cloud"
LOCAL="/run/media/wk/backup/local"

info "Cloud backup"
restic -r "$CLOUD" backup "$HOME" \
  --exclude "$HOME/Music" \
  --exclude "$HOME/.local/share/Trash" \
  --exclude "$HOME/Games" \
  --exclude "$HOME/Genes" \
  --exclude "$HOME/.cache" \
  --exclude "$HOME/.local/share/lutris" \
  --exclude "$HOME/.local/share/Steam" \
  --exclude "$HOME/.local/share/umu" \
  --exclude "$HOME/.local/share/uv"

info "Prune cloud backup: keep latest"
restic -r "$CLOUD" forget --keep-last 1 --prune

info "Checking integrity of cloud backup"
restic -r "$CLOUD" check --read-data

info "Local backup..."
restic -r "$LOCAL" backup "$HOME" \
  --exclude "$HOME/Games" \
  --exclude "$HOME/Genes" \
  --exclude "$HOME/.cache" \
  --exclude "$HOME/.local/share/lutris" \
  --exclude "$HOME/.local/share/Steam" \
  --exclude "$HOME/.local/share/umu" \
  --exclude "$HOME/.local/share/uv"

info "Prune local backup: keep latest"
restic -r "$LOCAL" forget --keep-last 1 --prune

info "Checking integrity of local backup"
restic -r "$LOCAL" check --read-data

info "Backup complete"
unset RESTIC_PASSWORD
