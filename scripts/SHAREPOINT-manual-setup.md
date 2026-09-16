# สร้าง SharePoint Lists ด้วยมือ (ไม่ต้องใช้ admin/CLI)

ต้องการแค่สิทธิ์ **Edit/Manage lists บน site** `https://dvsins.sharepoint.com/sites/PowerAppPRD`
สร้าง 4 lists ใหม่ (ห้ามแตะ list ทีมอื่น). KnowledgeBase ที่ site BusinessAnalystandHelpdesk = ไม่ต้องแตะ

> วิธีเพิ่มคอลัมน์: เปิด list → **+ Add column** → เลือกชนิด → ตั้งชื่อ (ใช้ชื่อภาษาอังกฤษตามตาราง) → บันทึก
> ชนิดคอลัมน์: Text=บรรทัดเดียว, Note=หลายบรรทัด, Choice=ตัวเลือก, Number=ตัวเลข, DateTime=วันที่และเวลา, Yes/No=ใช่/ไม่

---

## 1) List: `Cases`
สร้าง list ใหม่ชื่อ **Cases** (คอลัมน์ `Title` ที่ติดมาปล่อยไว้ได้ ใช้เก็บหัวเรื่องย่อ)

| Column | ชนิด | ตัวเลือก/หมายเหตุ |
|--------|------|-------------------|
| CaseID | Text | |
| CaseType | Choice | Incident ; Service Request ; Business Support ; Access |
| SystemName | Text | |
| Category | Text | |
| Priority | Choice | ปกติ ; ด่วน |
| Severity | Choice | P1 ; P2 ; P3 |
| ProblemDetail | Note | |
| IssueSummary | Note | |
| ConversationSummary | Note | |
| KBRef | Text | |
| Username | Text | |
| ReporterName | Text | |
| ReporterEmail | Text | |
| ReporterTel | Text | |
| Statuscase | Choice | Open ; In Progress ; Resolved ; Closed (default **Open**) |
| AssignedOwner | Text | |
| SlaDueDate | DateTime | |
| LastNotifiedStatus | Text | |
| ResolvedAt | DateTime | |

## 2) List: `SLAConfig`
| Column | ชนิด | ตัวเลือก/หมายเหตุ |
|--------|------|-------------------|
| Severity | Choice | P1 ; P2 ; P3 |
| FirstResponseHours | Number | |
| ResolutionHours | Number | |
| EscalateToCC | Text | อีเมล (คั่นด้วย ;) |

> เติมข้อมูล 3 แถว เช่น P1: FirstResponse 1, Resolution 4 · P2: 4/24 · P3: 8/48 (ปรับตามจริง)

## 3) List: `KnowledgeGaps`
| Column | ชนิด | ตัวเลือก/หมายเหตุ |
|--------|------|-------------------|
| UserQuestion | Note | |
| SystemGuess | Text | |
| Frequency | Number | |
| RelatedCaseID | Text | |
| GapStatus | Choice | New ; Reviewed ; Added to KB ; Rejected (default **New**) — **ตั้งชื่อคอลัมน์ว่า `GapStatus`** ให้ตรงกับ flow (ไม่ใช่ "Status") |

## 4) List: `ErrorLog`
| Column | ชนิด | ตัวเลือก/หมายเหตุ |
|--------|------|-------------------|
| FlowName | Text | |
| ErrorCode | Choice | CASE_001 ; ROUTE_001 ; EMAIL_001 ; SP_001 ; SLA_001 |
| ErrorMessage | Note | |
| ContextData | Note | |
| Timestamp | DateTime | |
| Notified | Yes/No | |

## 5) Routing (list เดิม — ทำเฉพาะถ้าต้องการ)
เพิ่มคอลัมน์ **OwnerTeam** (Text) — เฉพาะเมื่อยืนยันว่าจะใช้; ของเดิม (ToNotifyBA/ToNotifySA/CCNotify) มีอยู่แล้ว

---

## หลังสร้าง lists เสร็จ — เอา GUID มาใส่ flow
แต่ละ list มี GUID (List ID). หาได้จาก:
- เปิด list → **Settings (เฟือง) → List settings** → ดูใน URL ค่า `List=%7B....%7D` (ค่าในวงเล็บปีกกาคือ GUID) — หรือ
- ถ้ามี pac login แล้ว ไม่ต้องหาเองก็ได้ ให้ผมช่วยรัน

แล้วนำ GUID ไปแทน placeholder ใน `HelpMe Agent/workflows/CreateCaseAndAck/DRAFT-workflow.md`:
`@@CASES_LIST_GUID@@`, `@@SLACONFIG_LIST_GUID@@`, `@@KNOWLEDGEGAPS_LIST_GUID@@`, `@@ERRORLOG_LIST_GUID@@`, `@@ADMIN_EMAIL@@`

## จากนั้น deploy agent/flow ด้วย pac (ไม่ต้อง admin/app registration)
```
powershell -ExecutionPolicy Bypass -File .\deploy-helpme-agent.ps1
```
(pac ใช้ app ของ Microsoft เอง — login ด้วย device code ได้เลย)
