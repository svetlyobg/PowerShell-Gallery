# by Martin Angelov
# Set Execution Policy for the current process
Set-ExecutionPolicy RemoteSigned -Scope Process -Force

# --- 1. SETUP AND CONNECTION ---

# Check if the ExchangeOnlineManagement module is already available
if (-not (Get-Module -Name ExchangeOnlineManagement -ListAvailable)) {
    Write-Host "ExchangeOnlineManagement module not found. Installing..." -ForegroundColor Yellow
    Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser -Repository PSGallery -Force
} else {
    Write-Host "ExchangeOnlineManagement module is already installed." -ForegroundColor Green
}

# Import the module to ensure its commands are available
Import-Module ExchangeOnlineManagement

# Prompt for Global Administrator Account Email
$globalAdmin = Read-Host "Enter your Global Administrator account email (e.g., admin@organization.com)"

# Connect to Exchange Online
Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -UserPrincipalName $globalAdmin -ShowBanner:$false

# --- 2. PREPARE EXPORT DIRECTORY ---

# Create a folder named "GroupExports" in the same directory as the script
$exportPath = Join-Path -Path $PSScriptRoot -ChildPath "GroupExports"
if (-not (Test-Path -Path $exportPath)) {
    Write-Host "Creating export directory at: $exportPath" -ForegroundColor Yellow
    New-Item -Path $exportPath -ItemType Directory | Out-Null
}

# --- 3. CORE LOGIC: FETCH GROUPS AND EXPORT MEMBERS ---

try {
    Write-Host "Fetching all groups from the tenant. This might take a moment..." -ForegroundColor Yellow
    # Get all group types and crucially, select the 'RecipientTypeDetails' property
    $allGroups = Get-UnifiedGroup -ResultSize Unlimited | Select-Object DisplayName, Identity, RecipientTypeDetails
    $allGroups += Get-DistributionGroup -ResultSize Unlimited | Select-Object DisplayName, Identity, RecipientTypeDetails

    Write-Host "Found $($allGroups.Count) groups to process." -ForegroundColor Green
    Start-Sleep -Seconds 2

    # Loop through each group found
    foreach ($group in $allGroups) {
        Write-Host "Processing group: $($group.DisplayName)" -ForegroundColor Cyan
        
        # --- MODIFIED AND CORRECTED LOGIC ---
        # Initialize an empty variable for members
        $members = $null

        # Check the group's type and use the correct command
        if ($group.RecipientTypeDetails -eq 'GroupMailbox') {
            # This is a Microsoft 365 Group
            try {
                $members = Get-UnifiedGroupLinks -Identity $group.Identity -LinkType Members -ResultSize Unlimited -ErrorAction Stop
            } catch {
                Write-Warning " -> Could not retrieve members for M365 Group '$($group.DisplayName)'. Error: $($_.Exception.Message)"
            }
        }
        else {
            # This is a Distribution List or Mail-Enabled Security Group
            try {
                $members = Get-DistributionGroupMember -Identity $group.Identity -ResultSize Unlimited -ErrorAction Stop
            } catch {
                Write-Warning " -> Could not retrieve members for Distribution Group '$($group.DisplayName)'. Error: $($_.Exception.Message)"
            }
        }
        # --- END OF MODIFIED LOGIC ---

        # Check if the group has any members
        if ($null -ne $members) {
            $exportData = @()
            foreach ($member in $members) {
                $exportData += [PSCustomObject]@{
                    'Group Name'            = $group.DisplayName
                    'Display Name (Person)' = $member.DisplayName
                    'UserPrincipalName/email' = $member.PrimarySmtpAddress
                    'Recipient Type'        = $member.RecipientTypeDetails
                }
            }

            $safeGroupName = $group.DisplayName -replace '[\\/:"*?<>|]', ''
            $fileName = "$safeGroupName.csv"
            $filePath = Join-Path -Path $exportPath -ChildPath $fileName

            $exportData | Export-Csv -Path $filePath -NoTypeInformation -Encoding UTF8
            Write-Host " -> Successfully exported $($members.Count) members to '$fileName'" -ForegroundColor Green
        }
        else {
            Write-Host " -> Group '$($group.DisplayName)' is empty or members could not be retrieved. Skipping." -ForegroundColor Gray
        }
    }
}
catch {
    Write-Error "An unexpected error occurred during the main process: $_"
}
finally {
    # --- 4. CLEANUP ---
    Write-Host "-------------------------------------------------" -ForegroundColor Cyan
    Write-Host "Export process completed." -ForegroundColor Cyan
    Write-Host "All CSV files have been saved in the '$exportPath' folder." -ForegroundColor Cyan
    Start-Sleep -Seconds 2
    
    Write-Host "Disconnecting from all PowerShell sessions..."
    Get-PSSession | Remove-PSSession -Confirm:$false
}