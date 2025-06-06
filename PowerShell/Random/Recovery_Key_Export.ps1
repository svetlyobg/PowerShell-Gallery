# Get hostname
$Hostname = $env:COMPUTERNAME

# Get BitLocker info
$BitLockerInfo = Get-BitLockerVolume -MountPoint "C"
$KeyProtector = $BitLockerInfo.KeyProtector | Where-Object { $_.KeyProtectorType -eq 'RecoveryPassword' }

# Sanity check
if (-not $KeyProtector) {
    Write-Error "No RecoveryPassword protector found on C: drive."
    exit
}

# Extract details
$DeviceID = $KeyProtector.KeyProtectorId
$RecoveryKey = $KeyProtector.RecoveryPassword
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$OutFile = Join-Path $ScriptDir "$Hostname-$DeviceID`_BitLocker.txt"

# Compose output
$Output = @"
BitLocker Recovery Key Export
-----------------------------
Hostname     : $Hostname
Device ID    : $DeviceID
Recovery Key : $RecoveryKey
Generated At : $Timestamp
"@

# Write to file
$Output | Out-File -FilePath $OutFile -Encoding UTF8 -Force

Write-Host "Recovery key saved to: $OutFile"
