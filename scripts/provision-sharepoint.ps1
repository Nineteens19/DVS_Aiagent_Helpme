<#
    Provision SharePoint lists for HelpMe Agent (helpdesk-agent foundation)
    ------------------------------------------------------------------------
    สร้างเฉพาะ list ใหม่ของ solution นี้บน PowerAppPRD:
        Cases, SLAConfig, KnowledgeGaps, ErrorLog
    ไม่แตะ:
        - list ของทีมอื่นบน PowerAppPRD
        - KnowledgeBase (AI_KnowledgeBase_Helpdesk) ที่ site BusinessAnalystandHelpdesk = ของทีมอื่น (read-only)
        - Routing (มีอยู่แล้ว) — เพิ่มคอลัมน์ OwnerTeam เฉพาะเมื่อใส่ -AddRoutingOwnerTeam

    วิธีใช้:
        1) login ก่อน (ครั้งเดียว, device code):
             & "C:\Program Files\node-v24.15.0-win-x64\m365.cmd" login
        2) ตรวจว่าจะทำอะไร (ไม่เขียนจริง):
             powershell -ExecutionPolicy Bypass -File .\scripts\provision-sharepoint.ps1 -WhatIf
        3) รันจริง:
             powershell -ExecutionPolicy Bypass -File .\scripts\provision-sharepoint.ps1
#>
param(
    [string]$SiteUrl = "https://dvsins.sharepoint.com/sites/PowerAppPRD",
    [switch]$WhatIf,
    [switch]$AddRoutingOwnerTeam
)

$ErrorActionPreference = 'Stop'
$m365 = "C:\Program Files\node-v24.15.0-win-x64\m365.cmd"
if (-not (Test-Path $m365)) {
    $prefix = (cmd /c "npm config get prefix").Trim()
    $m365 = Join-Path $prefix "m365.cmd"
}
if (-not (Test-Path $m365)) { throw "ไม่พบ m365 CLI — ติดตั้งด้วย: npm i -g @pnp/cli-microsoft365" }

