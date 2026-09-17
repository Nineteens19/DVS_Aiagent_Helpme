# Phase 5: Tasks Decisions (D4) — Monitor_case_Helpdesk

## Context Summary
- **ระบบเป้าหมาย**: Power Apps Canvas App `Monitor_case_Helpdesk`
- **สถาปัตยกรรม**: Single-Screen Master-Detail with Collapsible Side Drawer บนหน้าจอ `Home_incident`
- **Units**: Unit 1 (`dashboard-filter`) และ Unit 2 (`case-resolution`)
- **การออกแบบที่อนุมัติจาก Phase 4**:
  - 4-Tier Auto-Layout Container Hierarchy (Header, KPI Bar, Control Bar, Workspace Split with 44px Dense Table and 480px Side Drawer)
  - Fluent Slate & Deves Corporate Deep Navy (`#012169`) — Zero Emoji 100%
  - Server-Side Delegable Filter 100% (ไร้คำเตือน 2,000 แถว)
  - Native EditForm Attachment Control สำหรับแนบหลักฐานปิดเคส
  - คู่มือ Schema 2 คอลัมน์ใหม่ + 5 Indexed Columns บน SharePoint List `Cases`

---

## Decision Questions

### D4-1: Implementation Sequencing & Wave Strategy (ลำดับขั้นการพัฒนาและแบ่ง Wave)
**Question**: ควรจัดลำดับขั้นตอนการปรับปรุงโค้ดและการแบ่ง Wave ในการพัฒนางานอย่างไร?
- 1) **Foundation & Shared Tokens -> Unit 1 Filter/Dashboard -> Unit 2 Resolution & Attachments -> Verification & Packaging**  
  - Wave 1 (Foundation): กำหนดตัวแปรชุดสีสากลใน `App.pa.yaml` และโครงสร้าง Container บน `Home_incident.pa.yaml`  
  - Wave 2 (Unit 1): ปรับปรุง Header, KPI Summary Bar, Control Filter Bar และ Dense Table Gallery พร้อมสูตร Delegable Filter ไร้ Emoji  
  - Wave 3 (Unit 2): ปรับปรุง Side Drawer, Attachment Control, ฟอร์มปิดเคส และเงื่อนไข Strict Validation  
  - Wave 4 (Packaging & Docs): คอมไพล์ผ่าน `pac canvas pack` และจัดทำคู่มือ SharePoint Setup Guide **(Recommended)**
- 2) **Screen-by-Screen Independent Build** — ปรับปรุงหน้า `updateincident` ให้เสร็จก่อน แล้วค่อยกลับมาปรับปรุง `Home_incident`
- 3) **Big Bang Modification** — ปรับปรุงไฟล์ YAML ทั้งหมดพร้อมกันในครั้งเดียว
- 4) Other (โปรดระบุ): _______

**Answer**: Option 1 (Foundation & Shared Tokens -> Unit 1 Filter/Dashboard -> Unit 2 Resolution & Attachments -> Verification & Packaging)

---

### D4-2: Power Fx Refactoring & Modernization Approach (แนวทางการลบ Emoji และปรับแต่งสูตร Power Fx)
**Question**: มีแนวทางอย่างไรในการกำจัด Emoji 100% และจัดระเบียบสูตร Power Fx ให้มีความเสถียรและบำรุงรักษาง่าย?
- 1) **Comprehensive Clean Code & Token Injection**  
  - ลบและแทนที่ Emoji ทั้งหมดจาก Label, Button, Notification, Icon, และ Status Text เป็นข้อความทางการภาษาไทย/อังกฤษที่กระชับ  
  - แปลงชุดสี Hardcoded เป็น Global Theme Variables (`gblColorPrimary`, `gblColorBg`, `gblColorResolved` ฯลฯ)  
  - จัดระเบียบสูตรคำนวณ Items, OnSelect, และ OnSuccess ให้อ่านง่ายตามหลัก Low-Code Best Practices **(Recommended)**
- 2) **Direct String Replacement Only** — ค้นหาแทนที่ Emoji แบบคำต่อคำโดยไม่ปรับโครงสร้างตัวแปรสี
- 3) **Preserve Legacy Properties with Hidden Emoji** — คง Emoji ไว้ใน Properties ลึกๆ แต่ซ่อนไม่ให้แสดงใน UI
- 4) Other (โปรดระบุ): _______

