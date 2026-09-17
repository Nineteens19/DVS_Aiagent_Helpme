# Requirements Decisions (D1)

## Context Summary
ระบบ HelpMe Agent ปัจจุบันมีแหล่งข้อมูลความรู้ 2 ส่วน คือรายการถาม-ตอบ (Q&A List) และเอกสารคู่มือระบบ (Manuals Document Library) ซึ่งจะถูกย้ายจากไซต์เดิม (`BusinessAnalystandHelpdesk`) มารวมศูนย์ที่ไซต์ `https://dvsins.sharepoint.com/sites/PowerAppPRD` เพื่อความเป็นเอกภาพด้าน Data Governance, การจัดการสิทธิ์ที่เบ็ดเสร็จ, ป้องกันปัญหา Broken Links, และรองรับการทำ Automation เชื่อมต่อกับเคส `Cases` และ `KnowledgeGaps`

---

## Decision Questions

### D1-1: Target Personas & Stakeholders
**Question**: ควรจัดกลุ่มผู้ใช้งาน (Personas) ในการบริหารจัดการและเข้าถึงฐานความรู้เพื่อกำหนดความต้องการอย่างไร?
- 1) กำหนดเป็น 2 กลุ่มแยกชัดเจน: **IT Helpdesk / KB Admin** (ผู้สร้าง อัปโหลด อนุมัติ และจัดหมวดหมู่ความรู้) และ **General End-User** (พนักงานทั่วไปที่ถามคำตอบและใช้เมนูนำทางผ่านแชท) **(Recommended)**
- 2) กำหนดเป็นกลุ่มเดียว (Unified User) รวมบทบาทผู้ใช้และผู้ดูแลไว้ด้วยกัน
- 3) Other (please specify): _______

**Answer**: 1) กำหนดเป็น 2 กลุ่มแยกชัดเจน: IT Helpdesk / KB Admin (ผู้ดูแลเนื้อหา) และ General End-User (ผู้ใช้งานแชทสอบถาม)

---

### D1-2: Document Library Architecture & Metadata (SystemManuals)
**Question**: โครงสร้างการจัดเก็บไฟล์คู่มือระบบ (PDF, Word, Excel, PPTX) ใน Document Library ควรเป็นรูปแบบใดเพื่อความสะดวกในการอัปโหลดและค้นหาของ AI?
- 1) **Single Document Library with Folders & Metadata**: ใช้ Library เดียว (`SystemManuals`) มี Folder แยกตามระบบ (`DSS`, `Renewal_Motor`, `PCS`, `Polisy_400`, `General`) พร้อมคอลัมน์ `SystemName`, `DocType`, `IsActive` เพื่อให้ Copilot Studio สแกนครอบคลุมและเจ้าหน้าที่ลากวางไฟล์ได้สะดวก **(Recommended)**
- 2) **Flat Structure**: Library เดียวไม่มี Folder อาศัยการระบุ Metadata เท่านั้น
- 3) **Multiple Libraries**: แยก 1 Library ต่อ 1 ระบบงาน
- 4) Other (please specify): _______

**Answer**: 1) Single Document Library with Folders & Metadata (Library `SystemManuals` บน PowerAppPRD มี Folder แยกตามระบบ และมีคอลัมน์ SystemName, DocType, IsActive)

---

### D1-3: Q&A Knowledge Base Lifecycle & Guardrails (AI_KnowledgeBase)
**Question**: กระบวนการอนุมัติและวงจรชีวิตเนื้อหา (Content Lifecycle) ของรายการถาม-ตอบใน SharePoint List ควรเป็นอย่างไรเพื่อป้องกัน AI ตอบข้อมูลผิดพลาด?
- 1) **3-Stage Governance**: `Draft` -> `Review Required` -> `Approved` โดยกำหนด Guardrail ให้ Copilot Studio ดึงไปตอบเฉพาะรายการที่ `Review_Status = Approved` และ `Is_Active = Active` เท่านั้น **(Recommended)**
- 2) **2-Stage Governance**: `Draft` -> `Approved` โดยไม่มีขั้นตอนรอตรวจสอบ
- 3) **Direct Active**: เพิ่มรายการแล้วมีผล Active ทันทีโดยไม่ต้องผ่านสถานะอนุมัติ
- 4) Other (please specify): _______

**Answer**: 1) 3-Stage Governance (Draft -> Review Required -> Approved โดย AI Agent ใช้เฉพาะ Approved และ Is_Active=Active)

---

