Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead('E:\DVS\Project\Aiagent_Helpme\Helpdesk_KB_Portal\Helpdesk_KB_Portal.msapr')
foreach ($e in $zip.Entries) {
    if ($e.FullName -like '*DataSources.json*') {
        Write-Output "Found: $($e.FullName)"
        $stream = $e.Open()
        $reader = New-Object System.IO.StreamReader($stream)
        $json = $reader.ReadToEnd() | ConvertFrom-Json
        $json.DataSources | ForEach-Object { Write-Output "  DS: $($_.Name)" }
        $reader.Close()
    }
}
$zip.Dispose()
