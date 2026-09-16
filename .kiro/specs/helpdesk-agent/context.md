# Context Assessment

## Summary
<!-- 10-line max digest for downstream agents. Later phases can read ONLY this section. -->
- **Type**: Brownfield — ต่อยอดจาก Microsoft Copilot Studio agent "HelpMe Agent" ที่มีอยู่แล้ว
- **Stack**: Microsoft Copilot Studio (`.mcs.yml`) + Power Automate (`workflow.json`) + SharePoint Online lists + Office 365 Outlook; LLM = GPT (GenerativeAIRecognizer)
- **Architecture**: Topic-based conversational agent + Generative answering (grounded KB) + Escalation flow (case capture → SharePoint + email)
- **Feature**: AI Helpdesk ที่ตอบจากฐานความรู้ที่ยืนยันแล้ว, เปิดเคสเมื่อตอบไม่ได้, และส่งอีเมลแจ้งทราบ/ติดตามสำหรับเคสที่รับแล้ว
- **Impact**: Extends existing — เสริม/ปรับ agent เดิม โดยเฉพาะการแจ้งทราบผู้แจ้ง (acknowledgment) และการติดตามสถานะเคส (follow-up)
- **Complexity**: Medium-High — ประมาณ 8-14 stories, 4 domains (answering, case capture, notification/follow-up, KB governance), 3 user types
- **Recommendations**: Personas [Yes], Units [Yes], NFR [Yes]

## Project Overview
- **Type**: Brownfield
- **Assessment Date**: 2026-09-14

## Technology Stack
- **Languages**: YAML (MCS component definitions), JSON (Power Automate/Logic Apps definition), Power Fx (expression bindings), PowerShell (deploy script)
- **Frameworks**: Microsoft Copilot Studio (template `default-2.1.0`), Power Automate Cloud Flow (Logic Apps schema 2016-06-01)
- **Build System**: Power Platform CLI (`pac copilot push` / `pac copilot publish`)
- **Testing**: N/A — ยังไม่มี test harness (แพลตฟอร์ม low-code; ทดสอบผ่าน Test pane / channel จริง)
- **Infrastructure**: Microsoft 365 / Power Platform (SaaS) — SharePoint Online, Office 365 Outlook, Dataverse environment (`devesinsurancedefault`)

## Codebase Analysis

**Architecture**: Conversational agent (topic-based `AdaptiveDialog`) + generative answering (`SearchAndSummarizeContent`) + serverless orchestration flow (Power Automate) สำหรับเปิดเคสและส่งอีเมล

**Entry Points** (topics ที่ `HelpMe Agent/topics/`):
- `ConversationStart` / `Greeting` — เริ่มบทสนทนา
- `Search` — `OnUnknownIntent` (priority -1): ตอบอัตโนมัติจากฐานความรู้ (grounded generative answer)
- `Fallback` — `OnUnknownIntent`: หลัง fallback ครบ 3 ครั้ง → เรียก `OpenCase`
- `OpenCase` — เก็บรายละเอียดปัญหาแล้วเรียก Power Automate flow เปิดเคส + ส่งอีเมล
- `Escalate` — ส่งเรื่องต่อเจ้าหน้าที่ (human handoff) → เรียก flow เดียวกัน
- `Signin` — การยืนยันตัวตน
- อื่น ๆ: `EndofConversation`, `Goodbye`, `MultipleTopicsMatched`, `OnError`, `ResetConversation`, `StartOver`, `ThankYou`, `v4K`

**Data Layer**: SharePoint Online lists (site `https://dvsins.sharepoint.com/sites/PowerAppPRD`)
- **Incident case list** (`cde47156-...`): `SystemName`, `ProblemDetail`, `ReporterName`, `ReporterEmail`, `ReporterTel`, `Statuscase` (Open), `CaseID`
- **Password/UserSystem case list** (`18715bbd-...`): เพิ่ม `Username` จากรายการ incident
- **Owner/Routing list** (`3d5264cb-...`): `SystemName`, `ToNotifyBA`, `ToNotifySA`, `CCNotify` — ใช้ resolve ผู้รับอีเมลตามระบบ (fallback = "Helpdesk")
- **Knowledge base** `AI_KnowledgeBase_Helpdesk` (74 รายการ active, 19 ฟิลด์): `KB_ID`, `System`, `Category`, `Issue_Title`, `User_Utterance_Variants`, `Keywords`, `Required_Information`, `Approved_Answer`, `Followup_Question`, `Action_Type`, `Severity`, `Escalation_Rule`, `Owner`, `Confidence_Level`, `Review_Status`, `Is_Active`, `Last_Reviewed`, `Agent_Guardrail`, `Source_Row`
- **Manual Systems**: SharePoint document search source (ไฟล์คู่มือระบบ)

**Key Components**:
| Component | Purpose | Location |
|-----------|---------|----------|
| Agent instructions (system prompt) | นิยามพฤติกรรม/guardrails ของ agent | `HelpMe Agent/agent.mcs.yml` |
| Search topic | ตอบจากฐานความรู้แบบ generative | `HelpMe Agent/topics/Search.mcs.yml` |
| OpenCase topic | เก็บข้อมูลปัญหา → เปิดเคส | `HelpMe Agent/topics/OpenCase.mcs.yml` |
| Escalate topic | ส่งต่อเจ้าหน้าที่ (คน) | `HelpMe Agent/topics/Escalate.mcs.yml` |
| Fallback topic | จับกรณีไม่เข้าใจ → เปิดเคส | `HelpMe Agent/topics/Fallback.mcs.yml` |
| NewcaseHelpDesk flow | สร้าง item ใน SharePoint + ส่งอีเมล | `HelpMe Agent/workflows/NewcaseHelpDesk-.../workflow.json` |
| Knowledge sources | KB + Manual Systems | `HelpMe Agent/knowledge/*.mcs.yml` |
| Deploy script | push + publish ผ่าน pac CLI | `deploy-helpme-agent.ps1` |

