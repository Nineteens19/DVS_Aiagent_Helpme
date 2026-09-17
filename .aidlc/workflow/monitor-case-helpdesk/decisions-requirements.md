# Phase 2: Requirements Decisions (D1) — Monitor_case_Helpdesk

## Context Summary
- **ระบบเป้าหมาย**: Power Apps Canvas App `Monitor_case_Helpdesk` เชื่อมต่อกับ SharePoint List `Cases` ที่ไซต์ `PowerAppPRD`
- **ปัญหาเดิม**: หน้าระบบมี Emoji จำนวนมาก, ยังไม่มีส่วนแนบไฟล์หลักฐานประกอบการปิดเคส, การจัดวางบนหน้าจอ Laptop แสดงผลหลวม ต้องเลื่อนหาข้อมูล, และตัวกรองอาจติด Delegation Limit เมื่อข้อมูลเติบโต
- **เป้าหมาย**: ปรับโฉมเป็น Modern Enterprise UI (No Emoji), รองรับไฟล์แนบปิดงาน, ปรับสูตรและ SharePoint Schema ให้รองรับเคสปริมาณมาก, และจัด Layout ให้หนาแน่นเหมาะสมกับจอ Laptop

---

## Decision Questions

### D1-1: Personas Selection (กลุ่มผู้ใช้งานหลัก)
**Question**: ระบบนี้ควรสร้าง Persona สำหรับกลุ่มผู้ใช้งานใดบ้างในการเขียน Requirement และ User Stories?
- 1) **2 Personas: IT Helpdesk Operator & Supervisor Lead** — แบ่งเป็นผู้ปฏิบัติงานประจำวันที่เน้นความเร็วในการกรองข้อมูล/ปิดงานบน Laptop และหัวหน้าทีมที่เน้นติดตามภาพรวม/SLA **(Recommended)**
- 2) **Single Persona: IT Helpdesk Operator** — มุ่งเน้นเฉพาะผู้ปฏิบัติงานแก้ปัญหาเคสเท่านั้น
- 3) **3 Personas: Operator, Supervisor, and Auditor/Admin** — เพิ่มกลุ่มผู้ตรวจสอบประวัติและไฟล์หลักฐานการปิดงาน
- 4) Other (โปรดระบุ): _______

**Answer**: 1) 2 Personas: IT Helpdesk Operator & Supervisor Lead

---

### D1-2: Modern UI Theme & Iconography (ธีมและการจัดการไอคอน)
**Question**: ต้องการปรับภาพลักษณ์ของ UI หลังจากนำ Emoji ออกทั้งหมดในรูปแบบใด?
- 1) **Fluent UI Enterprise Minimalist** — ใช้สีทางการ (Corporate Blue / Slate Gray), ใช้ Badge สี่เหลี่ยมมน (Pill Badges) สีเรียบสื่อความหมายของสถานะ, ใช้ Modern Vector/SVG Icons แทน Emoji ทั้งหมด **(Recommended)**
- 2) **Corporate High-Contrast Card Style** — เน้นการ์ดสีน้ำเงิน Deves (#012169) มีเงาและเส้นแบ่งชัดเจน
- 3) **Compact Spreadsheet/Grid Style** — ปรับให้คล้ายตารางข้อมูล Excel/SharePoint List เน้นตัวอักษรและข้อมูลดิบ
- 4) Other (โปรดระบุ): _______

**Answer**: 1) Fluent UI Enterprise Minimalist (Corporate Blue / Slate Gray, Pill Badges, Vector Icons แทน Emoji ทั้งหมด)

---

