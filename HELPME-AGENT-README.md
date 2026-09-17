# HelpMe Agent — สรุประบบ Helpdesk + ระบบติดตามเคส

เอกสารสรุปสถาปัตยกรรม ส่วนประกอบ และวิธีดูแล/ต่อยอดของ **HelpMe Agent** (Microsoft Copilot Studio) สำหรับ Deves Insurance
อัปเดตล่าสุด: 2026-09-16

---

## 1. ภาพรวม

HelpMe Agent เป็นผู้ช่วย AI แบบ Helpdesk สำหรับพนักงาน/ตัวแทน ทำงาน 3 อย่างหลัก:

1. **ตอบคำถามจากฐานความรู้** (KB ที่อนุมัติแล้ว) ผ่าน topic `Search`
2. **เปิดเคส** เมื่อตอบไม่ได้/ผู้ใช้ขอเจ้าหน้าที่ → บันทึกลง SharePoint + ส่งอีเมลแจ้งทีม + ตอบรับผู้แจ้ง
3. **ติดตามเคส** — แจ้งเตือนอัตโนมัติทางอีเมล + ให้ผู้แจ้งเช็คสถานะเองผ่านแชท

### สภาพแวดล้อม
| รายการ | ค่า |
|--------|-----|
| Environment | Deves Insurance (default) — `https://devesinsurancedefault.crm5.dynamics.com/` |
| SharePoint site | `https://dvsins.sharepoint.com/sites/PowerAppPRD` |
| Agent (bot) | HelpMe Agent — id `76812e27-6dce-f011-8544-6045bd592e11` |
| Schema prefix | `cr616_helpMeAgentUat` |
| ภาษา UI/เนื้อหา | ไทย (locale 1054) |

---

## 2. สถาปัตยกรรม

```
[ผู้ใช้ (Teams / M365 Copilot)]
        │
        ▼
[HelpMe Agent — Copilot Studio]
        │
        ├── Search topic ──────────► ตอบจาก KB (SearchAndSummarizeContent)
        │
        ├── OpenCase / Escalate / v4K ──► InvokeFlow: NewcaseHelpDesk ──► สร้างเคส + อีเมล
        │        └── (สาขา "อื่นๆ") ──► InvokeFlow: GetSystems (รายชื่อระบบจาก Routing)
        │
        ├── CaseStatus topic ─────► InvokeFlow: GetCaseStatus ──► แสดงสถานะเคสของผู้ใช้
        │
        └── ReopenCase topic ─────► InvokeFlow: ReopenCase ──► เปิดเรื่องเคสเดิมใหม่

[Power Automate — flow อัตโนมัติ (ไม่ผ่าน agent)]
        ├── NotifyStatusChange (trigger: Cases ถูกแก้) ──► อีเมลผู้แจ้งเมื่อสถานะเปลี่ยน
        ├── RemindStaleCases (recurrence จ–ศ 09:00) ─────► เตือน owner เคสเกิน SLA / first-response
        └── AutoCloseResolved (recurrence จ–ศ 08:30) ────► ปิดเคส Resolved ที่เงียบ > 3 วัน

[SharePoint Lists] Cases · SLAConfig · KnowledgeGaps · ErrorLog · Routing · (KB read-only)
```

---

## 3. SharePoint Lists

Site: `PowerAppPRD` (ใช้ร่วมกับแอพอื่น — lists ของระบบนี้ตามด้านล่าง)

### 3.1 `Cases` — GUID `b8b22b0d-45c6-43c9-bc66-06e5e45b1237`
ตารางเก็บเคสทั้งหมด (รวม incident/service/access เป็นตารางเดียว)

