# Non-Functional Requirements (NFR) — Monitor_case_Helpdesk

## 1. Performance & Responsiveness

| Metric | Target SLA | Strategy / Implementation |
|--------|------------|---------------------------|
| **Initial Screen Load Time** | < 2.0 วินาที | ไม่โหลดข้อมูลทั้งหมดเข้า Memory Collection; ผูก Gallery ตรงกับ SharePoint List |
| **Server-Side Filter Latency** | < 1.5 วินาที (p95) | ใช้ Indexed Columns (`Statuscase`, `CaseID`, `SystemName`, `Created`) และใช้สูตร Delegable 100% |
| **Delegation Warning Count** | **0 Warning** | หลีกเลี่ยงฟังก์ชัน Non-delegable เช่น `In`, `Search()`, `CountRows()` บนตารางใหญ่ |
| **Side Drawer Interaction** | < 150 ms | ควบคุมผ่าน Boolean Context Variable (`varShowDrawer`) โดยไม่ต้อง Navigate ข้ามหน้าจอ |
| **Form Submit & File Upload** | < 3.0 วินาที (สำหรับไฟล์ 5MB) | ใช้ `SubmitForm()` แบบ Native Streaming ผ่าน SharePoint Connector |

---

## 2. Scalability & High-Volume Data Management

- **Data Ceiling**: รองรับข้อมูลเคสสะสมได้มากกว่า 50,000 แถว โดยไม่เกิดปัญหาคอขวด 2,000 แถว
- **Data Pagination**: Power Apps Gallery ดึงข้อมูลจากเซิร์ฟเวอร์แบบ On-demand Paging ทีละ 100 แถวโดยอัตโนมัติเมื่อผู้ใช้เลื่อนหน้าจอ
- **Indexed Server Queries**: ทุกเงื่อนไขตัวกรองหลักถูกจัดทำ Index บน SharePoint เพื่อให้ OData Server Filter ประมวลผลได้อย่างรวดเร็ว

---

## 3. Usability, Ergonomics & Design Standards

- **Modern Enterprise Aesthetics**:
  - **Zero Emoji Compliance**: ห้ามมี Emoji (เช่น 📋, 🟢, 🔴, ⚠️) ในส่วนประกอบใดๆ ของหน้าจอ ตัวอักษร ป้ายสถานะ หรือข้อความแจ้งเตือน 100%
  - **Deves Corporate Palette**: ใช้สีหลัก Deves Deep Navy (`#012169`) ผสานกับ Neutral Slate และ Semantic Status Badges
- **Laptop / High Data Density Optimization**:
  - ออกแบบสำหรับหน้าจอแนวนอน 16:9 (ความละเอียดเป้าหมาย 1366x768 และ 1920x1080)
  - ความสูงแถวของตารางเคสกำหนดที่ 44px แสดงผลได้ 12-15 เคสในหน้าจอเดียวโดยไม่ต้องเลื่อนหน้าจอมาก
  - การใช้งาน Side Drawer ความกว้าง 480px ช่วยให้เจ้าหน้าที่ยังคงมองเห็นแถวเคสในตารางหลักขณะกำลังกรอกข้อมูลปิดเคส
- **Accessibility & Contrast**:
  - ทุกสีตัวอักษรและพื้นหลังผ่านเกณฑ์ WCAG 2.1 Level AA (Contrast Ratio >= 4.5:1)
  - ฟอนต์อ่านง่าย ชัดเจน (Segoe UI / Open Sans)

---

## 4. Security, Compliance & Data Governance

- **Authentication**: Single Sign-On (SSO) อัตโนมัติผ่าน Microsoft Entra ID (Azure Active Directory)
- **Role-Based Access Control (RBAC)**:
  - สิทธิ์ระดับ Helpdesk Operator: อ่านเคสทั้งหมด, อัปเดตและปิดเคสตนเอง/ในทีม
  - สิทธิ์ระดับ Supervisor / Lead: บริหารจัดการเคส ดูรายงานสถิติ และปรับแต่งการมอบหมาย
  - ควบคุมสิทธิ์ระดับข้อมูลผ่าน SharePoint List Permission Levels (Contribute / Read)
- **Data Encryption**:
  - Encryption at Rest: มาตรฐาน AES-256 ของ Microsoft 365 SharePoint Online
  - Encryption in Transit: บังคับใช้โปรโตคอล TLS 1.2+ ทุกทราฟฟิก
- **Attachment Protection**:
  - ระบบตรวจสอบและสแกนไวรัส/มัลแวร์อัตโนมัติผ่าน Microsoft Defender for Office 365 เมื่อมีการอัปโหลดไฟล์แนบเข้า SharePoint
  - จำกัดขนาดไฟล์แนบไม่เกิน 25 MB ต่อไฟล์

---

## 5. Auditability & Traceability

- **Immutable Timestamping**:
  - บันทึกเวลาปิดเคสจริงลงใน `ResolvedAt` ด้วยเวลาเครื่องแม่ข่าย
  - บันทึกผู้ดำเนินการปิดเคสลงใน `ResolvedBy`
- **Resolution Evidence Integrity**:
  - ฟอร์มบังคับให้แนบไฟล์หลักฐานอย่างน้อย 1 ไฟล์ และระบุสรุปแนวทางแก้ไขอย่างน้อย 10 ตัวอักษร จึงจะปลดล็อกปุ่มส่งข้อมูล
  - ประวัติไฟล์แนบจะถูกเก็บถาวรร่วมกับเคสใน SharePoint ไม่สามารถถูกลบโดยพลการได้