### D1-4: Copilot Studio Suggestion Menus Implementation Approach
**Question**: สถาปัตยกรรมการแสดงเมนู Suggestion / คำถามแนะนำใน HelpMe Agent ควรทำในระดับใดบ้าง?
- 1) **Hybrid Multi-Tier Approach**: 
     - ระดับ 1: ตั้งค่า Conversation Starters (Prompt Starters ลอยหน้าแรกก่อนพิมพ์) สำหรับหัวข้อยอดนิยม
     - ระดับ 2: คงเมนูปุ่มตัวเลือกระบบใน Topic (`v4K` / `Greeting`) เพื่อให้กดเลือกประเภทปัญหาได้ทันที
     - ระดับ 3: ปรับ Prompt ให้ AI สรุปและเสนอ 2 คำถามที่เกี่ยวข้อง (Related Follow-ups) ต่อท้ายคำตอบจาก KB **(Recommended)**
- 2) **In-Dialog Quick Replies Only**: ใช้เฉพาะเมนูปุ่มใน Topic `v4K` เดิม ไม่ต้องมี Conversation Starters หรือ AI Follow-ups
- 3) **Pure Generative AI**: ไม่ใช้ปุ่มใดๆ ให้ผู้ใช้พิมพ์อย่างเดียวและพึ่งพา AI ตีความ
- 4) Other (please specify): _______

**Answer**: 1) Hybrid Multi-Tier Approach (Conversation Starters + Topic Quick Replies + AI Follow-up Suggestions ท้ายคำตอบ)

---

### D1-5: Knowledge Gap to KB Content Pipeline
**Question**: กระบวนการนำคำถามที่ AI ตอบไม่ได้ (จากตาราง `KnowledgeGaps`) หรือข้อมูลจากเคสที่แก้ไขสำเร็จ มาแปลงเป็นองค์ความรู้ใหม่ควรดำเนินการอย่างไร?
- 1) **Semi-Automated Workflow**: จัดทำ SharePoint Views กรองเคสที่พบบ่อย พร้อมเตรียมขั้นตอน/ปุ่มให้ทีม Helpdesk ตรวจทานและกดสร้างเป็น Draft KB เพื่ออนุมัติก่อนใช้งานจริง **(Recommended)**
- 2) **Manual Entry Only**: ทีม Helpdesk ตรวจสอบตารางเคสด้วยสายตา แล้วพิมพ์เพิ่มเข้าไปใน `AI_KnowledgeBase` เองทั้งหมด
- 3) **Full Auto-Publish**: ให้ AI บันทึกและตอบคำถามใหม่ทันทีโดยไม่ต้องผ่านคน
- 4) Other (please specify): _______

**Answer**: 1) Semi-Automated Workflow (SharePoint Views กรอง Gap ยอดนิยม + การสร้าง Draft KB ให้ทีม Helpdesk ตรวจทานก่อนอนุมัติ)

---

### D1-6: Security & Access Control
**Question**: การกำหนดสิทธิ์ (SharePoint Permissions) สำหรับเข้าถึง Document Library และ Q&A List ควรตั้งค่าอย่างไร?
- 1) **Role-Based Standard**: กลุ่มพนักงานทั่วไป (`Everyone except external users`) ได้สิทธิ์ **Read Only** (เพื่อค้นหาผ่าน Agent ได้), กลุ่ม IT Helpdesk / KB Admins ได้สิทธิ์ **Edit/Contribute** (เพื่อเพิ่ม/แก้ไข/ลบข้อมูล) **(Recommended)**
- 2) **Open Access**: ให้สิทธิ์ Edit แก่พนักงานทุกคนในบริษัท
- 3) Other (please specify): _______

**Answer**: 1) Role-Based Standard (Everyone = Read Only, IT Helpdesk / KB Admins = Edit/Contribute)

---

## Decisions Summary
<!-- Machine-readable compact summary. Downstream agents: read ONLY this section. -->
<!-- Auto-populated after user fills answers above. One line per decision. -->
- D1-1 Target Personas: Separate Personas (IT Helpdesk KB Admin vs General End-User)
- D1-2 Document Library Architecture: Single Document Library with System Folders & Metadata (`SystemManuals`)
- D1-3 Q&A Governance Lifecycle: 3-Stage Lifecycle (Draft -> Review Required -> Approved; Agent reads only Approved+Active)
- D1-4 Suggestion Menus Approach: Hybrid Multi-Tier (Conversation Starters + In-Dialog Quick Replies + AI Prompt Follow-ups)
- D1-5 Gap to KB Pipeline: Semi-Automated Workflow (Views for frequent gaps + Draft KB creation)
- D1-6 Security & Access Control: Role-Based Standard (`Everyone` Read Only, `Helpdesk Group` Edit/Contribute)

---

**Instructions**: Fill in your answers above and respond with "requirements decisions complete" or "use recommendations"
