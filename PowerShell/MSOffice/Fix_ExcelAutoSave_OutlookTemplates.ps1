# by Martin Angelov
# Ensure Office 16.0 Common Privacy settings are configured
$privacyPath = "HKCU:\Software\Policies\Microsoft\office\16.0\common\privacy"

# Create the key if it doesn't exist
If (-not (Test-Path $privacyPath)) {
    New-Item -Path $privacyPath -Force | Out-Null
}

# Set the required DWORD values
New-ItemProperty -Path $privacyPath -Name "disconnectedstate" -PropertyType DWord -Value 1 -Force | Out-Null
New-ItemProperty -Path $privacyPath -Name "usercontentdisabled" -PropertyType DWord -Value 1 -Force | Out-Null
New-ItemProperty -Path $privacyPath -Name "downloadcontentdisabled" -PropertyType DWord -Value 1 -Force | Out-Null
New-ItemProperty -Path $privacyPath -Name "controllerconnectedservicesenabled" -PropertyType DWord -Value 1 -Force | Out-Null

# Ensure Office 16.0 Common Internet settings are configured
$internetPath = "HKCU:\Software\Policies\Microsoft\Office\16.0\Common\Internet"

# Create the key if it doesn't exist
If (-not (Test-Path $internetPath)) {
    New-Item -Path $internetPath -Force | Out-Null
}

# Set OnlineStorage to 0
New-ItemProperty -Path $internetPath -Name "OnlineStorage" -PropertyType DWord -Value 0 -Force | Out-Null

Write-Output "Registry settings applied. Please restart your device for changes to take effect."
