New-MoveRequest -Identity "user@example.com" -TargetDatabase "Mailbox Database 1986552740"

New-MoveRequest -Identity "user@example.com" -TargetDatabase "Mailbox Database 2134000348" -ArchiveTargetDatabase "ArchiveDatabase"

Get-MoveRequest -Identity "user@example.com" | Get-MoveRequestStatistics

Get-MoveRequest | Get-MoveRequestStatistics

Remove-MoveRequest -Identity "user@example.com"

Get-Mailbox -Database "Mailbox Database 1986552740" | Sort-Object TotalItemSize

Get-Mailbox -Database "ArchiveDatabase2019" | Sort-Object DisplayName

Get-MailboxDatabase -Status | Format-Table Name, DatabaseSize, AvailableNewMailboxSpace -Auto