Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$baseDir = 'E:\DVS\Project\Aiagent_Helpme\Monitor_case_Helpdesk'
$msaprPath = "$baseDir\Monitor_case_Helpdesk.msapr"
$msappPath = 'E:\DVS\Project\Aiagent_Helpme\Monitor_case_Helpdesk.msapp'

Write-Output "Step 1: Removing obsolete loose Controls 4.json and 41.json..."
if (Test-Path "$baseDir\Controls\4.json") { Remove-Item "$baseDir\Controls\4.json" -Force }
if (Test-Path "$baseDir\Controls\41.json") { Remove-Item "$baseDir\Controls\41.json" -Force }

Write-Output "Step 2: Updating Controls/1.json OnStart..."
$ctrl1Path = "$baseDir\Controls\1.json"
$ctrl1Json = Get-Content $ctrl1Path -Raw -Encoding UTF8 | ConvertFrom-Json
$onStartRule = $ctrl1Json.TopParent.Rules | Where-Object { $_.Property -eq "OnStart" }
if ($onStartRule) {
    $onStartRule.InvariantScript = @"
Set(
    varCurrentUser,
    {
        Email: User().Email,
        FullName: User().FullName,
        Image: User().Image
    }
);
ClearCollect(
    colRoutingSystems,
    Distinct(Routing, SystemName)
);
Set(varSelectedStatus, "All");
Set(varShowDrawer, false);
Set(varSelectedCase, Blank());
Set(varActiveKPIFilter, "");
Set(varSearchQuery, "");
Set(varSelectedSystem, "");
Set(varLastRefreshedTime, Now());
Set(varShowAssignModal, false);
Set(varAssignSelectedUser, Blank());
Set(varAssignNote, "");
Set(varSendAssignEmail, true);
Set(gblColorPrimary, ColorValue("#012169"));
Set(gblColorPrimaryHover, ColorValue("#0A3590"));
Set(gblColorSecondary, ColorValue("#FFCD00"));
Set(gblColorBg, ColorValue("#F8F9FA"));
Set(gblColorSurface, ColorValue("#FFFFFF"));
Set(gblColorBorder, ColorValue("#E2E8F0"));
Set(gblColorTextPrimary, ColorValue("#0F172A"));
Set(gblColorTextSecondary, ColorValue("#64748B"));
Set(gblColorOpenBg, ColorValue("#F1F5F9"));
Set(gblColorOpenText, ColorValue("#475569"));
Set(gblColorInProgBg, ColorValue("#FEF3C7"));
Set(gblColorInProgText, ColorValue("#B45309"));
Set(gblColorResolvedBg, ColorValue("#D1FAE5"));
Set(gblColorResolvedText, ColorValue("#047857"));
Set(gblColorSlaBreachBg, ColorValue("#FFE4E6"));
Set(gblColorSlaBreachText, ColorValue("#BE123C"));
ClearCollect(
    colDevesTheme,
    {
        Primary: RGBA(1, 33, 105, 1),
        Secondary: RGBA(255, 205, 0, 1),
        Background: RGBA(248, 249, 250, 1),
        Success: RGBA(40, 167, 69, 1),
        Danger: RGBA(220, 53, 69, 1),
        Warning: RGBA(253, 126, 20, 1),
        Info: RGBA(23, 162, 184, 1),
        Text: RGBA(33, 37, 41, 1),
        TextMuted: RGBA(108, 117, 125, 1),
        Border: RGBA(222, 226, 230, 1)
    }
);
"@
}
$ctrl1Json | ConvertTo-Json -Depth 20 | Set-Content $ctrl1Path -Encoding UTF8

Write-Output "Step 3: Updating Monitor_case_Helpdesk.msapr internal package..."
if (Test-Path $msaprPath) {
    $zip = [System.IO.Compression.ZipFile]::Open($msaprPath, [System.IO.Compression.ZipArchiveMode]::Update)

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

    # 3a. Clean any loose Src entries (these belong on the filesystem for pac pack)
    Remove-MatchingEntries $zip "*Src*"
    Remove-MatchingEntries $zip "*pa.yaml*"

    # 3b. Remove obsolete screen controls 4.json, 41.json
    Remove-MatchingEntries $zip "*Controls\4.json*"
    Remove-MatchingEntries $zip "*Controls/4.json*"
    Remove-MatchingEntries $zip "*Controls\41.json*"
    Remove-MatchingEntries $zip "*Controls/41.json*"

    # 3c. Replace Controls\1.json
    Remove-MatchingEntries $zip "*Controls\1.json*"
    Remove-MatchingEntries $zip "*Controls/1.json*"
    $c1Entry = $zip.CreateEntry('msapp\Controls\1.json')
    $c1Writer = New-Object System.IO.StreamWriter($c1Entry.Open(), [System.Text.Encoding]::UTF8)
    $c1Content = [System.IO.File]::ReadAllText($ctrl1Path, [System.Text.Encoding]::UTF8)
    $c1Writer.Write($c1Content)
    $c1Writer.Flush()
    $c1Writer.Close()

    # 3d. Replace DataSources.json
    Remove-MatchingEntries $zip "*DataSources.json*"
    $dsEntry = $zip.CreateEntry('msapp\References\DataSources.json')
    $dsWriter = New-Object System.IO.StreamWriter($dsEntry.Open(), [System.Text.Encoding]::UTF8)
    $dsContent = [System.IO.File]::ReadAllText("$baseDir\References\DataSources.json", [System.Text.Encoding]::UTF8)
    $dsWriter.Write($dsContent)
    $dsWriter.Flush()
    $dsWriter.Close()

    # 3e. Replace Properties.json
    Remove-MatchingEntries $zip "*Properties.json*"
    $propEntry = $zip.CreateEntry('msapp\Properties.json')
    $propWriter = New-Object System.IO.StreamWriter($propEntry.Open(), [System.Text.Encoding]::UTF8)
    $propContent = [System.IO.File]::ReadAllText("$baseDir\Properties.json", [System.Text.Encoding]::UTF8)
    $propWriter.Write($propContent)
    $propWriter.Flush()
    $propWriter.Close()

    $zip.Dispose()
    Write-Output "Successfully synced Monitor_case_Helpdesk.msapr."
} else {
    Write-Output "Monitor_case_Helpdesk.msapr does not exist, skipping."
}
