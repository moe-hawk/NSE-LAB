#Requires -RunAsAdministrator
$ErrorActionPreference = "Stop"
Import-Module ActiveDirectory

$OUName = "Training"
$OUPath = "DC=trainingAD,DC=training,DC=lab"

Write-Host "[1/5] Creating Users container accounts (student, ADadmin)..."
$studentPwd = ConvertTo-SecureString "password" -AsPlainText -Force
New-ADUser -Name "student" -SamAccountName "student" -AccountPassword $studentPwd -Enabled $true -PasswordNeverExpires $true -ChangePasswordAtLogon $false

$adadminPwd = ConvertTo-SecureString "Training!" -AsPlainText -Force
New-ADUser -Name "ADadmin" -SamAccountName "ADadmin" -AccountPassword $adadminPwd -Enabled $true -PasswordNeverExpires $true -ChangePasswordAtLogon $false

Write-Host "[2/5] Creating OU 'Training' and users (aduser1, aduser2, FAZadmin)..."
New-ADOrganizationalUnit -Name $OUName -Path $OUPath -ProtectedFromAccidentalDeletion $false -ErrorAction SilentlyContinue
$TrainingOU = "OU=$OUName,$OUPath"

$uPwd = ConvertTo-SecureString "Training!" -AsPlainText -Force
"aduser1","aduser2","FAZadmin" | ForEach-Object {
  New-ADUser -Name $_ -SamAccountName $_ -Path $TrainingOU -AccountPassword $uPwd -Enabled $true -PasswordNeverExpires $true -ChangePasswordAtLogon $false
}

Write-Host "[3/5] Creating group AD-users and adding aduser1/aduser2..."
New-ADGroup -Name "AD-users" -SamAccountName "AD-users" -GroupCategory Security -GroupScope Global -Path $TrainingOU -ErrorAction SilentlyContinue
Add-ADGroupMember -Identity "AD-users" -Members "aduser1","aduser2" -ErrorAction SilentlyContinue

Write-Host "[4/5] Enabling RDP and allowing 'student' in Remote Desktop Users..."
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -ErrorAction SilentlyContinue
Add-LocalGroupMember -Group "Remote Desktop Users" -Member "trainingAD\student" -ErrorAction SilentlyContinue

Write-Host "[5/5] Done."
