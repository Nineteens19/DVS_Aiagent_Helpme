# Tasks & Implementation Decisions (D4)

## Context Summary
- **Feature**: `helpdesk-kb-portal` (ระบบ Helpdesk Knowledge Base Management Portal)
- **Scope**: 8 User Stories, 2 Units, 8 Components บนหน้าจอ Canvas App Desktop 16:9
- **Deliverables**:
  - ซอร์สโค้ด YAML ของ Canvas App ในโฟลเดอร์ `Helpdesk_KB_Portal/` (`App.pa.yaml`, `Home_KB.pa.yaml`, Manifests & References)
  - ไฟล์ไบนารีคอมไพล์แล้ว `Helpdesk_KB_Portal.msapp` ผ่าน `pac canvas pack`
  - สรุปผลการทดสอบการทำงานร่วมกับ SharePoint Online และ Copilot Studio

---

## Decision Questions

### D4-1: Task Breakdown & Progressive Delivery Strategy
**Question**: ควรแบ่งขั้นตอนการพัฒนาและสร้างทาสก์ (Task Breakdown Strategy) อย่างไร?
- 1) **Foundation-to-Feature Progressive Wave Delivery**: แบ่งเป็น 4 ระยะ:
     - Phase 1: Application Scaffold & Master Connections (โครงสร้างโปรเจกต์ YAML, DataSources.json, App.OnStart, ตัวแปรสิทธิ์ RBAC, คอลเลกชัน Master Systems)
     - Phase 2: 4-Tier Shell & Manuals Management (Header, KPI Summary Bar, แท็บโมดูล, รายการโฟลเดอร์ระบบ, อัปโหลดคู่มือ, คุมสถานะ)
     - Phase 3: High-Density Q&A & Sliding Side Drawer (ตาราง Q&A 44px, Instant Delegable Search, Quick Toggle, Drawer Editor, Delete Dialog)
     - Phase 4: Gap-to-KB Converter Loop & Packaging (แท็บ Knowledge Gaps, 1-Click Convert action, คอมไพล์ .msapp, และทดสอบระบบ) **(Recommended)**
     - *ข้อดี*: พัฒนาและตรวจสอบผลได้ทีละเลเยอร์อย่างเป็นระบบ ป้องกันบั๊กทับซ้อน
     - *ข้อเสีย*: ต้องเรียงลำดับการส่งมอบ
- 2) **Single-Phase Big-Bang Task**: สร้างไฟล์โค้ดทั้งหมดพร้อมกันในขั้นตอนเดียว
     - *ข้อดี*: เอกสารน้อย
     - *ข้อเสีย*: ตรวจสอบความผิดพลาดยากเมื่อเกิดปัญหา Delegation หรือสูตรซ้อน
- 3) Other (please specify): _______

**Answer**: 1) Foundation-to-Feature Progressive Wave Delivery (Recommended)

---

### D4-2: Canvas App Development & Compilation Workflow
**Question**: กระบวนการสร้างและคอมไพล์ Canvas App ควรใช้แนวทางใด?
- 1) **Direct YAML Code Generation & Power Platform CLI Pack**:
     - สร้างโครงสร้างซอร์สโค้ด YAML (`.pa.yaml`) และ Manifest JSON โดยตรงใน Workspace ตามมาตรฐาน Power Platform CLI
     - คอมไพล์เป็นไฟล์ไบนารี `.msapp` ทันทีด้วยคำสั่ง `pac canvas pack`
     - นำเสนอไฟล์ `.msapp` พร้อมนำเข้าสู่ Power Apps Maker Portal **(Recommended)**
     - *ข้อดี*: ควบคุมความแม่นยำของคอนเทนเนอร์ 16:9, สี, และสูตร Power Fx ได้ 100%, ทำงานแบบอัตโนมัติ ไม่ต้องพึ่งพามือคลิกทีละปุ่ม
     - *ข้อเสีย*: ต้องจัดการรูปแบบ YAML ให้ถูกต้องตามไวยากรณ์ Power Platform
