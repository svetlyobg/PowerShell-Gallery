<#

CopyLeft SVET :)

NAME
	Recursively Delete Folder and Its Subfolders - 2
	
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

$folderPath = "C:\archive\"
$user = "$env:USERNAME"
$accesstype = "FullControl"
$argList = $user, $accesstype, $allowOrDeny
$allowOrDeny = "Allow"
$acl = Get-Acl $folderPath
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule -ArgumentList $argList
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule ($user, $accesstype, $allowOrDeny)
$acl.SetAccessRule($AccessRule)
$acl | Set-Acl $folderPath


# SIG # Begin signature block
# MIIFagYJKoZIhvcNAQcCoIIFWzCCBVcCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUh5eRKCPadP+/aax7bGYWZ+2T
# 9K6gggMGMIIDAjCCAeqgAwIBAgIQJLzUFQ0UMqZIQD0LynYJzzANBgkqhkiG9w0B
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
# AYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUsWQv17g2oZtq
# lSzfmpRjakjCX2QwDQYJKoZIhvcNAQEBBQAEggEATf8EvPLvj2YHBMaKSTvgXWsK
# M4Il/xwX2kl0k2G6Jx8y4ExdZwGHNqGvMjiWzYbMVcgYhvO57Io6oECT5YLSP3/a
# jew1E45xoj1v6Ezu81YOpbNAUymfbHDJD3pvcI621vtqclaG3pLBfQAH8nb1S4eT
# pSYNmR4QxRrtjH1nq1VUABKnVWAFbBWagR/QyUIrqFd57K480sOlFiVb378WP9i4
# mzD0F2oATLDI4O2vRW/AZf5iNksZju7tHl4pO43PWcjz7ljiwQ/msmK5g5Q7iEGn
# DhPGCImzKWtVKLge6Q0YLpC/abFTP0s6u0RXyfbzspymi4WM6BSzc1U8vEALoQ==
# SIG # End signature block
