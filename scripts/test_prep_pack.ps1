Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$testDir = 'E:\DVS\Project\Aiagent_Helpme\scratch\test_pack_dir'
if (Test-Path $testDir) { Remove-Item $testDir -Recurse -Force }
New-Item -ItemType Directory -Path $testDir | Out-Null

# Copy Src directory
Copy-Item 'E:\DVS\Project\Aiagent_Helpme\Helpdesk_KB_Portal\Src' -Destination "$testDir\Src" -Recurse

# Create test_pack_dir\test_pack_dir.msapr
$msaprPath = "$testDir\test_pack_dir.msapr"
Copy-Item 'E:\DVS\Project\Aiagent_Helpme\Helpdesk_KB_Portal\Helpdesk_KB_Portal.msapr' $msaprPath -Force

$zip = [System.IO.Compression.ZipFile]::Open($msaprPath, [System.IO.Compression.ZipArchiveMode]::Update)

# Helper function to remove entry by wildcard pattern
function Remove-MatchingEntries($archive, $pattern) {
    $toRemove = @()
    foreach ($e in $archive.Entries) {
        if ($e.FullName -like $pattern) {
            $toRemove += $e
        }
    }
    foreach ($e in $toRemove) {
        $e.Delete()
    }
}

# 1. Replace DataSources.json
Remove-MatchingEntries $zip "*DataSources.json*"
$dsEntry = $zip.CreateEntry('msapp\References\DataSources.json')
$dsWriter = New-Object System.IO.StreamWriter($dsEntry.Open(), [System.Text.Encoding]::UTF8)
$dsContent = [System.IO.File]::ReadAllText('E:\DVS\Project\Aiagent_Helpme\Helpdesk_KB_Portal\References\DataSources.json', [System.Text.Encoding]::UTF8)
$dsWriter.Write($dsContent)
$dsWriter.Flush()
$dsWriter.Close()

# 2. Replace Properties.json
Remove-MatchingEntries $zip "*Properties.json*"
$propEntry = $zip.CreateEntry('msapp\Properties.json')
$propWriter = New-Object System.IO.StreamWriter($propEntry.Open(), [System.Text.Encoding]::UTF8)
$propContent = [System.IO.File]::ReadAllText('E:\DVS\Project\Aiagent_Helpme\Helpdesk_KB_Portal\Properties.json', [System.Text.Encoding]::UTF8)
$propWriter.Write($propContent)
$propWriter.Flush()
$propWriter.Close()

# 3. Replace PublishInfo.json
$pubEntry = $null
foreach ($e in $zip.Entries) {
    if ($e.FullName -like '*PublishInfo.json*') { $pubEntry = $e; break }
}
if ($null -ne $pubEntry) {
    $stream = $pubEntry.Open()
    $reader = New-Object System.IO.StreamReader($stream)
    $pubJson = $reader.ReadToEnd() | ConvertFrom-Json
    $reader.Close()
    $pubEntry.Delete()
    
    $pubJson.AppName = "Helpdesk_KB_Portal"
    $newPubEntry = $zip.CreateEntry('msapp\Resources\PublishInfo.json')
    $pubWriter = New-Object System.IO.StreamWriter($newPubEntry.Open(), [System.Text.Encoding]::UTF8)
    $pubWriter.Write(($pubJson | ConvertTo-Json -Compress))
    $pubWriter.Flush()
    $pubWriter.Close()
}

# 4. Remove Controls/4.json and Controls/41.json (the old screens)
Remove-MatchingEntries $zip "*Controls\4.json*"
Remove-MatchingEntries $zip "*Controls/4.json*"
Remove-MatchingEntries $zip "*Controls\41.json*"
Remove-MatchingEntries $zip "*Controls/41.json*"

$zip.Dispose()
Write-Output "Test msapr prepared successfully."