- 2) **Manual Step-by-Step Guide for Maker Portal**: ทำเฉพาะคู่มือบอกให้ผู้ใช้ไปคลิกสร้างในเว็บทีละกล่อง
     - *ข้อดี*: ไม่ต้องเขียนโค้ด YAML
     - *ข้อเสีย*: เสียเวลาผู้ใช้เป็นชั่วโมง และเสี่ยงต่อการตั้งค่าผิดพลาด
- 3) Other (please specify): _______

**Answer**: 1) Direct YAML Code Generation & Power Platform CLI Pack (Recommended)

---

### D4-3: Testing & Quality Verification Method
**Question**: แนวทางการทดสอบและตรวจสอบคุณภาพแอปพลิเคชันควรครอบคลุมระดับใด?
- 1) **Comprehensive Verification Matrix & Delegable Code Audit**:
     - ตรวจสอบซอร์สโค้ด YAML ทุกจุดว่าใช้สูตร Delegable 100% (ปราศจากคำเตือน 2,000 แถว)
     - ตรวจสอบความสมบูรณ์ของโครงสร้าง 16:9 Desktop Auto-Layout
     - ตรวจสอบการผูก Data Sources กับ 4 แหล่งข้อมูลบน SharePoint
     - ยืนยันว่าคอมไพล์ผ่าน `pac canvas pack` ได้สำเร็จโดยไม่มี Error **(Recommended)**
     - *ข้อดี*: มั่นใจได้ว่าไฟล์ `.msapp` ที่ส่งมอบสามารถนำเข้าและรันได้จริง 100%
     - *ข้อเสีย*: ต้องตรวจสอบโค้ดอย่างละเอียด
- 2) **Basic Syntax Check Only**: ตรวจสอบเฉพาะไวยากรณ์พื้นฐาน
     - *ข้อดี*: รวดเร็ว
     - *ข้อเสีย*: อาจเกิดข้อผิดพลาดตอนนำเข้าสู่ Maker Portal
- 3) Other (please specify): _______

**Answer**: 1) Comprehensive Verification Matrix & Delegable Code Audit (Recommended)

---

### D4-4: Implementation Mode Preference
**Question**: รูปแบบการดำเนินการสร้างระบบ (Implementation Mode) ควรเลือกใช้แบบใด?
- 1) **Parallel Wave Execution (Wave Mode)**: พัฒนาและสร้างไฟล์ตามลำดับ Dependency Waves โดยทาสก์ที่อิสระจากกันสามารถดำเนินการพร้อมกันเพื่อความรวดเร็วสูงสุด **(Recommended)**
     - *ข้อดี*: รวดเร็วและมีประสิทธิภาพสูงสุด
     - *ข้อเสีย*: ต้องควบคุม File Ownership อย่างเคร่งครัด
- 2) **Standard Sequential Mode**: พัฒนาเรียงทีละทาสก์แบบลำดับเส้นตรง
     - *ข้อดี*: ติดตามทีละสเต็ปช้าๆ
     - *ข้อเสีย*: ใช้เวลานานกว่า
- 3) Other (please specify): _______

**Answer**: 1) Parallel Wave Execution (Wave Mode) (Recommended)

---

## Decisions Summary
<!-- Machine-readable compact summary. Downstream agents: read ONLY this section. -->
<!-- Auto-populated after user fills answers above. One line per decision. -->
- D4-1 Task Breakdown Strategy: Foundation-to-Feature Progressive Wave Delivery (Recommended)
- D4-2 Compilation Workflow: Direct YAML Code Generation & Power Platform CLI Pack (Recommended)
- D4-3 Testing Strategy: Comprehensive Verification Matrix & Delegable Code Audit (Recommended)
- D4-4 Implementation Mode: Parallel Wave Execution (Wave Mode) (Recommended)

---

**Instructions**: Fill in your answers above and respond with "tasks decisions complete" or "use recommendations"