### D1-3: Case Resolution Evidence & SharePoint Schema Enhancement (การแนบหลักฐานและปรับปรุง SharePoint)
**Question**: รูปแบบการจัดเก็บหลักฐานประกอบการปิดเคส และการปรับปรุงคอลัมน์ใน SharePoint List `Cases` ควรเป็นแบบใด?
- 1) **SharePoint Native Attachments + เพิ่มคอลัมน์ `ResolutionSummary` (ข้อความแนวทางแก้ไข) และ `ResolutionCategory` (หมวดหมู่วิธีแก้)** — ใช้ระบบ Attachment พื้นฐานของ SharePoint ที่มีอยู่แล้ว ไม่ต้องสร้าง Library เพิ่ม และเพิ่มฟิลด์สรุปงานให้ชัดเจน **(Recommended)**
- 2) **Dedicated Document Library** — สร้าง SharePoint Document Library แยกต่างหากเพื่อเก็บไฟล์หลักฐานปิดเคสโดยเฉพาะ (แยกโฟลเดอร์ตาม CaseID)
- 3) **SharePoint Native Attachments โดยไม่เพิ่มคอลัมน์ใหม่** — ใช้ฟิลด์ `StatusNote` เดิมในการบันทึกสรุปการแก้ไข
- 4) Other (โปรดระบุ): _______

**Answer**: 1) SharePoint Native Attachments + เพิ่มคอลัมน์ `ResolutionSummary` และ `ResolutionCategory` ใน SharePoint List `Cases`

---

### D1-4: High-Volume Data Filtering & Delegation Strategy (กลยุทธ์การกรองข้อมูลปริมาณมาก)
**Question**: กลยุทธ์ในการรองรับการค้นหาและกรองข้อมูลจำนวนมาก (เกิน 2,000 แถว) ควรจัดการอย่างไร?
- 1) **Delegable Server-Side Filter + Indexed Columns** — เขียนสูตร Power Fx ให้ Delegable 100% (ใช้ `StartsWith`, `=`, `>=`, `<=`) และแนะนำให้ผู้ใช้ไปตั้งค่า Indexed Columns ใน SharePoint สำหรับคอลัมน์ที่ใช้ค้นหาบ่อย (`Statuscase`, `Created`, `CaseID`, `SystemName`, `AssignedOwner`) **(Recommended)**
- 2) **Active Cases Caching** — ดึงเฉพาะเคสที่ยังไม่ปิด หรือเคส 30 วันล่าสุดมาเก็บใน Local Collection เพื่อกรองในเครื่องได้อย่างอิสระ
- 3) **Direct Server Query with Strict Date Range** — บังคับให้ผู้ใช้ต้องระบุช่วงเวลาหรือเลือกสถานะก่อนแสดงผลเสมอ
- 4) Other (โปรดระบุ): _______

**Answer**: 1) Delegable Server-Side Filter + Indexed Columns (Power Fx Delegable 100% + SharePoint Indexed Columns)

---

### D1-5: Laptop Layout & Information Density (การจัดวางหน้าจอบน Laptop)
**Question**: โครงสร้าง Layout หน้าจอที่เหมาะสมกับการทำงานบน Laptop ควรเป็นรูปแบบใด?
- 1) **Master-Detail Split Screen / Compact Grid with Side Drawer** — ด้านซ้ายเป็นตารางรายการเคสแบบ Dense Grid แสดงได้ 15-20 แถวต่อหน้าจอ เมื่อคลิกเลือกเคสจะเปิด Detail/Action Pane ด้านขวา ให้ตรวจดูและกดปิดงานแนบไฟล์ได้ทันทีโดยไม่ต้องสลับหน้าจอ **(Recommended)**
- 2) **Two-Screen Optimized Navigation** — แยกเป็น 2 หน้าเต็มจอเหมือนเดิม แต่ปรับหน้าแรกให้เป็นตารางขนาดกะทัดรัด (Compact Table) และปรับหน้าสอง (`updateincident`) ให้เป็นแบบ 2 คอลัมน์สมมาตร
- 3) **Modal Dialog Popup** — แสดงตารางกว้างเต็มจอ และเมื่อกดแก้ไขเคสจะเปิดหน้าต่าง Popup Modal กึ่งกลางหน้าจอ
- 4) Other (โปรดระบุ): _______

**Answer**: 1) Master-Detail Split Screen / Compact Grid with Side Drawer (ตารางด้านซ้าย และ Side Drawer ตรวจดู/ปิดงานด้านขวา)

---

