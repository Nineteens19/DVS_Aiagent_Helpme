# DF Foundation Decisions

## Context Summary
- **Mode**: Incremental — ตัดสิน foundation ก่อน แล้วออกแบบทีละ unit
- **Units**: foundation (นี้) + knowledge-answering, case-management, notification-followup, kb-governance
- **Platform**: Copilot Studio + Power Automate + SharePoint (site `PowerAppPRD`) + Office 365; auth = Integrated/Entra
- **ของเดิม**: มี 2 case lists (Incident + Password/UserSystem), 1 routing list, KB (structured search), flow เดียว `NewcaseHelpDesk` (มี nested For_each), CaseID = `Case-UserSystem-{yyyyMMdd}-{ID}`
- **หมายเหตุ**: คำถามปรับให้เข้ากับ low-code — ข้ามคำถามที่ไม่เกี่ยว (API gateway/frontend/gRPC)

> วิธีตอบ: เติมช่อง **Answer:** แล้วพิมพ์ **"done"** — หรือ **"use recommendations"**

---

## Decision Questions

### DF-1: โครงสร้างทีม (Team Structure)
**Question**: ทำงานกันแบบไหน?
- 1) Solo/ทีมเล็ก (1–3 คน) ทำตามลำดับ **(Recommended)**
- 2) หลายทีมทำขนานกัน
- 3) Other: _______

**Answer**: 1 (Solo/ทีมเล็ก ทำตามลำดับ)

---

### DF-2: ที่เก็บข้อมูล SharePoint (Site/Lists)
**Question**: จะวาง lists ไว้ที่ไหน?
- 1) ใช้ site `PowerAppPRD` เดิม จัดกลุ่ม lists ให้ชัด (Case/Routing/KB/Gap/ErrorLog) **(Recommended)**
- 2) สร้าง site ใหม่เฉพาะ Helpdesk
- 3) Other: _______

**Answer**: 1 (ใช้ site PowerAppPRD เดิม)

---

### DF-3: การรวม Case List (สำคัญ)
**Question**: จะจัดการ case lists อย่างไร (ปัจจุบันมี 2 lists)?
- 1) รวมเป็น **Case list เดียว** + ฟิลด์ `CaseType` (Incident/ServiceRequest/BusinessSupport/Access) + `Username` (optional) **(Recommended)** — ลดความซ้ำซ้อน จัดการ/รายงานง่าย
- 2) คงแยก 2 lists เดิม (Incident + UserSystem)
- 3) แยก list ตามประเภททั้งหมด
- 4) Other: _______

**Answer**: 1 (รวมเป็น Case list เดียว + CaseType) — migrate ข้อมูลเดิมภายหลัง

---

### DF-4: การสื่อสารระหว่างหน่วย / Orchestration
**Question**: จะให้ flows ทำงานร่วมกันอย่างไร?
- 1) SharePoint เป็น source of truth + **แยก flows ตามหน้าที่** (CreateCase+Ack, StatusChange-notify, SLA-reminder) trigger ตามเหตุการณ์ **(Recommended)**
- 2) รวมทุกอย่างใน flow เดียว (แบบเดิม)
- 3) Mixed
- 4) Other: _______

**Answer**: 1 (แยก flows ตามหน้าที่, SharePoint เป็น source of truth)

---

### DF-5: รูปแบบ CaseID
**Question**: จะใช้รูปแบบ CaseID แบบไหน?
- 1) `HD-{yyyyMMdd}-{running}` (สั้น อ่านง่าย เป็นกลางทุกประเภท) **(Recommended เมื่อรวมเป็น list เดียว)**
- 2) คงรูปแบบเดิม `Case-UserSystem-{yyyyMMdd}-{ID}` (ไม่กระทบของเดิม)
- 3) Other: _______

**Answer**: 1 (HD-{yyyyMMdd}-{running})

---

### DF-6: ตัวตนผู้แจ้ง / Auth
**Question**: จะระบุตัวผู้แจ้งและ auth อย่างไร?
- 1) คง Integrated (Entra); reporter email = `System.User.Email` + ถามชื่อ/เบอร์ **(Recommended)**
- 2) ถามอีเมลผู้แจ้งเองด้วย
- 3) Other: _______

**Answer**: 1 (Integrated/Entra + System.User.Email)

---

