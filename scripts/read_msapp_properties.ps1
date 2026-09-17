Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead('E:\DVS\Project\Aiagent_Helpme\Helpdesk_KB_Portal.msapp')
$e = $zip.GetEntry('Properties.json')
$stream = $e.Open()
$reader = New-Object System.IO.StreamReader($stream)
$json = $reader.ReadToEnd() | ConvertFrom-Json
Write-Output "msapp App Name: $($json.Name)"
Write-Output "msapp LocalConnectionReferences: $($json.LocalConnectionReferences)"
$reader.Close()
$zip.Dispose()
