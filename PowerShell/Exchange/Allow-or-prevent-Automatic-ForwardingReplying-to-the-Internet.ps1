#
#Get the currently configured a Remote Domain
Get-RemoteDomain
#
#See the current configuration for the remote domain
#
Get-RemoteDomain Default | Format-List
#
#Look for the settings for AllowedOOFType, AutoReplyEnabled and AutoForwardEnabled
#
Get-RemoteDomain Default | Format-List AllowedOOFType, AutoReplyEnabled, AutoForwardEnabled
#
#Change the setting
#
##Enable automatic replies
#
Set-RemoteDomain -AutoReplyEnabled $true
#
##Enable automatic forwards
#
Set-RemoteDomain –AutoForwardEnabled $true
#
##Enable OOF for Outlook 2003 and previous (for Exchange 2007 and 2010 support)
#
Set-RemoteDomain –AllowedOOFType $ExternalLegacy
#
##To change all at once
#
Set-RemoteDomain Default -AutoReplyEnabled $true -AutoForwardEnabled $true –AllowedOOFType $ExternalLegacy
#