| คอลัมน์ | ชนิด | หมายเหตุ |
|---------|------|----------|
| CaseID | Text | รูปแบบ `HD-{yyyyMMdd}-{itemID}` |
| CaseType | Choice | Incident / Service Request / Business Support / Access |
| SystemName | Text | ระบบที่พบปัญหา |
| Category | Text | |
| Priority | Choice | ปกติ / ด่วน |
| Severity | Choice | P1 / P2 / P3 |
| ProblemDetail | Note | รายละเอียดปัญหา |
| IssueSummary | Note | สรุปย่อ |
| ConversationSummary | Note | |
| KBRef | Text | KB_ID ที่เกี่ยวข้อง (ถ้ามี) |
| Username | Text | สำหรับเคส Access |
| ReporterName / ReporterEmail / ReporterTel | Text | ข้อมูลผู้แจ้ง |
| Statuscase | Choice | Open / In Progress / Resolved / Closed (+ แนะนำเพิ่ม Reopened / On Hold) |
| AssignedOwner | Text | อีเมลทีมผู้รับผิดชอบ |
| SlaDueDate | DateTime | กำหนดแก้ไข (resolution) |
| LastNotifiedStatus | Text | สถานะที่แจ้งผู้แจ้งล่าสุด (กันแจ้งซ้ำ) |
| ResolvedAt | DateTime | เวลาที่ Resolved |
| **StatusNote** | Note | หมายเหตุถึงผู้แจ้งต่อสถานะ *(เพิ่มโดย provisioning)* |
| **ClosedAt** | DateTime | เวลาปิดเคส *(เพิ่มโดย provisioning)* |
| **FirstResponseDueDate** | DateTime | กำหนดตอบกลับครั้งแรก *(เพิ่มโดย provisioning)* |
| **ReopenCount** | Number | จำนวนครั้งที่เปิดใหม่ *(เพิ่มโดย provisioning)* |

> **สำคัญ:** เพิ่ม choice `Reopened` และ `On Hold` ใน `Statuscase` (ยังไม่ได้เพิ่ม) เพื่อให้ ReopenCase/On Hold แสดงผลครบ — ตอนนี้ ReopenCase ตั้งค่าเป็น `Reopened` ถ้ายังไม่มี choice นี้อาจบันทึกไม่ได้ **แนะนำเพิ่มใน List settings**

### 3.2 `SLAConfig` — GUID `9c7bb698-4841-447e-aae4-5a43466771af`
| Severity | FirstResponseHours | ResolutionHours | EscalateToCC |
|----------|-------------------|-----------------|--------------|
| P1 | 1 | 4 | (temp) Teerapat.ti@deves.co.th |
| P2 | 4 | 24 | (temp) Teerapat.ti@deves.co.th |
| P3 | 8 | 48 | (temp) Teerapat.ti@deves.co.th |

### 3.3 `KnowledgeGaps` — GUID `9beb45a0-08e2-4717-8eee-5b80bd218005`
บันทึกคำถามที่ตอบไม่ได้ (feed การปรับปรุง KB): Title, UserQuestion, SystemGuess, Frequency, RelatedCaseID, GapStatus (New/Reviewed/Added to KB/Rejected)

### 3.4 `ErrorLog` — GUID `f6822ed6-ef24-4129-a56a-832d71c8312e`
บันทึก error ของ flow: FlowName, ErrorCode, ErrorMessage, ContextData, Timestamp, Notified

### 3.5 `Routing` — GUID `3d5264cb-65f6-4db5-8afa-fa68a6ea61e1` (list เดิม)
เป็น **master ของรายชื่อระบบ + ผู้รับผิดชอบ**: SystemName, ToNotifyBA, ToNotifySA, CCNotify
มีแถว `Helpdesk` เป็น fallback. ข้อมูลอีเมลปัจจุบันเป็น temp (Teerapat.ti@deves.co.th)

### 3.6 KnowledgeBase (`AI_KnowledgeBase_Helpdesk`)
อยู่คนละ site — **read-only** ใช้ตอบคำถาม ไม่ต้องเชื่อมกับเคสแบบ relationship (เชื่อมเชิง logic ผ่าน `Cases.KBRef` + `KnowledgeGaps`)

---

## 4. Flows (Power Automate)