function Invoke-M365 { param([string]$ArgLine)
    if ($WhatIf) { Write-Host "  [WhatIf] m365 $ArgLine" -ForegroundColor DarkGray; return }
    cmd /c "`"$m365`" $ArgLine 2>&1"
    if ($LASTEXITCODE -ne 0) { Write-Host "  ! คำสั่งล้มเหลว (อาจมีอยู่แล้ว): m365 $ArgLine" -ForegroundColor Yellow }
}

# ---- ตรวจสถานะ login ----
Write-Host "== ตรวจสถานะ login ==" -ForegroundColor Cyan
$status = cmd /c "`"$m365`" status 2>&1"
Write-Host $status
if ($status -match "Logged out" -or $status -match "not logged in") {
    throw "ยังไม่ได้ login — รัน: & `"$m365`" login  (แล้วกรอก device code)"
}

Write-Host "`n== Target site: $SiteUrl ==" -ForegroundColor Cyan
if ($WhatIf) { Write-Host "(โหมด WhatIf — แสดงคำสั่งเท่านั้น ไม่เขียนจริง)" -ForegroundColor Yellow }

function Ensure-List { param([string]$Title, [string]$Desc)
    Write-Host "`n-- List: $Title --" -ForegroundColor Green
    Invoke-M365 "spo list add --webUrl `"$SiteUrl`" --title `"$Title`" --baseTemplate GenericList --description `"$Desc`""
}
function Add-Field { param([string]$List, [string]$Xml)
    Invoke-M365 "spo field add --webUrl `"$SiteUrl`" --listTitle `"$List`" --xml `"$Xml`""
}

# ============ Cases ============
Ensure-List -Title "Cases" -Desc "Helpdesk cases (consolidated)"
Add-Field "Cases" "<Field Type='Text' DisplayName='CaseID' Name='CaseID' />"
Add-Field "Cases" "<Field Type='Choice' DisplayName='CaseType' Name='CaseType'><CHOICES><CHOICE>Incident</CHOICE><CHOICE>Service Request</CHOICE><CHOICE>Business Support</CHOICE><CHOICE>Access</CHOICE></CHOICES></Field>"
Add-Field "Cases" "<Field Type='Text' DisplayName='SystemName' Name='SystemName' />"
Add-Field "Cases" "<Field Type='Text' DisplayName='Category' Name='Category' />"
Add-Field "Cases" "<Field Type='Choice' DisplayName='Priority' Name='Priority'><CHOICES><CHOICE>ปกติ</CHOICE><CHOICE>ด่วน</CHOICE></CHOICES></Field>"
Add-Field "Cases" "<Field Type='Choice' DisplayName='Severity' Name='Severity'><CHOICES><CHOICE>P1</CHOICE><CHOICE>P2</CHOICE><CHOICE>P3</CHOICE></CHOICES></Field>"
Add-Field "Cases" "<Field Type='Note' DisplayName='ProblemDetail' Name='ProblemDetail' NumLines='6' RichText='FALSE' />"
Add-Field "Cases" "<Field Type='Note' DisplayName='IssueSummary' Name='IssueSummary' NumLines='4' RichText='FALSE' />"
Add-Field "Cases" "<Field Type='Note' DisplayName='ConversationSummary' Name='ConversationSummary' NumLines='6' RichText='FALSE' />"
Add-Field "Cases" "<Field Type='Text' DisplayName='KBRef' Name='KBRef' />"
Add-Field "Cases" "<Field Type='Text' DisplayName='Username' Name='Username' />"
Add-Field "Cases" "<Field Type='Text' DisplayName='ReporterName' Name='ReporterName' />"
Add-Field "Cases" "<Field Type='Text' DisplayName='ReporterEmail' Name='ReporterEmail' />"
Add-Field "Cases" "<Field Type='Text' DisplayName='ReporterTel' Name='ReporterTel' />"
Add-Field "Cases" "<Field Type='Choice' DisplayName='Statuscase' Name='Statuscase'><CHOICES><CHOICE>Open</CHOICE><CHOICE>In Progress</CHOICE><CHOICE>Resolved</CHOICE><CHOICE>Closed</CHOICE></CHOICES><Default>Open</Default></Field>"
Add-Field "Cases" "<Field Type='Text' DisplayName='AssignedOwner' Name='AssignedOwner' />"
Add-Field "Cases" "<Field Type='DateTime' DisplayName='SlaDueDate' Name='SlaDueDate' Format='DateTime' />"
Add-Field "Cases" "<Field Type='Text' DisplayName='LastNotifiedStatus' Name='LastNotifiedStatus' />"
Add-Field "Cases" "<Field Type='DateTime' DisplayName='ResolvedAt' Name='ResolvedAt' Format='DateTime' />"

# ============ SLAConfig ============
Ensure-List -Title "SLAConfig" -Desc "SLA thresholds by severity"
Add-Field "SLAConfig" "<Field Type='Choice' DisplayName='Severity' Name='Severity'><CHOICES><CHOICE>P1</CHOICE><CHOICE>P2</CHOICE><CHOICE>P3</CHOICE></CHOICES></Field>"
Add-Field "SLAConfig" "<Field Type='Number' DisplayName='FirstResponseHours' Name='FirstResponseHours' />"
Add-Field "SLAConfig" "<Field Type='Number' DisplayName='ResolutionHours' Name='ResolutionHours' />"
Add-Field "SLAConfig" "<Field Type='Text' DisplayName='EscalateToCC' Name='EscalateToCC' />"

# ============ KnowledgeGaps ============
Ensure-List -Title "KnowledgeGaps" -Desc "Unanswered questions for KB improvement"
Add-Field "KnowledgeGaps" "<Field Type='Note' DisplayName='UserQuestion' Name='UserQuestion' NumLines='4' RichText='FALSE' />"
Add-Field "KnowledgeGaps" "<Field Type='Text' DisplayName='SystemGuess' Name='SystemGuess' />"
Add-Field "KnowledgeGaps" "<Field Type='Number' DisplayName='Frequency' Name='Frequency' />"
Add-Field "KnowledgeGaps" "<Field Type='Text' DisplayName='RelatedCaseID' Name='RelatedCaseID' />"
Add-Field "KnowledgeGaps" "<Field Type='Choice' DisplayName='Status' Name='GapStatus'><CHOICES><CHOICE>New</CHOICE><CHOICE>Reviewed</CHOICE><CHOICE>Added to KB</CHOICE><CHOICE>Rejected</CHOICE></CHOICES><Default>New</Default></Field>"

# ============ ErrorLog ============
Ensure-List -Title "ErrorLog" -Desc "Flow error log"
Add-Field "ErrorLog" "<Field Type='Text' DisplayName='FlowName' Name='FlowName' />"
Add-Field "ErrorLog" "<Field Type='Choice' DisplayName='ErrorCode' Name='ErrorCode'><CHOICES><CHOICE>CASE_001</CHOICE><CHOICE>ROUTE_001</CHOICE><CHOICE>EMAIL_001</CHOICE><CHOICE>SP_001</CHOICE><CHOICE>SLA_001</CHOICE></CHOICES></Field>"
Add-Field "ErrorLog" "<Field Type='Note' DisplayName='ErrorMessage' Name='ErrorMessage' NumLines='6' RichText='FALSE' />"
Add-Field "ErrorLog" "<Field Type='Note' DisplayName='ContextData' Name='ContextData' NumLines='6' RichText='FALSE' />"
Add-Field "ErrorLog" "<Field Type='DateTime' DisplayName='Timestamp' Name='ErrTimestamp' Format='DateTime' />"
Add-Field "ErrorLog" "<Field Type='Boolean' DisplayName='Notified' Name='Notified'><Default>0</Default></Field>"

# ============ Routing (optional, existing list) ============
if ($AddRoutingOwnerTeam) {
    Write-Host "`n-- Routing: เพิ่มคอลัมน์ OwnerTeam (ยืนยันแล้ว) --" -ForegroundColor Green
    Add-Field "Routing" "<Field Type='Text' DisplayName='OwnerTeam' Name='OwnerTeam' />"
} else {
    Write-Host "`n(ข้าม Routing — ใส่ -AddRoutingOwnerTeam หากต้องการเพิ่มคอลัมน์ OwnerTeam)" -ForegroundColor DarkGray
}

# ============ KnowledgeBase (external, read-only) ============
Write-Host "`n== KnowledgeBase ==" -ForegroundColor Cyan
Write-Host "  ไม่ดำเนินการ — อยู่ที่ site BusinessAnalystandHelpdesk และเป็นของทีมอื่น (read-only)" -ForegroundColor Yellow

Write-Host "`nเสร็จสิ้น. ตรวจผลได้ที่ $SiteUrl" -ForegroundColor Cyan