### DF-7: การจัดการข้อผิดพลาด/ความน่าเชื่อถือของ Flow
**Question**: เมื่อ flow ทำงานผิดพลาด จะจัดการอย่างไร?
- 1) ทุก flow มี error handling: retry (transient), เขียน error ลง `ErrorLog` list, แจ้ง admin เมื่อ fail **(Recommended)**
- 2) Terminate เมื่อ error (ไม่ retry/log)
- 3) ไม่จัดการ (แบบเดิม)
- 4) Other: _______

**Answer**: 1 (retry + ErrorLog list + แจ้ง admin)

---

### DF-8: เทมเพลตอีเมล (Email Template)
**Question**: จะจัดการเนื้อหาอีเมลอย่างไร?
- 1) เทมเพลต HTML กลางมี placeholder (ack/notify/reminder) รวมศูนย์ **(Recommended)**
- 2) เขียน HTML ในแต่ละ flow (แบบเดิม)
- 3) Other: _______

**Answer**: 1 (เทมเพลต HTML กลาง มี placeholder)

---

### DF-9: Config เป็นข้อมูล (Routing / SLA)
**Question**: จะเก็บกฎ routing และเกณฑ์ SLA ไว้ที่ไหน?
- 1) เก็บเป็น SharePoint list config (แก้ได้โดยไม่แตะ flow) — routing (มีอยู่) + เพิ่ม SLA thresholds ตาม Severity **(Recommended)**
- 2) hardcode ใน flow
- 3) Other: _______

**Answer**: 1 (SharePoint list config: routing + SLA thresholds)

---

### DF-10: Environment & Deployment
**Question**: จะพัฒนา/ปล่อยขึ้น production อย่างไร?
- 1) แก้/ทดสอบใน UAT (`cr616_helpMeAgentUat`) → publish PROD ผ่าน `pac copilot push/publish` (สคริปต์ `deploy-helpme-agent.ps1` เดิม) **(Recommended)**
- 2) แก้ตรง PROD
- 3) ใช้ Solution export/import
- 4) Other: _______

**Answer**: 1 (UAT → PROD ผ่าน pac)

---

### DF-11: กลยุทธ์ Infrastructure Unit
**Question**: จะจัดโครงสร้าง foundation อย่างไร?
- 1) รวมทุกอย่างใน **Foundation unit เดียว** (schema, connections, CaseID, email templates, error handling, config) **(Recommended — ทีมเล็ก)**
- 2) แยกเป็นหลาย infra units
- 3) Other: _______

**Answer**: 1 (Foundation unit เดียว)

---

## Decisions Summary
<!-- Machine-readable compact summary. Downstream agents: read ONLY this section. -->
<!-- Auto-populated after user fills answers above. One line per decision. -->
- DF-1 Team: Solo/ทีมเล็ก (1–3) ทำตามลำดับ
- DF-2 SharePoint Site: ใช้ `PowerAppPRD` เดิม, lists = Case/Routing/KB/Gap/ErrorLog
- DF-3 Case List: รวมเป็น Case list เดียว + `CaseType` (Incident/ServiceRequest/BusinessSupport/Access) + `Username` optional; migrate ของเดิมภายหลัง
- DF-4 Orchestration: SharePoint = source of truth + แยก flows ตามหน้าที่ (CreateCase+Ack / StatusChange-notify / SLA-reminder), trigger ตามเหตุการณ์
- DF-5 CaseID: `HD-{yyyyMMdd}-{running}`
- DF-6 Auth/Identity: Integrated/Entra; reporter email = `System.User.Email` + ถามชื่อ/เบอร์
- DF-7 Error Handling: retry (transient) + เขียน `ErrorLog` list + แจ้ง admin เมื่อ fail
- DF-8 Email Template: เทมเพลต HTML กลางมี placeholder (ack/notify/reminder)
- DF-9 Config-as-Data: routing + SLA thresholds เก็บเป็น SharePoint list config
- DF-10 Deployment: UAT (`cr616_helpMeAgentUat`) → PROD ผ่าน `pac copilot push/publish`
- DF-11 Infra Strategy: Foundation unit เดียว (รวม schema/connections/CaseID/templates/error/config)

---

**Instructions**: Fill in your answers above and respond with "foundation decisions complete" (หรือ "done" / "use recommendations")