| Flow | workflowId | Trigger | Connection runtime | หน้าที่ |
|------|-----------|---------|--------------------|---------|
| **NewcaseHelpDesk** | `15bbc09f-f01a-d621-d0ac-71a27363b2b5` | Request/Skills (agent เรียก) | invoker | สร้างเคสลง Cases + จำแนก CaseType/Priority/Severity + routing (+fallback) + คำนวณ SLA/FirstResponse + อีเมลทีม + ack ผู้แจ้ง + error handling → ErrorLog + เขียน KnowledgeGaps |
| **NotifyStatusChange** | `...032` | SharePoint: Cases แก้ไข (poll 3 นาที) | embedded | เมื่อ `Statuscase` ≠ `LastNotifiedStatus` → อีเมลผู้แจ้ง + ตอน Resolved แนบข้อความเชิญยืนยัน + อัปเดต LastNotifiedStatus/ResolvedAt/ClosedAt |
| **RemindStaleCases** | `...033` | Recurrence จ–ศ 09:00 | embedded | เตือน owner: (A5) เคสเกิน `SlaDueDate` + CC `EscalateToCC`; (A4) เคส Open เกิน `FirstResponseDueDate` |
| **AutoCloseResolved** | `...034` | Recurrence จ–ศ 08:30 | embedded | ปิดเคส Resolved ที่ `ResolvedAt` เกิน 3 วัน → `Closed` (NotifyStatusChange จะอีเมลแจ้งปิดต่อ) |
| **GetCaseStatus** | `...041` | Request/Skills | invoker | ค้นเคสตาม CaseID หรือ "เคสของฉัน" (กรอง `ReporterEmail`) → คืนข้อความสถานะ |
| **GetSystems** | `...042` | Request/Skills | invoker | คืนรายชื่อระบบจาก Routing (สำหรับ hint แบบ dynamic) |
| **ReopenCase** | `...043` | Request/Skills | invoker | ตั้ง `Statuscase=Reopened` + เพิ่ม ReopenCount + แจ้ง owner |

> `...032`–`...043` ย่อจาก prefix `7c1e2f30-1111-4aaa-bbbb-0000000000xx`

**กฎสำคัญของ connection:** flow ที่ trigger เป็น **Request** (Skills/Button) ใช้ `runtimeSource: invoker` ได้; flow ที่ trigger เป็น **Recurrence / SharePoint** ต้องใช้ `runtimeSource: embedded`

### Flow ที่เป็น Draft (ลบทิ้งได้ — ไม่ใช้งาน)
- `ProvisionHelpdeskData` (`...021`) — flow ชั่วคราวที่ใช้สร้างคอลัมน์ + seed ข้อมูล (ทำงานเสร็จแล้ว)
- `CreateCaseAndAck` (`9a28553f-...`) — flow ค้างจากช่วงออกแบบ (รวม logic ไป NewcaseHelpDesk แทน)

---

## 5. Topics (Copilot Studio)

| Topic | Trigger (ตัวอย่าง) | ทำอะไร |
|-------|-------------------|--------|
| `Search` | OnUnknownIntent | ตอบจาก KB |
| `OpenCase` / `Escalate` | "เปิดเคส", "ส่งเรื่องต่อ" | เก็บข้อมูล → เรียก NewcaseHelpDesk; สาขา "อื่นๆ" เรียก GetSystems แสดงรายชื่อระบบ |
| `v4K` | "แจ้งปัญหา", เมนูหลัก | เมนูแจ้งปัญหา/ปลดล็อค/สอบถาม → เรียก NewcaseHelpDesk |
| `CaseStatus` | "ติดตามเคส", "สถานะเคส", "เคสของฉัน" | เรียก GetCaseStatus |
| `ReopenCase` | "เคสเดิมยังไม่หาย", "เปิดเคสเดิมใหม่" | เรียก ReopenCase |

ทั้ง OpenCase/Escalate/v4K เรียก flow ผ่าน trigger inputs `text, text_1..text_6`
(`text`=ประเภท, `text_1`=email, `text_2`=ชื่อ, `text_3`=เบอร์, `text_4`=ระบบ, `text_5`=รายละเอียด, `text_6`=username)

---

## 6. วงจรสถานะเคส (lifecycle)

```
Open ──► In Progress ──► Resolved ──► Closed
  │                          │            ▲
  │ (เกิน FirstResponse)      │ (เงียบ 3 วัน) │ AutoCloseResolved
  │  → RemindStaleCases       └────────────┘
  │
  └─(ผู้แจ้งบอกยังไม่หาย)──► Reopened ──► In Progress ...
```
ทุกครั้งที่ `Statuscase` เปลี่ยน → `NotifyStatusChange` อีเมลแจ้งผู้แจ้งอัตโนมัติ

---

