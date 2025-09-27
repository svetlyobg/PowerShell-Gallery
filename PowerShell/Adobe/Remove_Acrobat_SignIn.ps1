# by Martin Angelov
# This script configures Adobe Acrobat to prevent sign-in prompts by enforcing reduced mode.

# Define the path for the FeatureLockDown registry key
$FeatureLockDownPath = "HKLM:\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockDown"
$ServicesPath = "$FeatureLockDownPath\cServices"

# Create the FeatureLockDown path if it doesn't exist
if (-not (Test-Path $FeatureLockDownPath)) {
    New-Item -Path $FeatureLockDownPath -Force | Out-Null
}

# Create the cServices key under FeatureLockDown if it doesn't exist
if (-not (Test-Path $ServicesPath)) {
    New-Item -Path $ServicesPath -Force | Out-Null
}

# Set the value to enforce reduced mode, which disables the sign-in requirement.
# This corresponds to the HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockDown DWORD value "bIsSCReducedModeEnforcedEx" = 1
Set-ItemProperty -Path $FeatureLockDownPath -Name "bIsSCReducedModeEnforcedEx" -Value 1 -Type DWORD -Force | Out-Null

# Set the value to disable the updater service.
Set-ItemProperty -Path $ServicesPath -Name "bUpdater" -Value 1 -Type DWORD -Force | Out-Null

Write-Host "Adobe Acrobat registry keys have been set to prevent sign-in prompts."