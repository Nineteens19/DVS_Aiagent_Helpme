Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead('E:\DVS\Project\Aiagent_Helpme\Helpdesk_KB_Portal.msapp')
$e = $zip.GetEntry('References/DataSources.json')
if ($null -eq $e) { $e = $zip.GetEntry('References\DataSources.json') }
$stream = $e.Open()
$reader = New-Object System.IO.StreamReader($stream)
$json = $reader.ReadToEnd() | ConvertFrom-Json
$json.DataSources | ForEach-Object { Write-Output "msapp DS: $($_.Name)" }
$reader.Close()
$zip.Dispose()
