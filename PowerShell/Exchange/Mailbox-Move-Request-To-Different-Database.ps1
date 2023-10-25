Get-MailboxDatabase

Get-MoveRequest -Identity "user@domain.example" |  Get-MoveRequestStatistics

New-MoveRequest -Identity "user@domain.example" -TargetDatabase "Mailbox Database 2134000348"

New-MoveRequest -Identity "user@domain.example" -TargetDatabase "Mailbox Database 2134000348" -ArchiveTargetDatabase "ArchiveDatabase"

Remove-MoveRequest -Identity "user@domain.example"

Get-MigrationBatch -Identity "Mailbox 1 and Mailbox 2" | Select-Object Identity, Status, TotalCount, FinalizedCount, FailedCount

