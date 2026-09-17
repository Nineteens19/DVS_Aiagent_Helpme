# Implementation Tasks: Helpdesk Knowledge Base & Suggestion Management

## Overview
แผนงานและรายการทาสก์การพัฒนาสำหรับระบบ **Helpdesk Knowledge Base & Suggestion Management** จัดกลุ่มตามกลยุทธ์ **Foundation-to-Feature Progressive Delivery** (ตามมติ D4-1) ครอบคลุม 6 User Stories และคอมโพเนนต์สถาปัตยกรรมทั้งหมด

**Derived From**:
- Requirements: 6 User Stories (`US-KB-001` ถึง `US-KB-006`) จาก `requirements.md`
- Design: 4 Components, 3 Data Entities จาก `design.md` และโฟลเดอร์ `design/`
- Architecture Decisions: D3 (Strict Grounding, 0s Latency Top Systems, Inline Markdown Prompts) และ D4 (Progressive Delivery, Interactive Verification Matrix)

**Strategy**: Foundation-to-Feature Progressive Delivery  
**Rationale**: สร้างความมั่นคงของชั้นข้อมูล (SharePoint Storage & 74 Q&A Migration) ให้เสร็จสมบูรณ์ก่อนเชื่อมต่อกับ Copilot Studio และปรับแต่ง Prompt พฤติกรรมการตอบ เพื่อให้การทดสอบคำตอบและ Citations มีหลักฐานจริงอ้างอิงเสมอ

---

- [x] 1. Storage Layer & Data Governance (Foundation)
  - [x] 1.1 จัดเตรียม Document Library และกำหนดโครงสร้างคลังคู่มือระบบ
    - **Deps**: None | **Ref**: `design/components.md` — Section 1.1, `design/data-model.md` — Section 1
    - สร้างและตรวจสอบ Document Library `SystemManuals` บน `https://dvsins.sharepoint.com/sites/PowerAppPRD/SystemManuals`
    - เพิ่มคอลัมน์ `SystemName` (`Single line of text`), `DocType` (Choice), `Status` (Choice: Draft, Approved, Archived), `Keywords` (Text)
    - กำหนดสิทธิ์แบบ RBAC: IT Helpdesk Admin (Full Control), All Employees (Read-only)
  - [x] 1.2 จัดเตรียม SharePoint List และนำเข้าข้อมูล Q&A 74 รายการ
    - **Deps**: 1.1 | **Ref**: `design/components.md` — Section 1.2, `design/data-model.md` — Section 2
    - ตรวจสอบ SharePoint List `AI_KnowledgeBase` (ID: `95e5e09d-6d20-4811-8833-820cef88fe98`)
    - รันสคริปต์ `scripts/prepare-kb-import.ps1` แปลงข้อมูลจากไซต์เดิมเป็น `AI_KnowledgeBase_Import_Ready.csv` (UTF-8 with BOM)
    - นำเข้าข้อมูล Q&A 74 รายการสู่ SharePoint List พร้อมตรวจสอบฟิลด์ `System`, `Category`, `Keywords` และ `Status: Active`

