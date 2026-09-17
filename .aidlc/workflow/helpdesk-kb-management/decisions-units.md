# Architecture & Units Decisions (D2)

## Context Summary
ความต้องการของระบบจัดการองค์ความรู้ (Knowledge Base Management) และระบบเมนูนำทาง (Suggestion Menus) ได้รับการอนุมัติครอบคลุม 6 User Stories โดยมีมติทางสถาปัตยกรรมชัดเจนว่า:
1. รวมศูนย์ข้อมูลบน SharePoint Site `https://dvsins.sharepoint.com/sites/PowerAppPRD` (Library `SystemManuals` และ List `AI_KnowledgeBase` ID `95e5e09d-6d20-4811-8833-820cef88fe98` ซึ่งนำเข้าข้อมูล 74 รายการแล้ว)
2. เพื่อประสิทธิภาพของ AI สูงสุด (AI Intelligence) คอลัมน์ `SystemName` และ `System` ใน Document Library `SystemManuals` และ Q&A List `AI_KnowledgeBase` ถูกกำหนดเป็น `Single line of text` โดยยึดชื่อมาตรฐานตาม Master List `Systems` เพื่อให้ Copilot Studio ทำ Semantic Search และจับคู่คำค้นหาได้แม่นยำ 100%
3. แบ่งบทบาทผู้ใช้งานและการเข้าถึงชัดเจน (Admin จัดการไฟล์/Q&A, ผู้ใช้ทั่วไปค้นหาและรับคำตอบผ่านแชท)

---

## Decision Questions

### D2-1: Decomposition Need & Units Strategy
**Question**: ควรแบ่งขอบเขตงาน (Units of Work) ออกเป็นกี่หน่วยงานเพื่อความคล่องตัวในการพัฒนาและทดสอบ?
- 1) **2 Workstream Units**:
     - **Unit 1: `kb-storage-governance`** (US-KB-001, US-KB-002, US-KB-003): จัดเตรียม SharePoint Data Layer บน `PowerAppPRD` (Library `SystemManuals`, List `AI_KnowledgeBase`, สิทธิ์ RBAC, และเกณฑ์การกรอง Approved+Active)
     - **Unit 2: `agent-conversational-ux`** (US-KB-004, US-KB-005, US-KB-006): ปรับแต่ง Copilot Studio Agent (Conversation Starters, เมนูตัวเลือกระบบใน Topic `v4K`, คำถามต่อยอดท้ายคำตอบจาก AI, และการย้ายชี้ Connection มายัง PowerAppPRD) **(Recommended)**
- 2) **Single Monolithic Unit**: รวมทุกอย่างเป็นก้อนเดียว พัฒนาและทดสอบพร้อมกัน
- 3) **3 Units**: แยก Document Library, Q&A List, และ Copilot Studio ออกเป็น 3 หน่วยอิสระ
- 4) Other (please specify): _______

**Answer**: 1) 2 Workstream Units (Unit 1: kb-storage-governance และ Unit 2: agent-conversational-ux)

---

### D2-2: Execution Sequence & Dependency Strategy
**Question**: ลำดับขั้นตอนการพัฒนาและส่งมอบ (Execution Sequence) ควรเป็นอย่างไร?
- 1) **Sequential (Foundation First)**: ดำเนินการ Unit 1 (`kb-storage-governance`) ให้แล้วเสร็จ เพื่อให้มี SharePoint Library/List พร้อม URL และข้อมูลตัวอย่าง ก่อนเริ่มปรับแก้ Unit 2 (`agent-conversational-ux`) บน Copilot Studio **(Recommended)**
- 2) **Parallel Work**: ดำเนินการพร้อมกันทั้งสองส่วน
- 3) Other (please specify): _______

**Answer**: 1) Sequential (Foundation First)

---

### D2-3: Copilot Studio Knowledge Sources Migration Strategy
**Question**: การย้ายการเชื่อมต่อ Knowledge Sources ใน Copilot Studio จากไซต์เดิมมายัง `PowerAppPRD` ควรจัดการอย่างไร?
- 1) **In-Place Reconfiguration**: ปรับแต่งไฟล์ Configuration เดิม (`cr616_helpMeAgentUat.topic.AI_KnowledgeBase...mcs.yml` และ `ManualSystems...mcs.yml`) ให้ชี้ URL และ List เป้าหมายมายัง `PowerAppPRD` พร้อมปรับแต่ง Guardrails ใน `agent.mcs.yml` **(Recommended)**
- 2) **New Component Creation**: สร้างไฟล์ Knowledge Source Configuration ชุดใหม่ และลบไฟล์เก่าทิ้ง
- 3) Other (please specify): _______

**Answer**: 1) In-Place Reconfiguration (ชี้เป้าหมายมาที่ PowerAppPRD)

---

### D2-4: In-Dialog System Prompting Strategy (AI Intelligence vs Latency)
**Question**: สำหรับเมนูเลือกชื่อระบบในแชท (Topic `v4K`) เพื่อให้ตอบโจทย์ "เน้น AI ฉลาดและตอบสนองเร็ว" ควรใช้รูปแบบใด?
- 1) **High-Speed Hybrid with AI Disambiguation**: 
     - แสดงปุ่มระบบยอดนิยม 4-5 ตัวแรก (DSS, Renewal Motor, PCS, Polisy 400) + ปุ่ม "เลือกระบบอื่น / ระบุเอง" เพื่อให้การโต้ตอบรวดเร็วในระดับเสี้ยววินาที (Zero Flow Delay)
     - เสริม Prompt ใน `agent.mcs.yml` ให้ AI ตรวจจับชื่อระบบที่ผู้ใช้พิมพ์หรือเลือก เทียบกับ Master List `Systems` และช่วยจำแนกระบบให้อัตโนมัติ **(Recommended)**
- 2) **Strict Flow-Driven Adaptive Card**: เรียก Power Automate Flow ไปอ่าน SharePoint `Systems` ทุกครั้งที่กดเลือก เพื่อสร้างปุ่ม Dynamic (ยอมรับความหน่วง 1.5 - 2 วินาที)
- 3) Other (please specify): _______

**Answer**: 1) High-Speed Hybrid with AI Disambiguation

---

## Decisions Summary
<!-- Machine-readable compact summary. Downstream agents: read ONLY this section. -->
<!-- Auto-populated after user fills answers above. One line per decision. -->
- D2-1 Decomposition Strategy: 2 Workstream Units (kb-storage-governance, agent-conversational-ux)
- D2-2 Execution Sequence: Sequential (Unit 1 first, then Unit 2)
- D2-3 Knowledge Source Migration: In-Place Reconfiguration (Point to PowerAppPRD)
- D2-4 System Prompting Strategy: High-Speed Hybrid with AI Disambiguation

---

**Instructions**: Fill in your answers above and respond with "units decisions complete" or "use recommendations"
