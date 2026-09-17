# Prepare clean import CSV for new SharePoint List AI_KnowledgeBase
$srcPath = "e:\DVS\Project\Aiagent_Helpme\AI_KnowledgeBase_Helpdesk_export\AI_KnowledgeBase_Helpdesk.csv"
$dstPath = "e:\DVS\Project\Aiagent_Helpme\AI_KnowledgeBase_Import_Ready.csv"

$src = Import-Csv -Path $srcPath -Encoding utf8
Write-Host "Read $($src.Count) rows from $srcPath"

$cleaned = foreach ($row in $src) {
    [PSCustomObject]@{
        "KB_ID"                = $row.KB_ID
        "Title"                = $row.KB_ID
        "Issue_Title"          = $row.Issue_Title
        "System"               = $row.System
        "Category"             = $row.Category
        "Keywords"             = $row.Keywords
        "Approved_Answer"      = $row.Approved_Answer
        "Required_Information" = $row.Required_Information
        "Followup_Question"    = $row.Followup_Question
        "Action_Type"          = $row.Action_Type
        "Escalation_Rule"      = $row.Escalation_Rule
        "Owner"                = $row.Owner
        "Review_Status"        = "Approved"
        "Is_Active"            = "Active"
    }
}

# Export with UTF8 (with BOM so Excel opens Thai correctly)
$utf8WithBom = New-Object System.Text.UTF8Encoding $true
$csvContent = ($cleaned | ConvertTo-Csv -NoTypeInformation) -join "`r`n"
[System.IO.File]::WriteAllText($dstPath, $csvContent, $utf8WithBom)

Write-Host "Successfully generated clean import file: $dstPath with $($cleaned.Count) rows"
