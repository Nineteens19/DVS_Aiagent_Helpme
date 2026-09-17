Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

# 1. Create a copy of msapr to scratch/test.msapr
Copy-Item 'E:\DVS\Project\Aiagent_Helpme\Helpdesk_KB_Portal\Helpdesk_KB_Portal.msapr' 'E:\DVS\Project\Aiagent_Helpme\scratch\test.msapr' -Force

# 2. Open test.msapr and update entries
$zip = [System.IO.Compression.ZipFile]::Open('E:\DVS\Project\Aiagent_Helpme\scratch\test.msapr', [System.IO.Compression.ZipArchiveMode]::Update)

# Update msapp/References/DataSources.json
$dsEntry = $zip.GetEntry('msapp/References/DataSources.json')
if ($null -ne $dsEntry) { $dsEntry.Delete() }
$newDsEntry = $zip.CreateEntry('msapp/References/DataSources.json')
$dsWriter = New-Object System.IO.StreamWriter($newDsEntry.Open(), [System.Text.Encoding]::UTF8)
$dsContent = [System.IO.File]::ReadAllText('E:\DVS\Project\Aiagent_Helpme\Helpdesk_KB_Portal\References\DataSources.json', [System.Text.Encoding]::UTF8)
$dsWriter.Write($dsContent)
$dsWriter.Flush()
$dsWriter.Close()

# Update msapp/Properties.json
$propEntry = $zip.GetEntry('msapp/Properties.json')
if ($null -ne $propEntry) { $propEntry.Delete() }
$newPropEntry = $zip.CreateEntry('msapp/Properties.json')
$propWriter = New-Object System.IO.StreamWriter($newPropEntry.Open(), [System.Text.Encoding]::UTF8)
$propContent = [System.IO.File]::ReadAllText('E:\DVS\Project\Aiagent_Helpme\Helpdesk_KB_Portal\Properties.json', [System.Text.Encoding]::UTF8)
$propWriter.Write($propContent)
$propWriter.Flush()
$propWriter.Close()

# Update msapp/Resources/PublishInfo.json
$pubEntry = $zip.GetEntry('msapp/Resources/PublishInfo.json')
if ($null -ne $pubEntry) {
    $stream = $pubEntry.Open()
    $reader = New-Object System.IO.StreamReader($stream)
    $pubJson = $reader.ReadToEnd() | ConvertFrom-Json
    $reader.Close()
    $pubEntry.Delete()
    
    $pubJson.AppName = "Helpdesk_KB_Portal"
    $newPubEntry = $zip.CreateEntry('msapp/Resources/PublishInfo.json')
    $pubWriter = New-Object System.IO.StreamWriter($newPubEntry.Open(), [System.Text.Encoding]::UTF8)
    $pubWriter.Write(($pubJson | ConvertTo-Json -Compress))
    $pubWriter.Flush()
    $pubWriter.Close()
}

$zip.Dispose()
Write-Output "Successfully updated scratch/test.msapr"
