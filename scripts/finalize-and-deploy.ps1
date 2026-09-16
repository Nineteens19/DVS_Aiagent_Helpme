<#
    Finalize & deploy foundation (helpdesk-agent) — รันหลังจาก login m365 + pac แล้ว
    ----------------------------------------------------------------------------------
    ทำอัตโนมัติ:
      1) provision SharePoint lists (เรียก provision-sharepoint.ps1)
      2) อ่าน GUID ของแต่ละ list กลับมา
      3) สร้าง workflow.json ของ CreateCaseAndAck จาก DRAFT-workflow.md (แทน @@..@@ ด้วย GUID จริง)
      4) สร้าง metadata.yml (GUID ใหม่)
      5) pac copilot push (+ publish ถ้าใส่ -Publish)

    ต้อง login ก่อน:
      & "C:\Program Files\node-v24.15.0-win-x64\m365.cmd" login --appId <APPID> --authType deviceCode
      & "$env:USERPROFILE\pac-cli\extracted\tools\pac.exe" auth create --environment <EnvUrl> --deviceCode

    ตัวอย่างรัน:
      powershell -ExecutionPolicy Bypass -File .\scripts\finalize-and-deploy.ps1 -AdminEmail "helpdesk-admin@deves.co.th"
      (เพิ่ม -Publish เพื่อ publish ขึ้น production, -SkipProvision ถ้า provision แล้ว)
#>
param(
    [string]$SiteUrl   = "https://dvsins.sharepoint.com/sites/PowerAppPRD",
    [string]$EnvUrl    = "https://devesinsurancedefault.crm5.dynamics.com/",
    [string]$AdminEmail = "",
    [switch]$Publish,
    [switch]$SkipProvision,
    [switch]$AddRoutingOwnerTeam
)
$ErrorActionPreference = 'Stop'
$root    = Split-Path $PSScriptRoot -Parent
$m365    = "C:\Program Files\node-v24.15.0-win-x64\m365.cmd"
$pac     = "$env:USERPROFILE\pac-cli\extracted\tools\pac.exe"
$agentDir = Join-Path $root "HelpMe Agent"
$flowDir  = Join-Path $agentDir "workflows\CreateCaseAndAck"
$draftMd  = Join-Path $flowDir "DRAFT-workflow.md"

if (-not (Test-Path $m365)) { throw "ไม่พบ m365 CLI" }
if (-not (Test-Path $pac))  { throw "ไม่พบ pac.exe" }
if (-not (Test-Path $draftMd)) { throw "ไม่พบ $draftMd" }
if (-not $AdminEmail) { $AdminEmail = Read-Host "ใส่ admin email สำหรับแจ้ง flow error" }

# ---- 0) ตรวจ login m365 ----
Write-Host "== ตรวจ m365 login ==" -ForegroundColor Cyan
$st = cmd /c "`"$m365`" status 2>&1"
if ($st -match "Logged out" -or $st -match "not logged in") { throw "m365 ยังไม่ได้ login — รัน: & `"$m365`" login --appId <APPID> --authType deviceCode" }
Write-Host $st

# ---- 1) provision ----
if (-not $SkipProvision) {
    Write-Host "`n== Provision SharePoint lists ==" -ForegroundColor Cyan
    $provArgs = @("-File", (Join-Path $PSScriptRoot "provision-sharepoint.ps1"), "-SiteUrl", $SiteUrl)
    if ($AddRoutingOwnerTeam) { $provArgs += "-AddRoutingOwnerTeam" }
    powershell -ExecutionPolicy Bypass @provArgs
}

# ---- 2) อ่าน GUID ----
function Get-ListId([string]$Title) {
    $j = cmd /c "`"$m365`" spo list get --webUrl `"$SiteUrl`" --title `"$Title`" --output json 2>&1"
    try { return ($j | ConvertFrom-Json).Id } catch { throw "อ่าน GUID ของ list '$Title' ไม่ได้: $j" }
}
Write-Host "`n== อ่าน list GUIDs ==" -ForegroundColor Cyan
$casesId = Get-ListId "Cases"
$slaId   = Get-ListId "SLAConfig"
$gapId   = Get-ListId "KnowledgeGaps"
$errId   = Get-ListId "ErrorLog"
Write-Host "Cases=$casesId`nSLAConfig=$slaId`nKnowledgeGaps=$gapId`nErrorLog=$errId"

# ---- 3) สร้าง workflow.json จาก DRAFT ----
Write-Host "`n== สร้าง workflow.json ==" -ForegroundColor Cyan
$md = Get-Content $draftMd -Raw
$m = [regex]::Match($md, '(?s)```json\s*(.*?)```')
if (-not $m.Success) { throw "ไม่พบบล็อก json ใน DRAFT-workflow.md" }
$json = $m.Groups[1].Value
$json = $json.Replace('@@CASES_LIST_GUID@@', $casesId).
              Replace('@@SLACONFIG_LIST_GUID@@', $slaId).
              Replace('@@KNOWLEDGEGAPS_LIST_GUID@@', $gapId).
              Replace('@@ERRORLOG_LIST_GUID@@', $errId).
              Replace('@@ADMIN_EMAIL@@', $AdminEmail)
# validate JSON
$null = $json | ConvertFrom-Json
Set-Content -Path (Join-Path $flowDir "workflow.json") -Value $json -Encoding UTF8
Write-Host "เขียน workflow.json แล้ว"

# ---- 4) metadata.yml ----
$newGuid = [guid]::NewGuid().ToString()
$meta = @"
jsonFileName: workflows/CreateCaseAndAck/workflow.json
workflowId: $newGuid
name: CreateCaseAndAck
type: 1
description: helpdesk-agent - create case + acknowledgment + team notify + error handling
subprocess: false
category: 5
mode: 0
scope: 4
onDemand: false
triggerOnCreate: false
triggerOnDelete: false
asyncAutodelete: false
syncWorkflowLogOnFailure: false
stateCode: 1
statusCode: 2
runAs: 1
isTransacted: true
introducedVersion: 1.0
isCustomizable:
  value: true
  canBeChanged: true
  managedPropertyLogicalName: iscustomizableanddeletable
businessProcessType: 0
modernFlowType: 1
primaryEntity: none
connectionReferences:
- cr616_helpMeAgentUat.cr.KjQFMKAz
- new_sharedoffice365_71ca1
"@
Set-Content -Path (Join-Path $flowDir "metadata.yml") -Value $meta -Encoding UTF8
Write-Host "เขียน metadata.yml (workflowId=$newGuid) แล้ว"

# ---- 5) push / publish ----
Write-Host "`n== pac copilot push ==" -ForegroundColor Cyan
& $pac copilot push --project-dir "$agentDir"
if ($Publish) {
    Write-Host "`n== pac copilot publish (PRODUCTION) ==" -ForegroundColor Magenta
    $c = Read-Host "พิมพ์ yes เพื่อยืนยัน publish"
    if ($c -eq 'yes') { & $pac copilot publish --environment $EnvUrl } else { Write-Host "ข้าม publish" -ForegroundColor Yellow }
}
Write-Host "`nเสร็จสิ้น." -ForegroundColor Green
