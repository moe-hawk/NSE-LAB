#!/usr/bin/env bash
set -euo pipefail
log() { echo -e "\n[+] $*"; }
warn() { echo -e "\n[!] $*" >&2; }
if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run as root (sudo)." >&2
  exit 1
fi
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/00-common.env"
log "Creating lab users and setting password..."
for u in "${LAB_USERS[@]}"; do
  if id -u "$u" >/dev/null 2>&1; then
    echo "User exists: $u"
  else
    adduser --disabled-password --gecos "" "$u"
  fi
  echo "${u}:${LAB_USER_PASSWORD}" | chpasswd
done
log "Done."
