param(
    [string]$Server       = $env:COMPUTERNAME,
    [string]$OutputFolder = "C:\PermAudit",
    [int]   $MaxDepth     = 3,
    [string]$FilterUser   = ""
)

if (-not (Test-Path $OutputFolder)) { New-Item -ItemType Directory -Path $OutputFolder | Out-Null }
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
$csvFile   = "$OutputFolder\Permissions_$timestamp.csv"
$htmlFile  = "$OutputFolder\Permissions_$timestamp.html"
$results   = [System.Collections.Generic.List[PSObject]]::new()

Write-Host "Server : $Server"
Write-Host "Output : $OutputFolder"

function Get-FolderACL {
    param([string]$Path, [string]$ShareName, [string]$ShareType)
    try {
        $acl = Get-Acl -LiteralPath $Path -ErrorAction Stop
        foreach ($ace in $acl.Access) {
            $identity = $ace.IdentityReference.ToString()
            if ($FilterUser -and $identity -notlike "*$FilterUser*") { continue }
            $results.Add([PSCustomObject]@{
                Server           = $Server
                ShareName        = $ShareName
                ShareType        = $ShareType
                Path             = $Path
                Identity         = $identity
                Rights           = $ace.FileSystemRights
                AccessType       = $ace.AccessControlType
                IsInherited      = $ace.IsInherited
                InheritanceFlags = $ace.InheritanceFlags
            })
        }
    } catch {
        Write-Warning "Cannot read ACL: $Path"
    }
}

function Scan-Folder {
    param([string]$Path, [string]$ShareName, [string]$ShareType, [int]$Depth = 0)
    Get-FolderACL -Path $Path -ShareName $ShareName -ShareType $ShareType
    if ($Depth -lt $MaxDepth) {
        try {
            Get-ChildItem -LiteralPath $Path -Directory -ErrorAction Stop | ForEach-Object {
                Scan-Folder -Path $_.FullName -ShareName $ShareName -ShareType $ShareType -Depth ($Depth + 1)
            }
        } catch { Write-Warning "Cannot enumerate: $Path" }
    }
}

Write-Host "[1/2] Scanning SMB Shares..." -ForegroundColor Yellow
try {
    $isLocal   = ($Server -eq $env:COMPUTERNAME) -or ($Server -eq "localhost")
    $smbShares = if ($isLocal) { Get-SmbShare -ErrorAction Stop } else { Get-SmbShare -CimSession $Server -ErrorAction Stop }
    $smbShares = $smbShares | Where-Object { $_.Special -eq $false -and $_.Name -notmatch '\$$' }
    Write-Host "  Found $($smbShares.Count) share(s)"

    foreach ($share in $smbShares) {
        Write-Host "  Share: $($share.Name) -> $($share.Path)"
        try {
            $perms = if ($isLocal) { Get-SmbShareAccess -Name $share.Name } else { Get-SmbShareAccess -Name $share.Name -CimSession $Server }
            foreach ($p in $perms) {
                if ($FilterUser -and $p.AccountName -notlike "*$FilterUser*") { continue }
                $results.Add([PSCustomObject]@{
                    Server           = $Server
                    ShareName        = $share.Name
                    ShareType        = "SMB-ShareLevel"
                    Path             = $share.Path
                    Identity         = $p.AccountName
                    Rights           = $p.AccessRight
                    AccessType       = $p.AccessControlType
                    IsInherited      = "N/A"
                    InheritanceFlags = "N/A"
                })
            }
        } catch { Write-Warning "Share-level perms failed: $($share.Name)" }
        if ($share.Path -and (Test-Path $share.Path)) {
            Scan-Folder -Path $share.Path -ShareName $share.Name -ShareType "SMB-NTFS"
        } else { Write-Warning "Path not accessible: $($share.Path)" }
    }
} catch { Write-Warning "SMB scan failed: $_" }

Write-Host "[2/2] Scanning DFS..." -ForegroundColor Yellow
try {
    Import-Module DFSN -ErrorAction Stop
    $roots = Get-DfsnRoot -ErrorAction Stop
    Write-Host "  Found $($roots.Count) DFS root(s)"
    foreach ($root in $roots) {
        $links = Get-DfsnFolder -Path "$($root.Path)\*" -ErrorAction SilentlyContinue
        foreach ($link in $links) {
            $targets = Get-DfsnFolderTarget -Path $link.Path -ErrorAction SilentlyContinue
            foreach ($t in $targets) {
                Write-Host "  DFS: $($link.Path) -> $($t.TargetPath)"
                if ($t.TargetPath -and (Test-Path $t.TargetPath)) {
                    Scan-Folder -Path $t.TargetPath -ShareName $link.Path -ShareType "DFS-NTFS"
                }
            }
        }
    }
} catch { Write-Warning "DFS not available or no roots found" }

$results | Export-Csv -Path $csvFile -NoTypeInformation -Encoding UTF8
Write-Host "CSV: $csvFile" -ForegroundColor Green

$rows = $results | ForEach-Object {
    $bg = if ($_.AccessType -match "Deny") { "#ffe6e6" } elseif ($_.IsInherited -eq $false) { "#fff9e6" } else { "#f9f9f9" }
    "<tr style='background:$bg'><td>$($_.Server)</td><td>$($_.ShareName)</td><td>$($_.ShareType)</td><td>$($_.Path)</td><td><b>$($_.Identity)</b></td><td>$($_.Rights)</td><td>$($_.AccessType)</td><td>$($_.IsInherited)</td></tr>"
}

@"
<html><head><title>Permissions $timestamp</title>
<style>body{font-family:Segoe UI,sans-serif;font-size:12px;margin:20px}table{border-collapse:collapse;width:100%}th{background:#003087;color:white;padding:6px 10px;text-align:left}td{padding:4px 10px;border-bottom:1px solid #ddd}tr:hover td{background:#d9e8ff!important}</style>
</head><body>
<h1>Share Permissions Report</h1>
<p>Server: <b>$Server</b> | Generated: <b>$timestamp</b> | Total: <b>$($results.Count)</b></p>
<table><tr><th>Server</th><th>Share</th><th>Type</th><th>Path</th><th>Identity</th><th>Rights</th><th>Access</th><th>Inherited</th></tr>
$($rows -join "`n")
</table></body></html>
"@ | Out-File -FilePath $htmlFile -Encoding UTF8

Write-Host "HTML: $htmlFile" -ForegroundColor Green
Write-Host "Total entries: $($results.Count)"
Start-Process $htmlFile