### D1-6: Case Resolution Validation Rules (เงื่อนไขและกฎการปิดงาน)
**Question**: เงื่อนไขและ Validation เมื่อเจ้าหน้าที่กดปุ่ม "ปิดงาน" (Resolve / Close) ควรเป็นอย่างไร?
- 1) **บังคับสรุปแนวทางแก้ไข + บังคับแนบไฟล์หลักฐานอย่างน้อย 1 ไฟล์** — เพื่อความโปร่งใสและตรวจสอบย้อนหลังได้ เจ้าหน้าที่จะไม่สามารถปิดเคสได้หากยังไม่มีการแนบไฟล์หลักฐาน **(Recommended)**
- 2) **บังคับสรุปแนวทางแก้ไข แต่การแนบไฟล์เป็น Optional** — ให้แนบไฟล์ได้แต่ไม่บังคับ
- 3) **บังคับแนบไฟล์เฉพาะเคสประเภท Incident/Error** — ถ้าเป็นเคสประเภท Service Request หรือขอข้อมูล ทั่วไปไม่ต้องแนบไฟล์
- 4) Other (โปรดระบุ): _______

**Answer**: 1) บังคับสรุปแนวทางแก้ไข + บังคับแนบไฟล์หลักฐานอย่างน้อย 1 ไฟล์ก่อนปิดเคส

---

### D1-7: Analytics & Reporting Readiness (การเตรียมความพร้อมสำหรับวิเคราะห์ข้อมูล)
**Question**: ต้องการให้ระบบรองรับการวิเคราะห์ข้อมูลและสถิติในระดับใด?
- 1) **KPI Metrics Bar บนหน้าจอ + เตรียมฟิลด์คำนวณเวลา (Resolution Hours / SLA Met)** — มีการ์ดสรุปยอดเคส (รวม, รอรับ, กำลังทำ, ปิดแล้ว, หลุด SLA) ด้านบนของหน้าจอ พร้อมคำนวณสถิติเวลาให้ดึงไปออกรายงานหรือ Power BI ได้สะดวก **(Recommended)**
- 2) **In-App Analytics Tab** — เพิ่มแท็บหน้าจอกราฟสถิติและแนวโน้มปัญหาภายใน Power Apps โดยตรง
- 3) **Basic KPI Summary Only** — มีเฉพาะตัวเลขนับเคสตามสถานะทั่วไป ยังไม่ต้องคำนวณ SLA เชิงลึก
- 4) Other (โปรดระบุ): _______

**Answer**: 1) KPI Metrics Bar บนหน้าจอ + เตรียมฟิลด์คำนวณเวลา (Resolution Hours / SLA Met) สำหรับต่อยอด Power BI

---

## Decisions Summary
<!-- Machine-readable compact summary. Downstream agents: read ONLY this section. -->
<!-- Auto-populated after user fills answers above. One line per decision. -->
- D1-1 Personas: 2 Personas (IT Helpdesk Operator & Supervisor Lead)
- D1-2 UI Theme: Fluent UI Enterprise Minimalist (Corporate Blue / Slate Gray, Pill Badges, Vector Icons, No Emoji)
- D1-3 Resolution Evidence & Schema: SharePoint Native Attachments + เพิ่มคอลัมน์ `ResolutionSummary` และ `ResolutionCategory` ใน SharePoint List `Cases`
- D1-4 High-Volume Delegation: Delegable Server-Side Filter + Indexed Columns (Power Fx Delegable 100% + SharePoint Indexed Columns)
- D1-5 Laptop Layout: Master-Detail Split Screen / Compact Grid with Side Drawer
- D1-6 Resolution Validation: บังคับสรุปแนวทางแก้ไข + บังคับแนบไฟล์หลักฐานอย่างน้อย 1 ไฟล์ก่อนปิดเคส
- D1-7 Analytics Readiness: KPI Metrics Bar บนหน้าจอ + เตรียมฟิลด์คำนวณเวลาสำหรับต่อยอดรายงาน

---

**Instructions**: Fill in your answers above and respond with "requirements decisions complete" or confirm summary.
