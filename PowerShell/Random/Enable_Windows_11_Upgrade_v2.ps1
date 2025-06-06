# Ensure script is running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Error: This script must be run as Administrator." -ForegroundColor Red
    Exit 1
}

Write-Host "Starting script..." -ForegroundColor Green

# Registry paths (including 32-bit and 64-bit)
$RegistryPaths = @(
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate",
    "HKLM:\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\WindowsUpdate"
)

# Registry values to remove or set
$RegistryValues = @(
    @{ Path = "TargetReleaseVersion"; Value = 0; Type = "DWord"; RemoveFirst = $true; Comment = "Prevents updates beyond a specific version" }, # Set to 0 then remove
    @{ Path = "TargetReleaseVersionInfo"; RemoveFirst = $true; Comment = "Specifies the target feature update version" },
    @{ Path = "DeferFeatureUpdatesPeriodInDays"; RemoveFirst = $true; Comment = "Delays feature updates" },
    @{ Path = "DeferQualityUpdatesPeriodInDays"; RemoveFirst = $true; Comment = "Delays quality updates" },
    @{ Path = "DeferUpgradePeriodInDays"; RemoveFirst = $true; Comment = "Delays upgrade to a new Windows edition" },
    @{ Path = "BranchReadinessLevel"; RemoveFirst = $true; Comment = "Controls access to pre-release updates" },
    @{ Path = "PauseFeatureUpdates"; RemoveFirst = $true; Comment = "Pauses feature updates" },
    @{ Path = "PauseQualityUpdates"; RemoveFirst = $true; Comment = "Pauses quality updates" },
    #@{ Path = "DisableWUfBSafeguards"; RemoveFirst = $true; Comment = "Bypasses Windows Update safeguards (!!!USE WITH EXTREME CAUTION ONLY IF NEEDED!!!)" },
    @{ Path = "SetUpdateNotificationLevel"; RemoveFirst = $true; Comment = "Controls update notifications"},
    @{ Path = "Update/Auto Update Options/AUOptions"; RemoveFirst = $true; Comment = "Configures automatic updates settings"}, # Example using subkeys
    @{ Path = "NoAutoUpdate"; RemoveFirst = $true; Comment = "Disables Automatic Updates" },
    @{ Path = "NoAutoRebootWithLoggedOnUsers"; RemoveFirst = $true; Comment = "Prevents automatic reboot with logged-on users" }

)



foreach ($regPath in $RegistryPaths) {
    Write-Host "Processing registry path: $regPath" -ForegroundColor Green
    foreach ($value in $RegistryValues) {
        $fullPath = "$regPath\$($value.Path)"
        if (Test-Path $fullPath) {
            if ($value.RemoveFirst) {
                try {
                    Remove-ItemProperty -Path $regPath -Name $value.Path -Force -ErrorAction Stop
                    Write-Host "Removed '$($value.Path)' ( $($value.Comment) ) from '$regPath'" -ForegroundColor Green
                }
                catch {
                    Write-Host "Error removing '$($value.Path)' from '$regPath': $($_.Exception.Message)" -ForegroundColor Red
                }
            }
            if ($value.Value) { # If a value is specified, set it 
                try {
                    Set-ItemProperty -Path $regPath -Name $value.Path -Value $value.Value -Type $value.Type -Force -ErrorAction Stop
                    Write-Host "Set '$($value.Path)' in '$regPath' to '$($value.Value)'" -ForegroundColor Green
                }
                catch {
                    Write-Host "Error setting '$($value.Path)' in '$regPath': $($_.Exception.Message)" -ForegroundColor Red
                }
            }
        }
        else {
            Write-Host "Registry value '$($value.Path)' ( $($value.Comment) ) not found in '$regPath'" -ForegroundColor Yellow
        }
    }
}

# Set AllowWindows11Upgrade to allow upgrade path
$uxSettingsPath = "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings"

try
{
 New-Item -Path $uxSettingsPath -Force | Out-Null
 Write-Host "Registry value 'UX\Settings' (Key Required) created in 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings'" -ForegroundColor Green
}
    
catch 
{
 Write-Host "Could not create UX Settings path: $($_.Exception.Message)" -ForegroundColor Red
}

try {
    Set-ItemProperty -Path $uxSettingsPath -Name "AllowWindows11Upgrade" -Value 1 -Type DWord
    Write-Host "Registry value 'AllowWindows11Upgrade' ( Permits the Windows 11 upgrade ) added in 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings'" -ForegroundColor Green
}
catch {
    Write-Host "Warning: Failed to set AllowWindows11Upgrade: $($_.Exception.Message)" -ForegroundColor Yellow
}

# 
try {
		Restart-Service wuauserv -Force
		Write-Host "Restarted update service." -ForegroundColor Green
    }
catch 
{
        Write-Host "Error: Could not restart update service." -ForegroundColor Red
}

# Trigger update checks (multiple methods for redundancy)
try {
    wuauclt /detectnow
    Write-Host "Initiated Legacy Windows Update detection." -ForegroundColor Green
    wuauclt /updatenow
    Write-Host "Initiated Legacy Windows Update installation." -ForegroundColor Green

    UsoClient StartScan
    Write-Host "Started Mdoern Windows Update scan." -ForegroundColor Green


}
catch {
     Write-Host "Error triggering update checks: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "Script completed." -ForegroundColor Green