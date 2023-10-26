New-MailboxExportRequest -Mailbox "user@example.com" -FilePath "\\exchange\export\User.pst" -Name "CustomExportName" -Description "Description of the export"

Get-MailboxExportRequest -Mailbox "User Display Name or Mailbox"

Get-MailboxExportRequest -Identity "User Display Name or Mailbox"

Get-MailboxExportRequest -Status

Get-MailboxExportRequest -Status InProgress

Remove-MailboxExportRequest -Identity "User Display Name or Mailbox"