**Integration Points**: SharePoint Online (2 connection references), Office 365 Outlook (`SendEmailV2`), Power Automate flow (`flowId 15bbc09f-f01a-d621-d0ac-71a27363b2b5`), Dataverse/Power Platform environment

## Feature Impact

**Affected Areas**:
- [ ] New standalone feature
- [x] Extends existing component
- [x] Modifies existing behavior
- [x] Cross-cutting concern

**สิ่งที่มีอยู่แล้ว (ครอบคลุมเป้าหมายบางส่วน)**:
- ✅ ตอบจากฐานความรู้ที่ยืนยันแล้ว (Approved_Answer) พร้อม guardrails ห้ามเดา
- ✅ เก็บรายละเอียดปัญหาและเปิดเคสเมื่อตอบไม่ได้ (`OpenCase` + flow → SharePoint)
- ✅ ส่งอีเมล**แจ้งทีมเจ้าหน้าที่/Owner** ตามระบบที่เกี่ยว (routing list)
- ✅ สร้าง `CaseID` และตั้งสถานะ `Open`

**ช่องว่างที่ตรงกับสิ่งที่ผู้ใช้ต้องการเพิ่ม (candidate scope)**:
- ⚠️ ยังไม่มีอีเมล **แจ้งทราบผู้แจ้ง (acknowledgment)** ว่า "รับเคสแล้ว + CaseID" — ปัจจุบันอีเมลส่งถึงเจ้าหน้าที่เท่านั้น
- ⚠️ ยังไม่มีกลไก **ติดตามสถานะเคส (follow-up)** เช่น แจ้งเมื่อสถานะเปลี่ยน (In Progress/Resolved) หรือเตือนเคสค้าง
- ⚠️ flow มี nested `For_each` ซ้อนหลายชั้นในการ resolve MailTo/CC ซึ่งเสี่ยง bug/ประสิทธิภาพ (candidate สำหรับ refactor)
- ⚠️ ยังไม่มีการสรุปบริบทบทสนทนา/KB_ID ที่ใช้ ลงในเคสอย่างเป็นระบบ (ตอนนี้รวมไว้ใน text เดียว)

**Files Likely to Change**:
| File | Change Type | Reason |
|------|-------------|--------|
| `HelpMe Agent/workflows/.../workflow.json` | Modify | เพิ่มอีเมล acknowledgment ถึงผู้แจ้ง, ปรับ routing, รองรับ follow-up |
| `HelpMe Agent/topics/OpenCase.mcs.yml` | Modify | เก็บ/ส่งบริบทเพิ่ม (KB_ID, สรุปปัญหา), ยืนยัน CaseID กลับผู้ใช้ |
| `HelpMe Agent/topics/Escalate.mcs.yml` | Modify | ให้สอดคล้องกับ OpenCase (ลดความซ้ำซ้อน) |
| `HelpMe Agent/agent.mcs.yml` | Modify | ปรับ instruction ให้สื่อสาร CaseID/acknowledgment |
| SharePoint case list schema | Modify | เพิ่มฟิลด์สถานะ/timestamp สำหรับ follow-up (ถ้าเลือกทำ) |
| New follow-up flow | New | flow ตามสถานะ/เวลาเพื่อแจ้งเตือน (ถ้าเลือกทำ) |

## Recommendations

**Complexity Indicators**:
- Story Count: Medium-High (ประเมิน 8-14 stories)
- Domain Boundaries: (1) Knowledge answering, (2) Case capture & routing, (3) Notification & follow-up, (4) KB governance/ops
- User Types: ผู้แจ้งปัญหา (agent/พนักงาน), ทีมเจ้าหน้าที่/Owner (IT Helpdesk, ฝ่ายรับประกันภัยรถยนต์, IT/SA, ฝ่ายบัญชี, IT/Infrastructure), ผู้ดูแลฐานความรู้/แอดมิน
- Integration Points: SharePoint Online, Office 365 Outlook, Power Automate, Copilot Studio, (อาจมี SysAid ที่อ้างถึงใน KB)

**Decision Gate Recommendations**:
- **Personas**: Yes — มีผู้ใช้อย่างน้อย 3 กลุ่มที่เป้าหมายและ journey ต่างกันชัดเจน
- **Units**: Yes — แยกได้เป็น domain ตอบคำถาม / จัดการเคส / แจ้งเตือน-ติดตาม / ดูแล KB ซึ่งออกแบบและทำเป็นชิ้น ๆ ได้
- **NFR**: Yes — สำคัญเรื่องความถูกต้องของคำตอบ (no-guessing), ความน่าเชื่อถือของการส่งอีเมล/เปิดเคส, ความปลอดภัย (ห้ามเก็บ Password/OTP), และ PDPA สำหรับข้อมูลติดต่อผู้แจ้ง

## Next Steps
Proceed to Requirements phase (D1 → Personas → Requirements)
