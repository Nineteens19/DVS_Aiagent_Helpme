Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$zip = [System.IO.Compression.ZipFile]::OpenRead('E:\DVS\Project\Aiagent_Helpme\Helpdesk_KB_Portal.msapp')

Write-Output "=== 1. ZIP ENTRIES ==="
foreach ($e in $zip.Entries) {
    Write-Output "  $($e.FullName)"
}

Write-Output "`n=== 2. DATASOURCES IN MSAPP ==="
$dsEntry = $null
foreach ($e in $zip.Entries) {
    if ($e.FullName -like '*DataSources.json*') { $dsEntry = $e; break }
}
if ($dsEntry) {
    $r = New-Object System.IO.StreamReader($dsEntry.Open())
    $dsJson = $r.ReadToEnd() | ConvertFrom-Json
    $r.Close()
    $dsJson.DataSources | ForEach-Object { Write-Output "  [DataSource] Name: $($_.Name) | Type: $($_.Type) | TableName: $($_.TableName)" }
}

Write-Output "`n=== 3. PROPERTIES IN MSAPP ==="
$pEntry = $null
foreach ($e in $zip.Entries) {
    if ($e.FullName -like '*Properties.json*') { $pEntry = $e; break }
}
if ($pEntry) {
    $r = New-Object System.IO.StreamReader($pEntry.Open())
    $pJson = $r.ReadToEnd() | ConvertFrom-Json
    $r.Close()
    Write-Output "  App Name: $($pJson.Name)"
    Write-Output "  LocalConnectionReferences: $($pJson.LocalConnectionReferences)"
}

Write-Output "`n=== 4. PUBLISH INFO ==="
$pubEntry = $null
foreach ($e in $zip.Entries) {
    if ($e.FullName -like '*PublishInfo.json*') { $pubEntry = $e; break }
}
if ($pubEntry) {
    $r = New-Object System.IO.StreamReader($pubEntry.Open())
    $pubJson = $r.ReadToEnd() | ConvertFrom-Json
    $r.Close()
    Write-Output "  Publish App Name: $($pubJson.AppName)"
}

$zip.Dispose()
