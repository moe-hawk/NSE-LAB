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
log "Configuring Dovecot (imap/pop3) + Postfix (basic lab settings)..."
# Dovecot protocols
DOVECOT_CONF="/etc/dovecot/dovecot.conf"
if grep -q '^\s*#\?\s*protocols\s*=' "$DOVECOT_CONF"; then
  sed -i 's/^\s*#\?\s*protocols\s*=.*/protocols = imap pop3/' "$DOVECOT_CONF"
else
  echo 'protocols = imap pop3' >>"$DOVECOT_CONF"
fi
POSTFIX_MAIN="/etc/postfix/main.cf"
set_kv () {
  local key="$1" value="$2"
  if grep -qE "^\s*#?\s*${key}\s*=" "$POSTFIX_MAIN"; then
    sed -i -E "s|^\s*#?\s*${key}\s*=.*|${key} = ${value}|" "$POSTFIX_MAIN"
  else
    echo "${key} = ${value}" >>"$POSTFIX_MAIN"
  fi
}
set_kv "mydomain" "${LAB_DOMAIN}"
set_kv "myorigin" "\$mydomain"
set_kv "myhostname" "${LAB_HOSTNAME}"
set_kv "inet_interfaces" "all"
set_kv "mynetworks" "10.0.0.0/8, 127.0.0.0/8"
systemctl enable --now postfix
systemctl enable --now dovecot
systemctl restart postfix dovecot
log "Done."
