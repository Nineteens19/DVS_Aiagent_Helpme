# Setup & Deploy Guide — helpdesk-agent (foundation)

เครื่องมือทั้งหมดที่ต้องใช้ + ลำดับการรัน (สรุปให้ครบในที่เดียว)

## เครื่องมือ (ตรวจแล้วในเครื่องนี้)
| Tool | สถานะ | ใช้ทำ |
|------|-------|-------|
| **pac** (Power Platform CLI) | ✅ ติดตั้งแล้ว | push/publish agent + flows |
| **m365** (CLI for Microsoft 365) v11 | ✅ ติดตั้งแล้ว (`C:\Program Files\node-v24.15.0-win-x64\m365.cmd`) | สร้าง SharePoint lists/fields, อ่าน GUID |
| node/npm | ✅ | ใช้ติดตั้ง m365 |

> ไม่จำเป็นต้องใช้ PnP.PowerShell (เครื่องนี้เป็น PowerShell 5.1, PnP รุ่นใหม่ต้องการ PS7) — ใช้ m365 CLI แทนได้ครบ

## สิ่งที่ "เฉพาะคุณ" ต้องทำ (ผมทำแทนไม่ได้)
### A) pac login (ไม่ต้อง register app) — กำลังทำอยู่
ผมรัน `pac auth create --deviceCode` ให้แล้ว → เปิด https://microsoft.com/devicelogin กรอกรหัสที่ผมส่งให้ในแชท (ล็อกอินด้วย `teerapat.ti@deves.co.th`)

### B) Entra app registration (สำหรับ m365 — ทำครั้งเดียว)
m365 CLI v11 ต้องใช้ app ของ tenant เอง:
1. https://entra.microsoft.com → **App registrations → New registration**
   - Name: `CLI-m365-Helpdesk` ; Accounts: **Single tenant**
2. **Authentication** → เปิด **Allow public client flows = Yes**
3. **API permissions → Add** → **SharePoint › Delegated › AllSites.Manage** (+ **Microsoft Graph › Delegated › User.Read**) → **Grant admin consent**
4. คัดลอก **Application (client) ID** และ **Directory (tenant) ID**
5. Login:
   ```
   & "C:\Program Files\node-v24.15.0-win-x64\m365.cmd" login --appId <CLIENT_ID> --tenant <TENANT_ID> --authType deviceCode
   ```
   แล้วกรอก device code (จะได้ลิงก์/รหัสบนจอ)

## จากนั้น (ผมช่วยขับต่อได้ หรือคุณรันเอง)
### C) Dry-run ดูว่าจะสร้าง list อะไรบ้าง (ไม่เขียนจริง)
```
powershell -ExecutionPolicy Bypass -File .\scripts\provision-sharepoint.ps1 -WhatIf
```
### D) รันจริงครบชุด (provision → อ่าน GUID → สร้าง workflow.json → push)
```
powershell -ExecutionPolicy Bypass -File .\scripts\finalize-and-deploy.ps1 -AdminEmail "your-admin@deves.co.th"
```
เพิ่ม `-Publish` เพื่อ publish ขึ้น production (จะถามยืนยันอีกครั้ง), `-AddRoutingOwnerTeam` เพื่อเพิ่มคอลัมน์ OwnerTeam ใน Routing

## ข้อควรระวัง
- สร้างเฉพาะ list ใหม่บน **PowerAppPRD** — ไม่แตะ list ทีมอื่น
- **KnowledgeBase** (site BusinessAnalystandHelpdesk) = ของทีมอื่น, read-only เท่านั้น
- แนะนำ `-WhatIf` และทดสอบใน UAT ก่อน `-Publish`

## Troubleshooting

### AADSTS650056: Misconfigured application (ตอน m365 login)
สาเหตุ: app registration ขาด API permission (โดยเฉพาะ **Microsoft Graph**) หรือยังไม่ได้ **admin consent**

แก้ที่ app (client ID ที่ขึ้นใน error เช่น `d514ef9a-...`):
1. **API permissions** ต้องมี (Delegated):
   - **Microsoft Graph › `User.Read`**  ← ถ้าขาดตัวนี้จะเจอ error นี้ (m365 ขอ Graph ตอน sign-in)
   - **SharePoint › `AllSites.Manage`**  (สร้าง/แก้ list, field, view)
2. กด **Grant admin consent for [tenant]** → ต้องเป็นเครื่องหมายถูกเขียวทุกแถว (ถ้ากดไม่ได้ ให้ admin กดให้)
3. **Authentication → Allow public client flows = Yes**
4. รอ 1–2 นาที แล้ว login ใหม่ด้วย `--appId <id> --tenant <tenantId> --authType deviceCode`

หา TENANT_ID: entra.microsoft.com → Overview → Tenant ID; หรือถ้า pac login แล้ว: `& "$env:USERPROFILE\pac-cli\extracted\tools\pac.exe" auth list`

### ทางเลือกถ้า app registration ติดปัญหา admin consent
- ให้ทีม IT/Admin ที่ดูแล Entra เป็นคนสร้าง app + consent ให้ (ส่ง 3 ค่านี้ให้เขา: ชื่อ app, permission = Graph User.Read + SharePoint AllSites.Manage, public client flows = Yes) แล้วส่ง Client ID + Tenant ID กลับมา
- หรือถ้าติดจริง ๆ: สร้าง SharePoint lists **ด้วยมือ**ผ่านเบราว์เซอร์ตาม schema ใน `foundation.md` แล้วใช้แค่ `pac` deploy ฝั่ง agent/flow (ผมช่วยเตรียม schema/คู่มือ list ให้ได้)
