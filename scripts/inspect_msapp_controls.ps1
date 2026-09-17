Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead('E:\DVS\Project\Aiagent_Helpme\Helpdesk_KB_Portal.msapp')
foreach ($e in $zip.Entries) {
    if ($e.FullName -like 'Controls\*') {
        $stream = $e.Open()
        $reader = New-Object System.IO.StreamReader($stream)
        $txt = $reader.ReadToEnd()
        $json = $txt | ConvertFrom-Json
        Write-Output "$($e.FullName): TopParent Name = $($json.TopParent.Name), Type = $($json.TopParent.Type)"
        $reader.Close()
    }
}
$zip.Dispose()
