# บริบทของระบบ (Context Assessment) — Monitor_case_Helpdesk

## สรุปภาพรวม (Summary)
- **Type**: Brownfield
- **Stack**: Microsoft Power Apps (Canvas App) / Power Fx / SharePoint Online Lists / Power Automate / Copilot Studio
- **Architecture**: Low-Code Multi-Tier Enterprise Application (Canvas App UI + SharePoint Online Data Layer + Cloud Flows Integration)
- **Feature**: ปรับปรุงหน้าจอระบบ Monitor_case_Helpdesk ให้เป็น Modern UI ระดับ Enterprise (ปราศจาก Emoji), รองรับการแนบไฟล์หลักฐานประกอบการปิดเคส (Resolution Evidence Attachments), ปรับปรุงฟังก์ชันการกรองข้อมูล (Filter) ให้รองรับปริมาณข้อมูลสูงในอนาคต (Delegation-friendly / High Volume Data), และปรับ Layout ให้แสดงผลหนาแน่นและเหมาะสมบนหน้าจอ Laptop/Desktop
- **Impact**: ปรับปรุงและต่อยอดคอมโพเนนต์เดิม (Modifies existing screens `Home_incident`, `updateincident` + Extends data contract & attachment logic)
- **Complexity**: Medium — ประเมิน 6-8 Stories, 2 Domains (Case Monitoring & Search, Case Resolution & Evidence), 2 User Types (IT Support/Operator, Helpdesk Lead/Admin)
- **Recommendations**: Personas [Yes], Units [Yes], NFR [Yes]

---

## ภาพรวมโปรเจกต์ (Project Overview)
- **Type**: Brownfield (ปรับปรุงแอปพลิเคชัน Canvas App ที่มีอยู่เดิมในสภาพแวดล้อมจริง)
- **Assessment Date**: 2026-09-17
- **Target Application**: `Monitor_case_Helpdesk` (ไฟล์แพ็กเกจ `Monitor_case_Helpdesk.msapp` และ Source YAML ในโฟลเดอร์ `Monitor_case_Helpdesk/`)
- **Connected Environment**: Deves Insurance (default) (`https://devesinsurancedefault.crm5.dynamics.com/`)
- **SharePoint Site**: PowerAppPRD (`https://dvsins.sharepoint.com/sites/PowerAppPRD`)

---

## สแตกเทคโนโลยีที่มีอยู่ (Technology Stack)
- **Frontend / Client**: Microsoft Power Apps Canvas App (Power Fx Formulas, YAML Layouts `.pa.yaml`)
- **Packaging & Build System**: Microsoft Power Platform CLI (`pac` canvas pack / unpack / download)
- **Data Layer / Backend**: Microsoft 365 SharePoint Online Lists
  - `Cases` (List GUID: `b8b22b0d-45c6-43c9-bc66-06e5e45b1237`)
  - `Routing` (List GUID: `3d5264cb-65f6-4db5-8afa-fa68a6ea61e1`)
  - `SLAConfig` (List GUID: `9c7bb698-4841-447e-aae4-5a43466771af`)
- **Integration Layer**: Power Automate Cloud Flows (NewcaseHelpDesk, NotifyStatusChange, GetCaseStatus, etc.)
- **AI Agent Integration**: Microsoft Copilot Studio (HelpMe Agent — Agent ID `76812e27-6dce-f011-8544-6045bd592e11`)

---

## การวิเคราะห์โค้ดเบสเดิม (Codebase Analysis)

### สถาปัตยกรรมและโครงสร้างไฟล์เดิม
แอปพลิเคชันแบ่งเป็น 2 หน้าจอหลักในรูปแบบ Power Apps Modern YAML:

1. **`Src/App.pa.yaml`**:
   - จัดการ `OnStart`, ตัวแปรผู้ใช้ (`varCurrentUser = User()`), ตัวแปรสถานะและเวลา (`varLastRefreshedTime`)
   - ธีมและการกำหนดตัวแปรร่วม (Theme & Global Styles)

2. **`Src/Home_incident.pa.yaml`**:
   - หน้าจอค้นหาและตรวจสอบเคส (Incident Dashboard)
   - ประกอบด้วย Header, Quick KPI Summary Cards, แท็บตัวกรองสถานะ (Status Tabs), กล่องค้นหา (Search Box), และ Gallery แสดงรายการเคส
   - **ปัญหาที่พบ**: มีการใช้ Emoji จำนวนมากในข้อความและปุ่ม (เช่น 🛡️, 🕒, 🔄, 👤, 🔎, 📋, 🔵, 🟠, 🟢, 🗑️) ทำให้ภาพลักษณ์ดูไม่เป็นทางการ (Non-Enterprise), การจัดวางยังไม่กระชับสำหรับจอ Laptop (Data density ต่ำ ต้องเลื่อนเยอะ), และสูตรการกรองข้อมูลมีจุดเสี่ยงต่อ Delegation Limit เมื่อมีข้อมูลเกิน 500-2,000 แถว

