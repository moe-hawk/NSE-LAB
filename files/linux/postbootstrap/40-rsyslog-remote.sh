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
log "Enabling rsyslog UDP 514 and routing local6.* to /var/log/fortinet ..."
cat >/etc/rsyslog.d/10-udp.conf <<'EOF'
# Enable UDP syslog reception (port 514)
module(load="imudp")
input(type="imudp" port="514")
EOF
cat >/etc/rsyslog.d/30-fortinet.conf <<'EOF'
local6.*    /var/log/fortinet
EOF
touch /var/log/fortinet
chmod 640 /var/log/fortinet
systemctl enable rsyslog
systemctl restart rsyslog
log "Done."
