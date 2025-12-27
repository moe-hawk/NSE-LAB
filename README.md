# Fortinet NSE Lab Bootstrap

Fast, repeatable lab spin-up for NSE4 / NSE5 / NSE7 preparation

This repository provides staged bootstrap scripts that dramatically reduce the time required to build and rebuild Fortinet labs.

Instead of spending hours reconfiguring services, you can reset a full lab environment in minutes and focus on what actually matters: learning, testing, and troubleshooting.

Purpose:
  
    Fortinet labs are powerful—but repetitive to rebuild.
    
    This project solves that by:
      Automating Linux service setup used in Fortinet labs.
      Breaking configuration into safe, numbered stages.
      Allowing retry / skip / stop on failures.
  

Ideal for:

      - NSE4 fundamentals & policy testing
      - NSE5 FortiManager / FortiAnalyzer workflows
      - NSE7 logging, security fabric, and troubleshooting scenarios
      - Initial FortiGate / FMG / FAZ configs and module configs will be shared later



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


This Repo Includes:

Ubuntu 22 Post-Bootstrap Services
Mirrors services commonly used in Fortinet training labs:

    - Apache
    - DLP file upload test pages
    - vsftpd
        Dual listeners
          10.200.1.254:21
          10.200.3.254:222
    - rsyslog
      Remote syslog (UDP 514)
        local6.* → /var/log/fortinet
    - Postfix + Dovecot
    - SMTP / IMAP / POP3
    - SNMP
    - OpenSSL CA workspace
      /root/ssl layout for cert labs

How to Use: 
    
    1- Edit environment variables
        nano 00-common.env
      Update IPs / hostname if your lab differs.
      
    2️-  Run everything automatically
        sudo bash run-all-stages.sh
      
    3️-  Failure handling 
    
      If any stage fails, you’ll be prompted to:
      
        (r) Retry the failed stage
        
        (c) Continue to the next stage
        
        (s) Stop execution
      
      
    4- Verification:
      Final stage (99-verify.sh) checks:
      
        - Listening ports (FTP, HTTP, Syslog, Mail)
        
        - Service status
        
        - Key files and directories

Planned additions:

      FortiGate initial configs
      
      FortiManager device & policy package configs
      
      FortiAnalyzer log & report module configs
