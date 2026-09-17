Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead('E:\DVS\Project\Aiagent_Helpme\Helpdesk_KB_Portal.msapp')
$e = $zip.GetEntry('packed.json')
$stream = $e.Open()
$reader = New-Object System.IO.StreamReader($stream)
Write-Output $reader.ReadToEnd()
$reader.Close()
$zip.Dispose()
