
#
#PS C:\Users\Administrator> Get-ChildItem -Path Cert:\LocalMachine\WebHosting | Select-Object Thumbprint, Subject, NotBefore, Issuer
#2025SSL-EB179E5A2C09858E352D8EBD2B52F61A51755943

$OldThumbprint ="5e7a3768fb447e2a86fb362d2a57add39dcce92e"
$NewThumbprint ="f4c9769841338ca5ebcf9e7bae47cc7a5995f26f"

Get-WebBinding | Where-Object { $_.certificateHash -eq $OldThumbprint} | ForEach-Object {

Write-Host "Replacing Cert For " $_

$_.RemoveSslCertificate()

$_.AddSslCertificate($NewThumbprint, 'WebHosting')

}