# by Martin Angelov
# =================================================================================================
# SCRIPT TO MANUALLY UNINSTALL MICROSOFT OFFICE CLICK-TO-RUN
# Based on Microsoft's official guide: 
# https://support.microsoft.com/en-us/office/manually-uninstall-office-4e2904ea-25c8-4544-99ee-17696bb3027b
#
# WARNING: This script will forcibly remove Microsoft Office and its components.
# Run this script with caution and ensure all work is saved.
# You MUST run this script as an Administrator.
# =================================================================================================

# --- PRE-FLIGHT CHECK: Verify Administrator Privileges ---
Write-Host "Checking for administrator privileges..." -ForegroundColor Yellow
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Administrator privileges are required! Please re-run this script as an Administrator."
    Start-Sleep -Seconds 10
    Exit
}
Write-Host "Administrator privileges confirmed." -ForegroundColor Green
Write-Host "Starting Office cleanup in 5 seconds..."
Start-Sleep -Seconds 5

# --- Step 3 (Adapted): Use Task Manager to end the Click-to-Run tasks ---
# This is done before deleting files to release any file locks.
Write-Host "[Step 3] Terminating all Office processes..." -ForegroundColor Cyan
$officeProcesses = @(
    "OfficeClickToRun",
    "OfficeC2RClient",
    "AppVShNotify",
    "setup"
)
foreach ($processName in $officeProcesses) {
    Get-Process $processName -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Write-Host "  - Stopped process: $processName"
}

# --- Step 4: Delete the Office service ---
Write-Host "[Step 4] Stopping and deleting the ClickToRun service..." -ForegroundColor Cyan
$service = Get-Service -Name "ClickToRunSvc" -ErrorAction SilentlyContinue
if ($service) {
    Stop-Service -Name "ClickToRunSvc" -Force -ErrorAction SilentlyContinue
    sc.exe delete "ClickToRunSvc"
    Write-Host "  - Service 'ClickToRunSvc' has been deleted."
}
else {
    Write-Host "  - Service 'ClickToRunSvc' not found. Skipping."
}


# --- Step 2: Remove the Office scheduled tasks ---
Write-Host "[Step 2] Deleting Office scheduled tasks..." -ForegroundColor Cyan
$scheduledTasks = @(
    "\Microsoft\Office\Office Automatic Updates",
    "\Microsoft\Office\Office Subscription Maintenance",
    "\Microsoft\Office\Office ClickToRun Service Monitor",
    "\Microsoft\Office\OfficeTelemetryAgentLogOn2016",
    "\Microsoft\Office\OfficeTelemetryAgentFallBack2016"
)
foreach ($task in $scheduledTasks) {
    schtasks.exe /delete /tn $task /f
}
Write-Host "  - All scheduled tasks have been processed."


# --- Step 1 & 5: Delete the Office files and folders ---
Write-Host "[Step 1 & 5] Deleting Office file system components..." -ForegroundColor Cyan
$foldersToDelete = @(
    "$env:ProgramFiles\Microsoft Office 16",
    "$env:ProgramFiles\Microsoft Office",
    "$env:ProgramFiles(x86)\Microsoft Office",
    "$env:CommonProgramFiles\Microsoft Shared\ClickToRun",
    "$env:ProgramData\Microsoft\ClickToRun",
    "$env:ProgramData\Microsoft\Office\ClickToRunPackagerLocker"
)
foreach ($folder in $foldersToDelete) {
    if (Test-Path $folder) {
        Write-Host "  - Deleting: $folder"
        Remove-Item -Path $folder -Recurse -Force -ErrorAction SilentlyContinue
    }
}


# --- Step 6: Delete the Office registry subkeys ---
Write-Host "[Step 6] Deleting Office registry keys..." -ForegroundColor Cyan
# It is safer to use Get-ChildItem to find the specific uninstall key
Write-Host "  - Searching for Office Uninstall registry key..."
$uninstallPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
Get-ChildItem -Path $uninstallPath | ForEach-Object {
    $displayName = $_.GetValue("DisplayName")
    if ($displayName -like "*Microsoft Office*" -or $displayName -like "*Microsoft 365*") {
        $keyPath = $_.PSPath
        Write-Host "  - Found and deleting Uninstall key: $keyPath"
        Remove-Item -Path $keyPath -Recurse -Force -ErrorAction SilentlyContinue
    }
}

$registryKeysToDelete = @(
    "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun",
    "HKLM:\SOFTWARE\Microsoft\AppVISV",
    "HKCU:\Software\Microsoft\Office"
)
foreach ($regKey in $registryKeysToDelete) {
    if (Test-Path $regKey) {
        Write-Host "  - Deleting registry key: $regKey"
        Remove-Item -Path $regKey -Recurse -Force -ErrorAction SilentlyContinue
    }
}


# --- Step 7: Delete the Start menu shortcuts ---
Write-Host "[Step 7] Deleting Start Menu shortcuts..." -ForegroundColor Cyan
$startMenuPath = "$env:ALLUSERSPROFILE\Microsoft\Windows\Start Menu\Programs"
$shortcutsToDelete = @(
    "$startMenuPath\Microsoft Office 2016 Tools",
    "$startMenuPath\Word",
    "$startMenuPath\Excel",
    "$startMenuPath\PowerPoint",
    "$startMenuPath\Outlook",
    "$startMenuPath\Publisher",
    "$startMenuPath\Access",
    "$startMenuPath\OneNote"
)
foreach ($shortcut in $shortcutsToDelete) {
    # We add a wildcard for file extensions (.lnk) or if it's a folder
    $itemPath = "$shortcut*" 
    if (Test-Path $itemPath) {
        Write-Host "  - Deleting shortcut/folder: $shortcut"
        Remove-Item -Path $itemPath -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# --- Step 8: Uninstall the MSI components ---
# This step is highly specific. This script does not run these commands automatically
# as they depend on the exact version of Office that was installed.
# Running the wrong ones is harmless but will produce errors.
# The most critical cleanup steps have already been performed.
Write-Host "[Step 8] MSI Component Cleanup" -ForegroundColor Yellow
Write-Host "The script has completed the primary cleanup. The MsiExec commands from Step 8 are rarely needed for modern Microsoft 365 but can be run manually if required."


# --- Finalization ---
Write-Host ""
Write-Host "Office cleanup script has finished." -ForegroundColor Green
Write-Host "It is highly recommended to RESTART your computer now before reinstalling Office." -ForegroundColor Yellow