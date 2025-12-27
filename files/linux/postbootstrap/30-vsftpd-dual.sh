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
log "Configuring vsftpd dual listeners (21 and 222)..."
# Ensure FTP pub exists and seed a test file
mkdir -p /var/ftp/pub
touch /var/ftp/pub/test.txt
chmod 644 /var/ftp/pub/test.txt
DEFAULT_VSFTPD="/etc/vsftpd.conf"
VSFTPD_DIR="/etc/vsftpd"
VSFTPD_21="${VSFTPD_DIR}/vsftpd-21.conf"
VSFTPD_222="${VSFTPD_DIR}/vsftpd-222.conf"
mkdir -p "$VSFTPD_DIR"
if [[ -f "$DEFAULT_VSFTPD" ]]; then
  cp -f "$DEFAULT_VSFTPD" "$VSFTPD_21"
  cp -f "$DEFAULT_VSFTPD" "$VSFTPD_222"
else
  cat >"$VSFTPD_21" <<EOF
listen=YES
anonymous_enable=YES
local_enable=YES
write_enable=YES
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
EOF
  cp -f "$VSFTPD_21" "$VSFTPD_222"
fi
for f in "$VSFTPD_21" "$VSFTPD_222"; do
  sed -i \
    -e 's/^\s*listen=.*/listen=YES/' \
    -e 's/^\s*listen_ipv6=.*/listen_ipv6=NO/' \
    -e 's/^\s*anonymous_enable=.*/anonymous_enable=YES/' \
    -e 's/^\s*local_enable=.*/local_enable=YES/' \
    -e 's/^\s*write_enable=.*/write_enable=YES/' \
    -e 's/^\s*pasv_enable=.*/pasv_enable=NO/' \
    -e 's/^\s*#\?\s*seccomp_sandbox=.*/seccomp_sandbox=NO/' \
    "$f" || true
  grep -q '^anonymous_enable=' "$f" || echo 'anonymous_enable=YES' >>"$f"
  grep -q '^local_enable=' "$f" || echo 'local_enable=YES' >>"$f"
  grep -q '^write_enable=' "$f" || echo 'write_enable=YES' >>"$f"
  grep -q '^pasv_enable=' "$f" || echo 'pasv_enable=NO' >>"$f"
done
# Bind address + port per instance
grep -q '^listen_address=' "$VSFTPD_21" && sed -i "s/^listen_address=.*/listen_address=${FTP_LISTEN_21_IP}/" "$VSFTPD_21" || echo "listen_address=${FTP_LISTEN_21_IP}" >>"$VSFTPD_21"
grep -q '^listen_port=' "$VSFTPD_21" && sed -i 's/^listen_port=.*/listen_port=21/' "$VSFTPD_21" || echo 'listen_port=21' >>"$VSFTPD_21"
grep -q '^listen_address=' "$VSFTPD_222" && sed -i "s/^listen_address=.*/listen_address=${FTP_LISTEN_222_IP}/" "$VSFTPD_222" || echo "listen_address=${FTP_LISTEN_222_IP}" >>"$VSFTPD_222"
grep -q '^listen_port=' "$VSFTPD_222" && sed -i 's/^listen_port=.*/listen_port=222/' "$VSFTPD_222" || echo 'listen_port=222' >>"$VSFTPD_222"
# systemd template unit
VSFTPD_UNIT="/etc/systemd/system/vsftpd@.service"
cat >"$VSFTPD_UNIT" <<'EOF'
[Unit]
Description=vsftpd instance (%i)
After=network.target
[Service]
Type=simple
ExecStart=/usr/sbin/vsftpd /etc/vsftpd/vsftpd-%i.conf
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl disable --now vsftpd || true
systemctl enable --now vsftpd@21
systemctl enable --now vsftpd@222
log "Done."