- [x] 2. Conversational AI & Prompt Engineering
  - [x] 2.1 ปรับแต่งไฟล์ YAML เชื่อมต่อ Knowledge Sources บน PowerAppPRD
    - **Deps**: 1.1, 1.2 | **Ref**: `design/components.md` — Section 2.1, `design/integration.md` — Section 1
    - ปรับแก้ `ManualSystems_9SrlC8K2q_jCPnpBMmCOn.mcs.yml` ให้ชี้ไปยัง `PowerAppPRD/SystemManuals`
    - สร้าง `AI_KnowledgeBase_SPList.mcs.yml` ชี้ไปยัง `PowerAppPRD/Lists/AI_KnowledgeBase`
    - ลบไฟล์คอนฟิกเดิมที่อ้างอิงไซต์เก่า `BusinessAnalystandHelpdesk` ป้องกันการดึงข้อมูลผิดไซต์
  - [x] 2.2 ปรับปรุง System Instructions, Guardrails และตรรกะเสนอคำถามแนะนำต่อยอด
    - **Deps**: 2.1 | **Ref**: `design/components.md` — Section 2.3, `design/nfr.md` — Section 2
    - ปรับแต่ง `agent.mcs.yml`: กำหนด Strict Grounding และ Fallback ป้องกัน Hallucination 100%
    - เสริมคำสั่งเสนอคำถามที่เกี่ยวข้อง 2 ข้อ (Inline Markdown Bullets) ที่ท้ายคำตอบเสมอ
    - ระบุรายชื่อระบบ 31 ระบบจาก Master List `Systems` เพื่อให้ AI ทำ Disambiguation จับคู่ชื่อระบบได้อย่างชาญฉลาด
  - [x] 2.3 ปรับแต่ง Topic v4K สำหรับเมนูตัวเลือกระบบความเร็วสูง (0s Latency)
    - **Deps**: 2.1, 2.2 | **Ref**: `design/components.md` — Section 2.2, `design/nfr.md` — Section 1
    - กำหนดปุ่ม Quick Reply สำหรับ Top 4 ระบบ (Renewal Motor, DSS, PCS, Polisy 400) + ปุ่ม "ระบุระบบอื่น"
    - ป้องกันความหน่วง (Zero Latency) โดยไม่เรียก Power Automate Flow ในขั้นตอนการกดเลือกปุ่ม
  - [x] 2.4 Deploy และ Publish Agent ขึ้นสภาพแวดล้อมจริง
    - **Deps**: 2.1, 2.2, 2.3 | **Ref**: `design/integration.md` — Section 2
    - รันคำสั่ง `pac copilot push --project-dir "HelpMe Agent"` อัปเดตซอร์สโค้ด YAML ขึ้น Dataverse
    - รันคำสั่ง `pac copilot publish --bot 76812e27-6dce-f011-8544-6045bd592e11` เผยแพร่ขึ้นสภาพแวดล้อม UAT/Production สำเร็จ

- [x] 3. Verification, Operational SOP & Rollout
  - [x] 3.1 ทดสอบ Golden Benchmark Q&A และ Negative Edge Cases
    - **Deps**: 2.4 | **Ref**: `design/implementation.md` — Section 3, `design/nfr.md`
    - ทดสอบคำถามจริง 15-20 คำถามจากฐานข้อมูล Q&A 74 รายการผ่าน Copilot Studio Test Pane
    - ตรวจสอบความถูกต้องของคำตอบ, ลิงก์อ้างอิง (Citations), และการแสดงผลคำถามแนะนำ 2 ข้อ
    - ทดสอบ Negative Cases (คำถามนอกขอบเขต) ตรวจสอบว่า Agent ปฏิเสธอย่างสุภาพและไม่เกิด Hallucination
  - [x] 3.2 จัดทำคู่มือปฏิบัติงานแอดมิน (Operational Runbook) และส่งมอบระบบ
    - **Deps**: 3.1 | **Ref**: `design/implementation.md` — Section 2, `KNOWLEDGE-BASE-SETUP-GUIDE.md`
    - สรุปคู่มือการเพิ่ม/แก้ไขคู่มือและ Q&A, ขั้นตอนการ Force Indexing เมื่อมีข้อมูลเร่งด่วน
    - สรุป Walkthrough รายงานผลการดำเนินงานส่งมอบให้ทีมงานและผู้บริหาร

---

## Task Summary

| Task | Title | Dependencies | Status |
|------|-------|--------------|--------|
| 1.1 | จัดเตรียม Document Library และกำหนดโครงสร้างคลังคู่มือระบบ | None | [x] |
| 1.2 | จัดเตรียม SharePoint List และนำเข้าข้อมูล Q&A 74 รายการ | 1.1 | [x] |
| 2.1 | ปรับแต่งไฟล์ YAML เชื่อมต่อ Knowledge Sources บน PowerAppPRD | 1.1, 1.2 | [x] |
| 2.2 | ปรับปรุง System Instructions, Guardrails และ Follow-up Prompts | 2.1 | [x] |
| 2.3 | ปรับแต่ง Topic v4K สำหรับเมนูตัวเลือกระบบความเร็วสูง (0s Latency) | 2.1, 2.2 | [x] |
| 2.4 | Deploy และ Publish Agent ขึ้นสภาพแวดล้อมจริง | 2.1, 2.2, 2.3 | [x] |
| 3.1 | ทดสอบ Golden Benchmark Q&A และ Negative Edge Cases | 2.4 | [x] |
| 3.2 | จัดทำคู่มือปฏิบัติงานแอดมิน (Operational Runbook) และส่งมอบระบบ | 3.1 | [x] |

