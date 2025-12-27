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
log "Downloading EICAR test file into /var/ftp/pub (best effort)..."
mkdir -p /var/ftp/pub
if curl -fsSL -o /var/ftp/pub/eicar.com "https://secure.eicar.org/eicar.com"; then
  :
elif curl -fsSL -o /var/ftp/pub/eicar.com "https://www.eicar.org/download/eicar.com"; then
  :
else
  warn "Could not download EICAR file (network blocked). Place it manually into /var/ftp/pub if needed."
fi
chmod 644 /var/ftp/pub/eicar.com 2>/dev/null || true
log "Done."