**Answer**: Option 1 (Comprehensive Clean Code & Token Injection — Zero Emoji, Global Theme Variables, Readable Power Fx)

---

### D4-3: SharePoint Deployment Guidance Strategy (แนวทางการส่งมอบคู่มือการปรับปรุง SharePoint)
**Question**: ควรจัดเตรียมและส่งมอบคำแนะนำสำหรับการตั้งค่าคอลัมน์ใหม่และการทำ Index ใน SharePoint List `Cases` อย่างไร?
- 1) **Step-by-Step Documentation & Verification Script**  
  - จัดทำเอกสารคู่มือ [SHAREPOINT-SETUP-GUIDE.md](file:///e:/DVS/Project/Aiagent_Helpme/SHAREPOINT-SETUP-GUIDE.md) อธิบายขั้นตอนการเพิ่มคอลัมน์ `ResolutionSummary`, `ResolutionCategory` พร้อมภาพและค่าตัวเลือกที่ถูกต้อง  
  - อธิบายวิธีการคลิกสร้าง 5 Indexed Columns ใน SharePoint List Settings  
  - แนบคำสั่ง PowerShell/CLI ตัวอย่างสำหรับ Admin ใช้ตรวจสอบโครงสร้างฟิลด์ **(Recommended)**
- 2) **Markdown Documentation Only** — เขียนคำอธิบายสรุปสั้นๆ ใน README รวม
- 3) **Source Code Comments Only** — ใส่เป็นคอมเมนต์อธิบายในไฟล์ YAML
- 4) Other (โปรดระบุ): _______

**Answer**: Option 1 (Step-by-Step Documentation & Verification Script in SHAREPOINT-SETUP-GUIDE.md)

---

### D4-4: CLI Packaging & Validation Protocol (กระบวนการทดสอบและบิลด์แพ็กเกจด้วย PAC CLI)
**Question**: กระบวนการคอมไพล์และตรวจสอบความถูกต้องของไฟล์ไบนารี .msapp ด้วย Power Platform CLI ควรทำอย่างไร?
- 1) **Continuous Pack-Unpack-Diff Verification**  
  - รัน `pac canvas pack --sources Monitor_case_Helpdesk --msapp Monitor_case_Helpdesk.msapp --overwrite` เพื่อคอมไพล์ซอร์สโค้ด YAML  
  - ตรวจจับและแก้ไข Syntax Error หรือ Missing References ทันทีหากคอมไพล์ไม่ผ่าน  
  - ทดสอบ unpack กลับมาตรวจสอบความคงอยู่ของโครงสร้างไฟล์และ DataSources.json **(Recommended)**
- 2) **Single Final Build Pack** — รัน pack เพียงครั้งเดียวตอนสุดท้ายเมื่อแก้ทุกอย่างเสร็จ
- 3) **Manual Import via Power Apps Studio** — ไม่ออกคำสั่ง pack ใน CLI ปล่อยให้ผู้ใช้นำโฟลเดอร์ไปนำเข้าเอง
- 4) Other (โปรดระบุ): _______

**Answer**: Option 1 (Continuous Pack-Unpack-Diff Verification via PAC CLI)

---

## Decisions Summary
<!-- Machine-readable compact summary. Downstream agents: read ONLY this section. -->
<!-- Auto-populated after user fills answers above. One line per decision. -->
- D4-1 Sequencing & Waves: Option 1 (Foundation & App Variables -> Unit 1 Filter/Dashboard -> Unit 2 Resolution/Drawer -> Packaging & Docs)
- D4-2 Power Fx Modernization: Option 1 (Comprehensive Clean Code & Token Injection — Zero Emoji, Global Variables, Clean Formulas)
- D4-3 SharePoint Guidance: Option 1 (Step-by-Step Documentation & Verification Script in SHAREPOINT-SETUP-GUIDE.md)
- D4-4 Packaging Protocol: Option 1 (Continuous Pack-Unpack-Diff Verification via PAC CLI)

---

**Instructions**: Decisions populated from recommended choices.