3. **`Src/updateincident.pa.yaml`**:
   - หน้าจอแสดงรายละเอียดเคสและบันทึกการอัปเดตสถานะ (Case Detail & Update Form)
   - มีปุ่มรับเคส (Assign Me), แก้ไขเคส, และปิดงาน (Resolve)
   - **ปัญหาที่พบ**: มี Emoji ในปุ่มกด (🙋, ✅, 💾), ยังไม่มีส่วนจัดการและแสดงผลการแนบไฟล์หลักฐานเมื่อปิดเคส (Resolution Evidence Attachment Control), และยังไม่มีช่องบันทึกสรุปแนวทางแก้ไขอย่างชัดเจน (Resolution Summary)

4. **`References/DataSources.json`**:
   - ชี้ไปยัง SharePoint List `Cases` ที่ไซต์ `PowerAppPRD`
   - ในตาราง `Cases` มีความสามารถ Native Attachment (`{Attachments}`, `{HasAttachments}`) และคอลัมน์เวลาปิด (`ClosedAt`, `ResolvedAt`, `StatusNote`) พร้อมใช้งานแล้ว

---

## ผลกระทบต่อระบบ (Feature Impact)

### ส่วนที่ได้รับผลกระทบ (Affected Areas)
- [ ] New standalone feature
- [x] Extends existing component (ขยายขีดความสามารถการแนบไฟล์หลักฐาน และตัวกรองขั้นสูง)
- [x] Modifies existing behavior (ปรับสไตล์ให้เป็น Modern UI ปราศจาก Emoji, ปรับสูตร Power Fx ให้รองรับ Delegation)
- [x] Cross-cutting concern (การจัดเก็บไฟล์แนบใน SharePoint, การแสดงผลบนขนาดหน้าจอ Laptop)

### รายการไฟล์ที่ต้องแก้ไขหรือปรับปรุง (Files Likely to Change)
| ไฟล์ | ประเภทการเปลี่ยนแปลง | เหตุผล |
|---|---|---|
| `Monitor_case_Helpdesk/Src/Home_incident.pa.yaml` | Modify | ลบ Emoji ทั้งหมด, ปรับ Layout เป็น Modern Dense Dashboard เหมาะกับ Laptop, ปรับสูตร Filter ให้เป็น Delegable |
| `Monitor_case_Helpdesk/Src/updateincident.pa.yaml` | Modify | ลบ Emoji, เพิ่ม Attachment DataCard สำหรับแนบไฟล์หลักฐานปิดเคส, ปรับ Form Layout ให้ทันสมัย |
| `Monitor_case_Helpdesk/Src/App.pa.yaml` | Modify | ปรับปรุงชุดสี (Color Palette) และ Styling Variables ให้ดูเป็น Professional Enterprise |
| `SharePoint List: Cases` (Schema Configuration) | Schema Enhance | ตรวจสอบ/เปิดใช้ Attachment, สร้าง Indexed Columns (Statuscase, Created, CaseID) เพื่อรองรับการค้นหาข้อมูลขนาดใหญ่ |

---

## ข้อเสนอแนะเชิงกลยุทธ์ (Recommendations)

### ตัวชี้วัดความซับซ้อน (Complexity Indicators)
- **Story Count**: Medium (6-8 Stories) ครอบคลุม UI Redesign, Attachment Management, Delegation Filtering, และ Responsive Laptop Layout
- **Domain Boundaries**: 2 โดเมนหลัก
  1. *Monitoring & High-Volume Filtering*: หน้าแดชบอร์ดหลัก การค้นหา การเรียงลำดับ การแบ่งหน้า/โหลดเพิ่ม
  2. *Case Action & Resolution Evidence*: หน้าแก้ไขสถานะ การบันทึกปิดงาน และการอัปโหลดไฟล์หลักฐาน
- **User Types**: 2 กลุ่มผู้ใช้งาน (Operator/IT Support ผู้ใช้งานประจำวันบน Laptop, Manager/Lead ผู้ตรวจดูภาพรวม)

### ข้อเสนอแนะสำหรับ Decision Gates
- **Personas**: **Yes** — ผู้ใช้งาน Helpdesk บน Laptop ต้องการความรวดเร็วในการคลิกและการอ่านตารางข้อมูล (Data Density) ที่แตกต่างจากผู้บริหาร
- **Units**: **Yes** — ควรแยกเป็น 2 หน่วยการทำงาน (Unit 1: Modern Dashboard & Delegable Filter, Unit 2: Case Action & Resolution Evidence)
- **NFR (Non-Functional Requirements)**: **Yes** — ประสิทธิภาพการโหลดข้อมูลขนาดใหญ่ (Delegation Limit < 2,000 / Delegation Warnings = 0), UI Polish & Consistency (Fluent Design System, No Emoji)

---

## ขั้นตอนต่อไป (Next Steps)
เข้าสู่ขั้นตอนกำหนดความต้องการ (Phase 2: Requirements) โดยเริ่มจาก Decision Gate 1 (D1) เพื่อยืนยันขอบเขตการออกแบบและฟีเจอร์ร่วมกับผู้ใช้
