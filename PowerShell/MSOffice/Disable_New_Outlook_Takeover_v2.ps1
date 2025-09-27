# --------------------------------------------------------------------
# Script to disable and remove both "New Outlook" (webview version)
# and "Outlook for Windows" (formerly Mail & Calendar app)
# --------------------------------------------------------------------
# Author: You, with cleanup from ChatGPT
# Use: Run under user context for HKCU keys and elevated for Appx removal
# --------------------------------------------------------------------

Write-Host "==== Starting Cleanup of New Outlook and Outlook for Windows ===="

# ----------------------------
# Disable "New Outlook" (WebView/Reskinned version of OWA)
# ----------------------------

Write-Host "Disabling New Outlook toggle and migration options..."

# Create necessary registry paths if they don’t exist
New-Item -Path "HKCU:\Software\Policies\Microsoft\office\16.0\outlook\preferences" -Force | Out-Null
New-Item -Path "HKCU:\Software\Microsoft\Office\16.0\Outlook\Options\General" -Force | Out-Null

# Disable auto migration to New Outlook
Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\office\16.0\outlook\preferences" -Name "NewOutlookMigrationUserSetting" -Value 0 -Type DWord -Force
reg.exe ADD "HKCU\Software\Microsoft\Office\16.0\Outlook\Options\General" /v DoNewOutlookAutoMigration /t REG_DWORD /d 0 /f /reg:64

# Hide the toggle to switch to New Outlook
reg.exe ADD "HKCU\Software\Microsoft\Office\16.0\Outlook\Options\General" /v HideNewOutlookToggle /t REG_DWORD /d 1 /f /reg:64

# Prevent retry prompt for New Outlook migration
reg.exe ADD "HKCU\Software\Microsoft\Office\16.0\Outlook\Options\General" /v NewOutlookAutoMigrationRetryIntervals /t REG_DWORD /d 0 /f /reg:64

# ----------------------------
# Remove "Outlook for Windows" (Mail & Calendar replacement)
# ----------------------------

Write-Host "Removing 'Outlook for Windows' (formerly Mail & Calendar app)..."

# Attempt to remove provisioned package for Outlook for Windows
try {
    Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -like "*Microsoft.OutlookForWindows*"} | Remove-AppxProvisionedPackage -Online -ErrorAction Stop
    Write-Host "Provisioned package 'Microsoft.OutlookForWindows' removed."
} catch {
    Write-Warning "Could not remove provisioned package: Microsoft.OutlookForWindows"
}

# Attempt to remove installed package for all users
try {
    Get-AppxPackage -AllUsers | Where-Object {$_.Name -like "*Microsoft.OutlookForWindows*"} | Remove-AppxPackage -AllUsers -ErrorAction Stop
    Write-Host "Installed package 'Microsoft.OutlookForWindows' removed for all users."
} catch {
    Write-Warning "Could not remove installed package: Microsoft.OutlookForWindows"
}

# Also remove old Mail and Calendar (still installs under this name sometimes)
Write-Host "Removing legacy Mail and Calendar app..."

try {
    Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -like "*windowscommunicationsapps*"} | Remove-AppxProvisionedPackage -Online -ErrorAction Stop
    Write-Host "Provisioned package 'windowscommunicationsapps' removed."
} catch {
    Write-Warning "Could not remove provisioned package: windowscommunicationsapps"
}

try {
    Get-AppxPackage -AllUsers | Where-Object {$_.Name -like "*windowscommunicationsapps*"} | Remove-AppxPackage -AllUsers -ErrorAction Stop
    Write-Host "Installed package 'windowscommunicationsapps' removed for all users."
} catch {
    Write-Warning "Could not remove installed package: windowscommunicationsapps"
}

# ----------------------------
# Block "Outlook for Windows" from being reinstalled via Windows Update / OOBE
# ----------------------------

# Blocking future installation of "Outlook for Windows" via Windows Update...
Write-Host "Blocking Outlook for Windows from being reinstalled via Windows Update..."

# Create the path if it doesn't exist
New-Item -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe" -Force | Out-Null

# Correct way to set REG_SZ using PowerShell to avoid reg.exe escaping issues
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe" -Name "BlockedOobeUpdaters" -PropertyType String -Value '["MS_Outlook"]' -Force

# Attempt to remove any known leftover OutlookUpdate entry
reg.exe DELETE "HKLM\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\OutlookUpdate" /f /reg:64 2>$null


# ----------------------------
# Optional: Use BCU StoreAppHelper if installed
# ----------------------------

Write-Host "Checking for BCUninstaller helper..."

if (Test-Path "C:\Program Files\BCUninstaller\win-x64\StoreAppHelper.exe") {
    Write-Host "BCU detected. Attempting cleanup of Outlook for Windows via BCU..."

    & "C:\Program Files\BCUninstaller\win-x64\StoreAppHelper.exe" /uninstall "Microsoft.OutlookForWindows_1.2024.1017.300_x64__8wekyb3d8bbwe" 2>nul
    & "C:\Program Files\BCUninstaller\win-x64\StoreAppHelper.exe" /uninstall "Microsoft.OutlookForWindows_1.2024.1023.300_x64__8wekyb3d8bbwe" 2>nul
    & "C:\Program Files\BCUninstaller\win-x64\StoreAppHelper.exe" /uninstall "Microsoft.OutlookForWindows_1.2025.122.200_x64__8wekyb3d8bbwe" 2>nul
    & "C:\Program Files\BCUninstaller\win-x64\StoreAppHelper.exe" /uninstall "Microsoft.OutlookForWindows_1.2024.1115.300_x64__8wekyb3d8bbwe" 2>nul
    & "C:\Program Files\BCUninstaller\win-x64\StoreAppHelper.exe" /uninstall "Microsoft.OutlookForWindows_1.2025.506.300_x64__8wekyb3d8bbwe" 2>nul
} else {
    Write-Host "BCU not found, skipping BCU-based cleanup."
}

# ----------------------------
# Done
# ----------------------------

Write-Host "`n==== Cleanup Complete ===="
Write-Host "A reboot or user logoff may be required for all changes to fully apply."
