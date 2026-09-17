Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead('E:\DVS\Project\Aiagent_Helpme\Helpdesk_KB_Portal\Helpdesk_KB_Portal.msapr')
$e = $zip.GetEntry('msapr-header.json')
$stream = $e.Open()
$reader = New-Object System.IO.StreamReader($stream)
Write-Output $reader.ReadToEnd()
$reader.Close()
$zip.Dispose()
