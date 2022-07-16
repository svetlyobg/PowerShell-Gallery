<#

CopyLeft SVET :)

NAME
	Dump MySQL DB to website folder, convert to UTF8mb4 for MariaDB, create zip and delete the SQL file - 3
	
SYNOPSIS
	

SYNTAX
	
	
DESCRIPTION
	
	
PARAMETERS
	
	
INPUTS
	
	
OUTPUTS
	
	
NOTES
	
	
EXAMPLES
	
	
RELATED LINKS
	
	
#>

Push-Location "C:\Program Files\MySQL\MySQL Server 5.7\bin\"
.\mysqldump.exe -u USER -pPASSWORD -h SERVERNAME DATABASENAME --default-character-set=utf8mb4 > "WEBSITELOCATION\DATABASE.sql"
$d = Get-Date -Format "dd-MM-yyyy-dddd"
Compress-Archive -LiteralPath "WEBSITELOCATION\" -DestinationPath "BACKUPLOCATION\$d.zip" -CompressionLevel Optimal -Force
Push-Location "WEBSITELOCATION"
Remove-Item DATABASE.sql



# SIG # Begin signature block
# MIIFagYJKoZIhvcNAQcCoIIFWzCCBVcCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUXJ6Bj11deSg6PDqpqjsOBjRX
# HqugggMGMIIDAjCCAeqgAwIBAgIQJLzUFQ0UMqZIQD0LynYJzzANBgkqhkiG9w0B
# AQsFADAZMRcwFQYDVQQDDA5HbyBMaXZlIFVLIEx0ZDAeFw0yMjA3MTYxMTU3MzZa
# Fw0yNzA3MTUyMTAwMDBaMBkxFzAVBgNVBAMMDkdvIExpdmUgVUsgTHRkMIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1jBbQhei1OZxT2X07woTaSXAAIhc
# nY1a8OwQdzKLpWKCskGbDmGBH0bdqLq1m+y8jWKnf1tEnzaFVxUKrcwq57hy8og2
# xK9Ciq2+X43ZpA4acLUnvK0auUNig2vwWXlnPr4vh4g6+E6nMvvyhPA5ND+Uvhm2
# wSi7Z+qlmYQqm7wI7IEoaGy/8zyPB1vnWOL2UUYL8oTSklGdA6/wPGcV0S41vfGR
# 1YClE/AaAMB2+GZgkGgw9gQvKwsNRFIJSKu3OHICfrPRJgObdMnKr6F2jFl2LP+E
# Rf/Qy7BkTMwLIuxm2Tik+yPh3ZLGWGr2TtQoipNcdIg/7jmGuepTssD5/QIDAQAB
# o0YwRDAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMwHQYDVR0O
# BBYEFDBp69/PtsKtexPQHwwNhwtX73JqMA0GCSqGSIb3DQEBCwUAA4IBAQBQ4+Qm
# FQd/u421ZKpspyhsYw/Hjnn27uBwJ1420lpQSApuI6BnsmlZlpNVAl5ETMtbzezo
# x4xwkQ2H4/+FWg4/Mic0adMwAgqGEeOpWYZxpUQFnzCIlyH6QmXvDLuR5FwVUFKt
# fdbUj5waOOY6UJ3MSGWEykAX3R3jF/g9AgZmfvTeK9ko72QU595uIHRRXubq3akk
# 8WGiZcvgZ6WwzbHDw3iM3Q16OKOGKC/UQgJ1eiawavJUF7DQawB1VonfnbT9caZB
# 8H88Qf8u3g2FQlStoZ1lYfIUj37PZfbaBhVVZyMS7FxmSmfLXvQLtV0pT7nSRK63
# Ki30MG53JtJQdqYmMYIBzjCCAcoCAQEwLTAZMRcwFQYDVQQDDA5HbyBMaXZlIFVL
# IEx0ZAIQJLzUFQ0UMqZIQD0LynYJzzAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIB
# DDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEE
# AYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQU6bMyt+HHpFMe
# w6kMovaN8BsTQ6swDQYJKoZIhvcNAQEBBQAEggEAQloedtyDpRHLgI+WUmfFklrf
# Afn7C1sDLC+PNUf+X3JPwDLLxzxr3PaciLMywex3T7T1pP+jAdOs/tM/xxKSX0sp
# e9gUNhQ/V3xPMozMufEa1dEXNs6WW72dteRARH8YuUDcj7ZhzxnkgpakbdLCktMV
# P627hbGbequig1g6+6eqtIsCKx5+VKdR10xq8yuFQ0WKiLGKNjYTAozDqr9WgKzn
# XKh0E3wWuTCbUXq0NqF4/BGaYh3iqMaMhL7NXVgG3F/U+/Pam/jrDrylQh2nWL9F
# NVuMhAYULW2zM18KCdoIIYfQvtfQHGp6gRLtgn7qX1sR7eRgAwuMm+FqtHHBUg==
# SIG # End signature block
