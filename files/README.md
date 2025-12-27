# Fortinet NSE4 Lab Bootstrap Scripts:

## Contents
- `linux/`
  - `bootstrap-linux-router.sh`
- `fortinet/`
  - `bootstrap-fgt-local.txt`
  - `bootstrap-fgt-remote.txt`
  - `bootstrap-fmg.txt`
  - `bootstrap-faz.txt`
- `windows/`
  - `bootstrap-local-windows-server.ps1`
  - `bootstrap-local-windows-server-stage2.ps1`
  - `bootstrap-remote-windows10.ps1`

## Notes
- You must still map VM NICs to the correct networks in your hypervisor.
- FMG/FAZ initial config restore + VM licensing remain manual steps.
- FortiGate `execute formatlogdisk` will reboot the unit; paste the remaining config after reboot.