## 7. การ Deploy (สำคัญสำหรับการดูแลต่อ)

**ข้อจำกัดที่เจอ:** `pac copilot push` **แก้/สร้าง flow (cloud flow) ไม่ได้** — ทำได้แค่ topic/agent config
ดังนั้น:

| ส่วน | วิธี deploy |
|------|-------------|
| **Topics / agent config** | `pac copilot push --project-dir "HelpMe Agent"` |
| **Flows (สร้าง/แก้ definition)** | **Dataverse solution import** (`pac solution pack` + `pac solution import`) |

### Solutions ใน environment (publisher: HelpMeDeploy / prefix `hmdep`)
| Solution | บรรจุ flow |
|----------|-----------|
| `HelpMeFlowDeploy` | NewcaseHelpDesk |
| `HelpMeTracking` | NotifyStatusChange, RemindStaleCases, AutoCloseResolved |
| `HelpMeSelfService` | GetCaseStatus, ReopenCase, GetSystems |

### ขั้นตอนแก้ flow แล้ว deploy (สรุป)
1. แก้ definition (source เก็บที่ `_track/*.txt` และในโฟลเดอร์ workflow ของ agent)
2. `pac solution export --name <Solution>` → `pac solution unpack` → วาง definition ใหม่ในไฟล์ `Workflows/<Name>-<GUID>.json` → bump `<Version>` ใน `Other/Solution.xml`
3. `pac solution pack` → `pac solution import --publish-changes --force-overwrite`
4. **flow ที่ import มาจะถูกปิด (deactivate)** → ต้องเข้า Power Automate เปิด (Turn on) + ยืนยัน connection ใหม่ทุกครั้ง

> รูปแบบ workflow ใน solution: `RootComponent type="29"` ใน Solution.xml + ไฟล์ `Workflows/<Name>-<GUID>.json` + `.json.data.xml`; `Customizations.xml` ปล่อย `<Workflows/>` ว่างได้

---

## 8. งานดูแลประจำ (How-to)

### เพิ่มระบบใหม่
เพิ่ม **1 แถวใน `Routing`** (SystemName + ToNotifyBA/ToNotifySA/CCNotify)
→ ผู้ใช้เลือก "อื่นๆ (ระบุเอง)" แล้วพิมพ์ชื่อ → flow จับคู่ตามชื่อได้ทันที และรายชื่อจะโผล่ใน hint อัตโนมัติ (GetSystems)
**ไม่ต้องแก้ topic / ไม่ต้อง redeploy**

### แก้ผู้รับผิดชอบ / อีเมลทีม
แก้แถวใน `Routing` (คอลัมน์ ToNotifyBA/ToNotifySA/CCNotify) — ปัจจุบันเป็น temp `Teerapat.ti@deves.co.th`

### ปรับ SLA
แก้แถวใน `SLAConfig` (FirstResponseHours/ResolutionHours/EscalateToCC ต่อ Severity)

### ปรับข้อความอีเมล / เวลา recurrence / นโยบาย auto-close
แก้ definition ของ flow ที่เกี่ยว แล้ว deploy ตามข้อ 7

---

## 9. Checklist ทดสอบ

- [ ] เปิดเคส (แชท) → มี item ใน `Cases` + ได้อีเมล ack (ผู้แจ้ง) + อีเมลทีม
- [ ] เลือกระบบ "อื่นๆ" → เห็นรายชื่อระบบจาก Routing
- [ ] แก้ `Statuscase` ใน SharePoint → ผู้แจ้งได้อีเมลภายใน ~3 นาที
- [ ] แชท "ติดตามเคส" → พิมพ์ CaseID / "ทั้งหมด" → เห็นสถานะ (เฉพาะเคสตนเอง)
- [ ] แชท "เคสเดิมยังไม่หาย" → เคสเป็น Reopened + owner ได้อีเมล
- [ ] ตั้ง `SlaDueDate`/`FirstResponseDueDate` ย้อนหลัง → RemindStaleCases เตือน owner (รอ schedule หรือ Run manual)
- [ ] ตั้ง `ResolvedAt` เกิน 3 วัน → AutoCloseResolved ปิดเคส

---

## 10. ข้อจำกัด / สิ่งที่ควรทำต่อ (Backlog)

