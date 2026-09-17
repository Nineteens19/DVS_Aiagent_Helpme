Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$zip = [System.IO.Compression.ZipFile]::OpenRead('E:\DVS\Project\Aiagent_Helpme\scratch\test_output.msapp')

Write-Output "=== ZIP ENTRIES ==="
foreach ($e in $zip.Entries) {
    Write-Output "Entry: $($e.FullName)"
}

Write-Output "`n=== DATASOURCES ==="
$dsEntry = $null
foreach ($e in $zip.Entries) {
    if ($e.FullName -like '*DataSources.json*') { $dsEntry = $e; break }
}
if ($dsEntry) {
    $r = New-Object System.IO.StreamReader($dsEntry.Open())
    $dsJson = $r.ReadToEnd() | ConvertFrom-Json
    $r.Close()
    $dsJson.DataSources | ForEach-Object { Write-Output "  DS: $($_.Name)" }
}

Write-Output "`n=== PROPERTIES ==="
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

$zip.Dispose()
