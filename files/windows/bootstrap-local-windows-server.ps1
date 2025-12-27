#Requires -RunAsAdministrator
$ErrorActionPreference = "Stop"

# === EDIT NIC NAME IF NEEDED ===
# Use: Get-NetAdapter
$Lan3AdapterName = "Ethernet"     # NIC connected to LAN3 (10.0.1.0/24)
$DomainName      = "trainingAD.training.lab"
$SafeModePwd     = "P@ssw0rd-DSRM!"  # change if you want

Write-Host "[1/4] Setting IPv4 on LAN3..."
Get-NetIPAddress -InterfaceAlias $Lan3AdapterName -AddressFamily IPv4 -ErrorAction SilentlyContinue | Remove-NetIPAddress -Confirm:$false -ErrorAction SilentlyContinue
New-NetIPAddress -InterfaceAlias $Lan3AdapterName -IPAddress "10.0.1.10" -PrefixLength 24 -DefaultGateway "10.0.1.254"
Set-DnsClientServerAddress -InterfaceAlias $Lan3AdapterName -ServerAddresses "10.0.1.254"

Write-Host "[2/4] Disabling Windows Firewall (Domain/Private/Public)..."
Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled False

Write-Host "[3/4] Installing AD DS + DNS + IIS..."
Install-WindowsFeature AD-Domain-Services, DNS, Web-Server -IncludeManagementTools

Write-Host "[4/4] Promoting to Domain Controller (new forest)..."
$sec = ConvertTo-SecureString $SafeModePwd -AsPlainText -Force
Install-ADDSForest `
  -DomainName $DomainName `
  -SafeModeAdministratorPassword $sec `
  -InstallDns `
  -Force

# Server will reboot automatically.
# After reboot, run: bootstrap-local-windows-server-stage2.ps1
