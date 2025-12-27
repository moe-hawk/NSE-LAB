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
log "Creating OpenSSL CA workspace in /root/ssl and adjusting openssl.cnf ..."
SSL_DIR="/root/ssl"
mkdir -p "${SSL_DIR}"/{certs,newcerts,requests,keys}
touch "${SSL_DIR}/index.txt"
echo "01" > "${SSL_DIR}/serial"
# Copy openssl.cnf
if [[ -f /etc/ssl/openssl.cnf ]]; then
  cp -f /etc/ssl/openssl.cnf "${SSL_DIR}/openssl.cnf"
elif [[ -f /usr/lib/ssl/openssl.cnf ]]; then
  cp -f /usr/lib/ssl/openssl.cnf "${SSL_DIR}/openssl.cnf"
else
  warn "Could not find openssl.cnf default; skipping copy."
fi
if [[ -f "${SSL_DIR}/openssl.cnf" ]]; then
  sed -i -E "s|^\s*dir\s*=.*|dir             = ${SSL_DIR}|" "${SSL_DIR}/openssl.cnf" || true
  awk -v desired="keyUsage = cRLSign, keyCertSign" '
    BEGIN{in=0; done=0}
    /^\s*\[\s*v3_ca\s*\]\s*$/ {in=1; print; next}
    /^\s*\[/ { if(in && !done){print desired; done=1} in=0; print; next}
    {
      if(in && $0 ~ /^\s*#?\s*keyUsage\s*=/){ if(!done){print desired; done=1} next }
      print
    }
    END{ if(in && !done){print desired} }
  ' "${SSL_DIR}/openssl.cnf" > "${SSL_DIR}/openssl.cnf.tmp" && mv "${SSL_DIR}/openssl.cnf.tmp" "${SSL_DIR}/openssl.cnf"
fi
log "Done."
