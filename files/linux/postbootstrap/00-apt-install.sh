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
log "Installing required packages for all services..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
# postfix prompts; pre-seed minimal answers
echo "postfix postfix/main_mailer_type select Internet Site" | debconf-set-selections || true
echo "postfix postfix/mailname string ${LAB_HOSTNAME}" | debconf-set-selections || true
apt-get install -y \
  apache2 \
  vsftpd \
  rsyslog \
  postfix \
  dovecot-core dovecot-imapd dovecot-pop3d \
  snmp snmpd snmp-mibs-downloader \
  openssl \
  curl \
  net-tools
log "Done."