- **เพิ่ม choice `Reopened` / `On Hold`** ใน `Statuscase` (List settings) — จำเป็นสำหรับ ReopenCase/On Hold
- **อีเมล Routing/SLA เป็น temp** — เปลี่ยนเป็นอีเมลทีมจริง
- **Dynamic system = แบบ hint (ข้อความ)** ไม่ใช่ปุ่ม dropdown คลิกได้ เพราะ Teams จำกัดปุ่มตัวเลือกที่ 3 ปุ่ม; ถ้าต้องการ dropdown จริงต้องทำ Adaptive Card
- **v4K topic** ยังใช้ dropdown ระบบแบบ static (มี "อื่นๆ" + Routing รองรับ) — ยังไม่ได้ใส่ hint dynamic (เลี่ยงความเสี่ยงกับ topic หลัก)
- **CSAT (ให้คะแนนหลังปิด)** — ยังไม่ทำ
- **m365 CLI** ยังไม่ได้ login (การเขียน SharePoint columns/data ทำผ่าน connection เดิมใน provisioning flow) — ถ้าจะให้ผมจัดการ SharePoint ตรงๆ ต้องมี Entra appId
- ลบ flow Draft: `ProvisionHelpdeskData`, `CreateCaseAndAck`

---

## 11. ตาราง ID อ้างอิงรวม

| ประเภท | ชื่อ | ID |
|--------|------|-----|
| Agent | HelpMe Agent | `76812e27-6dce-f011-8544-6045bd592e11` |
| Entra App Registration | CLI-m365-Helpdesk (App ID) | `d514ef9a-e9c4-4d09-a282-a9a12e2bbea4` |
| Tenant ID | Deves Insurance (default) | `8ffef73e-6c1e-4fda-890b-a8fa247be32e` |
| List | Cases | `b8b22b0d-45c6-43c9-bc66-06e5e45b1237` |
| List | SLAConfig | `9c7bb698-4841-447e-aae4-5a43466771af` |
| List | KnowledgeGaps | `9beb45a0-08e2-4717-8eee-5b80bd218005` |
| List | ErrorLog | `f6822ed6-ef24-4129-a56a-832d71c8312e` |
| List | Routing | `3d5264cb-65f6-4db5-8afa-fa68a6ea61e1` |
| Flow | NewcaseHelpDesk | `15bbc09f-f01a-d621-d0ac-71a27363b2b5` |
| Flow | NotifyStatusChange | `7c1e2f30-1111-4aaa-bbbb-000000000032` |
| Flow | RemindStaleCases | `7c1e2f30-1111-4aaa-bbbb-000000000033` |
| Flow | AutoCloseResolved | `7c1e2f30-1111-4aaa-bbbb-000000000034` |
| Flow | GetCaseStatus | `7c1e2f30-1111-4aaa-bbbb-000000000041` |
| Flow | GetSystems | `7c1e2f30-1111-4aaa-bbbb-000000000042` |
| Flow | ReopenCase | `7c1e2f30-1111-4aaa-bbbb-000000000043` |
| Conn ref | SharePoint | `cr616_helpMeAgentUat.cr.KjQFMKAz` (+ `new_sharedsharepointonline_4d4aa`) |
| Conn ref | Office 365 Outlook | `new_sharedoffice365_71ca1` |

---

## 12. ตำแหน่งไฟล์ในโปรเจกต์

| ที่ | อะไร |
|-----|------|
| `HelpMe Agent/` | source ของ agent (topics, entities, knowledge, workflows) |
| `HelpMe Agent/topics/*.mcs.yml` | topics รวม CaseStatus, ReopenCase, OpenCase, Escalate |
| `HelpMe Agent/workflows/NewcaseHelpDesk-*/workflow.json` | definition ของ flow เปิดเคส |
| `_track/*.txt` | source ของ flow ติดตาม (NotifyStatusChange, RemindStaleCases, AutoCloseResolved, GetCaseStatus, ReopenCase, GetSystems) |
| `_tracksol/`, `_sssol/` | โฟลเดอร์ solution สำหรับ pack/import |
| `scripts/SHAREPOINT-manual-setup.md` | คู่มือสร้าง list ด้วยมือ |
| `scripts/*.ps1` | สคริปต์ deploy/provision |
