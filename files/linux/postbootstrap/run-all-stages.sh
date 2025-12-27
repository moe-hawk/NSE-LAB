#!/usr/bin/env bash
set -uo pipefail
# Orchestrator: runs all stages in order.
# If a stage fails, you will be prompted to:
#   (c) continue to next stage
#   (r) retry the failed stage
#   (s) stop the run
if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run as root (sudo)." >&2
  exit 1
fi
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
stages=(
  "00-apt-install.sh"
  "10-users.sh"
  "20-apache.sh"
  "30-vsftpd-dual.sh"
  "40-rsyslog-remote.sh"
  "50-mail-postfix-dovecot.sh"
  "60-snmp.sh"
  "70-openssl-ca-workspace.sh"
  "80-eicar.sh"
  "99-verify.sh"
)
run_stage() {
  local s="$1"
  echo -e "\n===== Running ${s} ====="
  bash "${SCRIPT_DIR}/${s}"
}
prompt_on_fail() {
  local s="$1" rc="$2"
  echo -e "\n[!] Stage FAILED: ${s} (exit code ${rc})"
  while true; do
    read -r -p "Choose: (r)etry, (c)ontinue, (s)top: " ans
    case "${ans,,}" in
      r|retry) return 2 ;;
      c|cont|continue) return 1 ;;
      s|stop|quit|q) return 0 ;;
      *) echo "Please enter r, c, or s." ;;
    esac
  done
}
for s in "${stages[@]}"; do
  while true; do
    set +e
    run_stage "$s"
    rc=$?
    set -e
    if [[ $rc -eq 0 ]]; then
      break
    fi
    prompt_on_fail "$s" "$rc"
    decision=$?
    if [[ $decision -eq 0 ]]; then
      echo "Stopping."
      exit $rc
    elif [[ $decision -eq 1 ]]; then
      echo "Continuing to next stage."
      break
    else
      echo "Retrying stage: $s"
      continue
    fi
  done
done
echo -e "\nAll stages completed (or skipped per your choices)."
