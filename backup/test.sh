#!/bin/sh

# Test a single backup repo.
test()
{
  REPO="$1"

  rm -rf /tmp/test
  mkdir /tmp/test

  restic -r "$REPO" restore latest:"$HOME" --target /tmp/test

  diff -r --no-dereference "$HOME" /tmp/test \
    --exclude="BraveSoftware" \
    --exclude="application_state" \
    --exclude="recently-used.xbel" \
    --exclude="rhythmdb.xml" \
    --exclude="stream-properties" \
    --exclude="gvfs-metadata"
}

# A function for printing useful information.
BLUE="$(printf '\033[1;34m')"
RESET="$(printf '\033[0m')"

info()
{
  printf '%s==> %s %s\n' "$BLUE" "$*" "$RESET"
}

# Input the restic password only once, instead of once per operation.
. /etc/nixos/backup/input_restic_password.sh

info "Testing cloud backup"
test /run/media/wk/backup/cloud

info "Testing local backup"
test /run/media/wk/backup/local

info "Done"
unset RESTIC_PASSWORD
