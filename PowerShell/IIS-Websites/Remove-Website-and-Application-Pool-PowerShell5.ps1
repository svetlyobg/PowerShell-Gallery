<#
CopyLeft SVET :)
.Synopsis
   Removes a Web App Pool and IIS a Wesbsite for Powershell 5
.DESCRIPTION
   Removes an Application Pool and Website.
.EXAMPLE
   Another example of how to use this cmdlet

#>
#Needed for PowerShell 5
Install-Module -Name WebAdministration
#Needed for PowerShell 5
Import-Module WebAdministration
#Find-Module -Name *IIS*
#Find-Module -Name *WebAdministration*
#Needed for PowerShell 5
Install-Module -Name IISAdministration
#Needed for PowerShell 5
Import-Module IISAdministration
$wap = Read-Host -Prompt 'Input the Web App Pool Name'
Write-Host "`n$line"
Write-Host "Next actions will be performed on App Pools and IIS websites that contain $wap in their name !!!" -ForegroundColor Yellow
Write-Host "`n$line"

Get-Website -Name $wap
Get-WebAppPoolState -Name $wap

$yesno = Read-Host -Prompt 'Do you wish to proceed with stopping the website? y/n:'

if ($yesno -like 'y'){

Remove-WebAppPool -Name $wap -verbose
#Start-WebAppPool -Name *$wap* -verbose
Write-Host "`n$line"
Write-Host "App Pool was sucessfully removed!" -ForegroundColor Green
Write-Host "`n$line"

Get-Website -Name $wap
Remove-Website $wap -Verbose
Write-Host "`n$line"
Write-Host "IIS Website was sucessfully removed !!!" -ForegroundColor RED
Write-Host "`n$line"

Write-Host "The Window will close in 5 seconds"
Start-Sleep -Seconds 5

}

else {
    Write-Host Negative User Choise
}

