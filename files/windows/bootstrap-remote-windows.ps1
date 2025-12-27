#Requires -RunAsAdministrator
$ErrorActionPreference = "Stop"

# === EDIT NIC NAME IF NEEDED ===
$Lan6AdapterName = "Ethernet"  # NIC connected to LAN6 (10.0.2.0/24)

Write-Host "[1/3] Setting IPv4 on LAN6..."
Get-NetIPAddress -InterfaceAlias $Lan6AdapterName -AddressFamily IPv4 -ErrorAction SilentlyContinue | Remove-NetIPAddress -Confirm:$false -ErrorAction SilentlyContinue
New-NetIPAddress -InterfaceAlias $Lan6AdapterName -IPAddress "10.0.2.10" -PrefixLength 24 -DefaultGateway "10.0.2.254"
Set-DnsClientServerAddress -InterfaceAlias $Lan6AdapterName -ServerAddresses "10.0.2.254"

Write-Host "[2/3] Disabling Windows Firewall (Domain/Private/Public)..."
Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled False

Write-Host "[3/3] Optional: install tooling via winget (if available)..."
if (Get-Command winget -ErrorAction SilentlyContinue) {
  winget install -e --id Mozilla.Firefox
  winget install -e --id PuTTY.PuTTY
  winget install -e --id WiresharkFoundation.Wireshark
  winget install -e --id Notepad++.Notepad++
} else {
  Write-Host "winget not found; install apps manually if needed."
}