---

## Requirements Coverage

| Requirement | Implemented By Tasks | Status |
|-------------|----------------------|--------|
| **US-KB-001** (Document Library Setup & System Manuals) | Task 1.1, Task 3.2 | [x] Completed |
| **US-KB-002** (Q&A List Setup & Data Migration) | Task 1.2, Task 3.2 | [x] Completed |
| **US-KB-003** (Knowledge Governance & Status Lifecycle) | Task 1.1, Task 1.2, Task 3.2 | [x] Completed |
| **US-KB-004** (Agent Knowledge Source Re-pointing & Citations) | Task 2.1, Task 2.4, Task 3.1 | [x] Completed |
| **US-KB-005** (In-Dialog System Suggestions & Hybrid Routing) | Task 2.2, Task 2.3, Task 3.1 | [x] Completed |
| **US-KB-006** (AI Follow-up Question Prompts) | Task 2.2, Task 2.4, Task 3.1 | [x] Completed |

---

## Design Coverage

- **Components**:
  - `SystemManuals` -> Task 1.1, Task 3.2
  - `AI_KnowledgeBase` -> Task 1.2, Task 3.2
  - `HelpMeAgentRAG` -> Task 2.1, Task 2.2, Task 2.4, Task 3.1
  - `ConversationalMenuUX` -> Task 2.3, Task 3.1
- **Entities**:
  - `ManualDocument` -> Task 1.1
  - `QnAEntry` -> Task 1.2
  - `MasterSystems` -> Task 1.1, Task 1.2, Task 2.2
- **Integrations**:
  - SharePoint Graph Search Indexer -> Task 2.1, Task 3.1
  - Power Platform CLI (`pac`) -> Task 2.4

---

## Definition of Done

- [x] โครงสร้าง SharePoint Library และ List พร้อมใช้งานบน `PowerAppPRD`
- [x] ข้อมูล Q&A ทั้ง 74 รายการได้รับการนำเข้าและมีสถานะ `Active`
- [x] ไฟล์ YAML ของ Agent ปรับชี้แหล่งข้อมูลใหม่และลบไซต์เดิมออกเรียบร้อย
- [x] Agent ผ่านการคอมไพล์และ Publish สู่ Environment จริงเรียบร้อย (`pac copilot publish`)
- [x] ผ่านการทดสอบ Golden Benchmark ครบถ้วน ไม่พบ Hallucination
- [x] จัดทำคู่มือการบำรุงรักษา (Runbook & SOP) เรียบร้อยสมบูรณ์

---

## Execution Waves

| Wave | Tasks | Dependencies Resolved | Parallel Execution |
|------|-------|-----------------------|--------------------|
| **Wave 1** (Storage Foundation) | Task 1.1, Task 1.2 | None | Yes (Library & List can be prepared concurrently) |
| **Wave 2** (Agent Configuration & UX) | Task 2.1, Task 2.2, Task 2.3 | Wave 1 | Yes (YAML files, Instructions, Topic v4K) |
| **Wave 3** (Deployment) | Task 2.4 | Wave 2 | No (Sequential push & publish) |
| **Wave 4** (Verification & Handover) | Task 3.1, Task 3.2 | Wave 3 | Yes (Testing Matrix & Admin Documentation) |

### File Ownership Per Wave

- **Wave 1**:
  - Task 1.1: `KNOWLEDGE-BASE-SETUP-GUIDE.md` (Library Section)
  - Task 1.2: `scripts/prepare-kb-import.ps1`, `AI_KnowledgeBase_Import_Ready.csv`
- **Wave 2**:
  - Task 2.1: `HelpMe Agent/knowledge/*.mcs.yml`
  - Task 2.2: `HelpMe Agent/agent.mcs.yml`
  - Task 2.3: `HelpMe Agent/topics/v4K.mcs.yml`
- **Wave 3**:
  - Task 2.4: Dataverse Solution / Copilot Studio Environment (CLI commands)
- **Wave 4**:
  - Task 3.1: Verification Benchmark Suite (Test Pane Matrix)
  - Task 3.2: `KNOWLEDGE-BASE-SETUP-GUIDE.md`, `walkthrough.md`
