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
log "Verification: expected listeners include 21, 222, 80, 514/udp, 25, 110, 143"
echo "=== Listening sockets ==="
ss -lntu | egrep ':(21|222|80|514|25|110|143)\b' || true
echo -e "\n=== Service status ==="
systemctl --no-pager --full status apache2 vsftpd@21 vsftpd@222 rsyslog postfix dovecot snmpd || true
echo -e "\n=== Key files ==="
ls -l /var/www/html/fileupload.html /var/www/html/result.html 2>/dev/null || true
ls -l /var/log/fortinet 2>/dev/null || true
ls -l /root/ssl 2>/dev/null || true
log "Done."
