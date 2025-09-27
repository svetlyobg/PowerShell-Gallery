# by Martin Angelov
# Set Execution Policy for the current process
Set-ExecutionPolicy RemoteSigned -Scope Process -Force

# Check if the ExchangeOnlineManagement module is already available
if (-not (Get-Module -Name ExchangeOnlineManagement -ListAvailable)) {
    Write-Host "ExchangeOnlineManagement module not found. Installing..." -ForegroundColor Yellow
    # Install the module for the current user without requiring admin rights
    Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser -Repository PSGallery -Force
} else {
    Write-Host "ExchangeOnlineManagement module is already installed." -ForegroundColor Green
}

# Import the module to ensure its commands are available in this session
Import-Module ExchangeOnlineManagement

# Prompt for Global Administrator Account Email
$globalAdmin = Read-Host "Enter your Global Administrator account email (e.g., admin@organization.com)"

# Connect to Exchange Online
Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -UserPrincipalName $globalAdmin -ShowBanner:$false

# Loop the menu until the user chooses to quit
do {
    # Clear the screen for a clean menu display
    cls

    # Display Menu Options with your original colors
    Write-Host "Select an option:"
	Write-Host " "
    Write-Host "1. Check auto-expanding archive status for a mailbox" -ForegroundColor Cyan
    Write-Host "2. Enable auto-expanding archive for a mailbox" -ForegroundColor Green
    Write-Host "3. Disable auto-expanding archive for a mailbox [CAUTION]" -ForegroundColor Red
    Write-Host "4. Show organization configuration" -ForegroundColor Yellow
    Write-Host "5. Exit the application" -ForegroundColor Green

    # Get User Choice
    $choice = Read-Host "Enter your choice (1, 2, 3, 4, 5)"

    switch ($choice) {
        '1' {
            # Check auto-expanding archive status
            $mailbox = Read-Host "Enter the mailbox (e.g., person@organization.com)"
            Write-Host "Checking auto-expanding archive status for $mailbox..." -ForegroundColor Yellow
			Start-Sleep -Seconds 2
            try {
                Get-Mailbox $mailbox -ErrorAction Stop | Select-Object UserPrincipalName, AutoExpandingArchiveEnabled
            }
            catch {
                Write-Warning "Could not find mailbox '$mailbox'. Please check the address and try again."
            }
        }
        '2' {
            # Enable auto-expanding archive
            $mailbox = Read-Host "Enter the mailbox (e.g., person@organization.com)"
            Write-Host "Enabling auto-expanding archive for $mailbox..." -ForegroundColor Green
            Enable-Mailbox $mailbox -AutoExpandingArchive
            Write-Host "Auto-expanding archive enabled for $mailbox." -ForegroundColor Green
			Start-Sleep -Seconds 2
        }
        '3' {
            # Disable auto-expanding archive
            $mailbox = Read-Host "Enter the mailbox (e.g., person@organization.com)"
            Write-Host "Disabling auto-expanding archive for $mailbox..." -ForegroundColor Red
            Disable-Mailbox $mailbox -AutoExpandingArchive
            Write-Host "Auto-expanding archive disabled for $mailbox." -ForegroundColor Red
			Start-Sleep -Seconds 2
        }
        '4' {
            # Show organization configuration
            Write-Host "Retrieving organization configuration..." -ForegroundColor Yellow
            $tempFile = Join-Path $env:TEMP "OrganizationConfig.txt"
            Get-OrganizationConfig | Out-File -FilePath $tempFile
            Write-Host "Opening organization configuration in Notepad..." -ForegroundColor Green
            notepad.exe $tempFile
        }
        '5' {
            # This case handles the exit. The message will be displayed before the loop ends.
            Write-Host "Script execution completed." -ForegroundColor Cyan
			Start-Sleep -Seconds 1
        }
        default {
            Write-Host "Invalid choice. Please run the script again." -ForegroundColor Red
        }
    }

    # Pause the script so the user can see the output before the menu redisplays
    if ($choice -ne '5') {
        Read-Host "Press Enter to return to the menu..."
    }

} while ($choice -ne '5') # The loop continues as long as the choice is not '5'

# Disconnect the session when the script is finished
Write-Host "Disconnecting from all PowerShell sessions..." -ForegroundColor Cyan
Start-Sleep -Seconds 1
Get-PSSession | Remove-PSSession -Confirm:$false