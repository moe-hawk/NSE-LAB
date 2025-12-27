# Ubuntu 22 Post-Bootstrap Staged Service Setup

Run each stage individually (recommended while you validate), or run everything:

```bash
sudo bash run-all-stages.sh
```

## Stage files
1. `00-apt-install.sh` - installs packages for all services
2. `10-users.sh` - creates lab users (admin/student/FortiGate) with password `fortinet1`
3. `20-apache.sh` - Apache + lab pages (`fileupload.html`, `result.html`)
4. `30-vsftpd-dual.sh` - vsftpd dual listeners:
   - 10.200.1.254:21
   - 10.200.3.254:222
5. `40-rsyslog-remote.sh` - rsyslog UDP 514 + local6.* -> /var/log/fortinet
6. `50-mail-postfix-dovecot.sh` - Postfix + Dovecot (imap/pop3)
7. `60-snmp.sh` - enable snmpd + download MIBs (best effort)
8. `70-openssl-ca-workspace.sh` - /root/ssl CA workspace + openssl.cnf edits
9. `80-eicar.sh` - download EICAR file to /var/ftp/pub (best effort)
10. `99-verify.sh` - quick checks for listeners and service status

## Configure variables
Edit `00-common.env` if your IPs/hostname differ.
