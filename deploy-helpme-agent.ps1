<#
    Deploy HelpMe Agent (Microsoft Copilot Studio) to the Deves Insurance environment.

    วิธีใช้:
      1) เปิด PowerShell (Terminal ใหม่)
      2) รัน:  powershell -ExecutionPolicy Bypass -File "e:\DVS\Project\Aiagent_Helpme\deploy-helpme-agent.ps1"
      3) ทำตามขั้นตอน login (Device Code) ที่หน้าจอบอก
      4) ยืนยันการ Publish เมื่อสคริปต์ถาม

    ขั้นตอนภายใน: auth (ถ้ายังไม่ได้ login) -> push (อัปโหลดการแก้ไข local) -> publish (ทำให้ agent เวอร์ชันใหม่ออก live)
#>

$ErrorActionPreference = 'Stop'
$ProgressPreference    = 'SilentlyContinue'

# ---- ค่าคงที่ของโปรเจกต์นี้ ----
$Pac         = "$env:USERPROFILE\pac-cli\extracted\tools\pac.exe"
$ProjectDir  = "e:\DVS\Project\Aiagent_Helpme\HelpMe Agent"
$EnvUrl      = "https://devesinsurancedefault.crm5.dynamics.com/"
$BotId       = "76812e27-6dce-f011-8544-6045bd592e11"   # AgentId (จาก .mcs\conn.json)
$BotSchema   = "cr616_helpMeAgentUat"                    # ใช้แทน BotId ได้ถ้าต้องการ

if (-not (Test-Path $Pac)) {
    Write-Host "ไม่พบ pac.exe ที่ $Pac — โปรดติดตั้ง Power Platform CLI ก่อน" -ForegroundColor Red
    exit 1
}

Write-Host "== HelpMe Agent Deploy ==" -ForegroundColor Cyan
& $Pac copilot help > $null 2>&1

# ---- 1) Auth ----
$profiles = & $Pac auth list 2>&1 | Out-String
if ($profiles -match "No profiles were found") {
    Write-Host "`n[1/3] ยังไม่มี auth profile — กำลังเริ่ม login แบบ Device Code..." -ForegroundColor Yellow
    Write-Host "     จะมีรหัสและลิงก์ให้เปิดใน browser แล้ว login ด้วยบัญชี teerapat.ti@deves.co.th" -ForegroundColor Yellow
    & $Pac auth create --name HelpMeDeves --environment $EnvUrl --deviceCode
} else {
    Write-Host "`n[1/3] พบ auth profile อยู่แล้ว:" -ForegroundColor Green
    & $Pac auth who
    Write-Host "     (ถ้าต้องการเปลี่ยนบัญชี ให้รัน: pac auth create --environment $EnvUrl --deviceCode)" -ForegroundColor DarkGray
}

# ---- 2) Push ----
Write-Host "`n[2/3] Push การแก้ไข local ขึ้น Copilot Studio ..." -ForegroundColor Yellow
& $Pac copilot push --project-dir $ProjectDir
Write-Host "     Push เสร็จแล้ว" -ForegroundColor Green

# ---- 3) Publish (production) — ยืนยันก่อน ----
Write-Host "`n[3/3] ขั้นตอน Publish จะทำให้ agent เวอร์ชันใหม่ออก LIVE บน production" -ForegroundColor Magenta
$confirm = Read-Host "พิมพ์  yes  เพื่อยืนยัน Publish (อย่างอื่น = ยกเลิก)"
if ($confirm -eq 'yes') {
    & $Pac copilot publish --environment $EnvUrl --bot $BotId
    Write-Host "`nPublish สำเร็จ 🎉  ตรวจสอบสถานะได้ด้วย: pac copilot status --bot $BotId" -ForegroundColor Green
} else {
    Write-Host "`nยกเลิกการ Publish — การแก้ไขถูก push ขึ้นแล้ว แต่ยังไม่ออก live (คุณ publish เองภายหลังได้)" -ForegroundColor Yellow
}
