# กลุ่มผู้ใช้งาน (Personas) — Monitor_case_Helpdesk

## สรุปภาพรวม (Overview)
ระบบ **Monitor_case_Helpdesk** ให้บริการกลุ่มผู้ใช้งานหลัก 2 กลุ่มที่มีบทบาท ความต้องการ และลักษณะการใช้งานบนหน้าจอคอมพิวเตอร์พกพา (Laptop) แตกต่างกัน:

---

## Persona 1: สมชาย (Somchai) — IT Support / Helpdesk Operator

**ข้อมูลพื้นฐาน (Demographics)**:
- **ตำแหน่ง / บทบาท**: เจ้าหน้าที่ฝ่ายสนับสนุนระบบสารสนเทศ (IT Helpdesk Specialist Tier 1/2)
- **ทักษะทางเทคนิค (Technical Proficiency)**: ระดับกลาง - สูง (Intermediate - Expert)
- **ความถี่ในการใช้งาน (Usage Frequency)**: ทุกวัน (เปิดแอปพลิเคชันทำงานตลอด 8 ชั่วโมงต่อวันบน Laptop จอ 14-15 นิ้ว)

**เป้าหมายหลัก (Goals)**:
- **Primary**: คัดกรองและค้นหาเคสปัญหาที่ได้รับมอบหมายได้อย่างรวดเร็ว โดยมีพื้นที่แสดงข้อมูลในแนวตั้งและแนวนอนกระชับที่สุด (High Information Density) ไม่ต้องเลื่อนหน้าจอไปมา
- **Secondary**: รับเคสเข้าสู่การดูแล (Assign to Me) และอัปเดตสถานะงานได้อย่างสะดวก พร้อมอัปโหลดไฟล์หลักฐานยืนยันการแก้ไข (เช่น Screenshot, Log, เอกสารผลทดสอบ) ก่อนปิดงาน

**จุดติดขัดในปัจจุบัน (Pain Points)**:
- หน้าจอเดิมมีการใช้ Emoji จำนวนมาก (🛡️, 📋, 🔵, 🟢, 🙋, ✅) ทำให้ดูไม่เป็นมาตรฐานระดับ Enterprise และไม่น่าเชื่อถือเมื่อต้องแชร์หน้าจอประสานงานกับผู้ใช้งานหรือผู้บริหาร
- การจัดวางหน้าจอ (Layout) แบบเดิมหลวมเกินไป แสดงผลได้เพียงไม่กี่แถว ต้องเลื่อนเมาส์บ่อย
- ยังไม่มีที่แนบไฟล์หลักฐานตอนปิดเคส ทำให้บางครั้งต้องเก็บไฟล์หลักฐานไว้ในเครื่องส่วนตัวหรือส่งทางอีเมลแยกต่างหาก ตรวจสอบย้อนหลังได้ยาก
- ตัวกรองค้นหาเคสเก่าทำงานช้า และกังวลว่าจะค้นหาเคสย้อนหลังไม่พบเมื่อข้อมูลสะสมเกิน 2,000 แถว

**พฤติกรรมการใช้งาน (User Journey)**:
1. **Entry**: เปิดหน้าต่างเบราว์เซอร์เข้าสู่ `Home_incident` บน Laptop
2. **Action**: ดูตัวเลขเคสค้างบน KPI Bar, คลิกเลือกแท็บสถานะ "รอรับเรื่อง", ค้นหาเคสด้วย CaseID หรือชื่อระบบ, คลิกเปิด Detail Drawer ด้านขวาเพื่ออ่านรายละเอียด, กดรับงาน และเมื่อแก้ไขเสร็จพิมพ์สรุปผลพร้อมแนบภาพหลักฐาน แล้วกด Resolve
3. **Outcome**: เคสถูกปิดอย่างถูกต้อง มีหลักฐานผูกติดกับเคสใน SharePoint ผู้แจ้งได้รับการแจ้งเตือนอัตโนมัติ

**ผลกระทบต่อข้อกำหนด (Implications for Requirements)**:
- ออกแบบเป็น Master-Detail Split Screen / Compact Grid with Side Drawer (ไม่ต้องสลับหน้าจอไปมา)
- ใช้ชุดไอคอนเวกเตอร์สไตล์ Fluent UI ปราศจาก Emoji 100%
- เพิ่มส่วนควบคุมการแนบไฟล์หลักฐาน (Attachment Control) พร้อมฟังก์ชันลบ/ดูตัวอย่างไฟล์ก่อนบันทึก

---

## Persona 2: วิภา (Wipha) — Helpdesk Lead & Supervisor

**ข้อมูลพื้นฐาน (Demographics)**:
- **ตำแหน่ง / บทบาท**: หัวหน้าทีม IT Helpdesk และผู้ควบคุมคุณภาพงานบริการ (Service Delivery Lead / Supervisor)
- **ทักษะทางเทคนิค (Technical Proficiency)**: ระดับกลาง (Intermediate)
- **ความถี่ในการใช้งาน (Usage Frequency)**: ทุกวัน (มอนิเตอร์ภาพรวม) และทุกสัปดาห์ (ตรวจสอบรายงานและ SLA) บน Laptop

**เป้าหมายหลัก (Goals)**:
- **Primary**: ตรวจสอบภาพรวมปริมาณเคส คอขวดของงาน และเคสที่เสี่ยงหรือหลุด SLA ผ่านตัวชี้วัดบน Dashboard
- **Secondary**: ตรวจสอบความถูกต้องของเคสที่ปิดไปแล้ว (Quality Audit) ว่ามีแนวทางแก้ไขและไฟล์หลักฐานยืนยันครบถ้วนจริงหรือไม่

**จุดติดขัดในปัจจุบัน (Pain Points)**:
- เจ้าหน้าที่บางท่านกดปิดเคสโดยไม่มีการระบุแนวทางแก้ไขที่ชัดเจน และไม่มีหลักฐานยืนยัน ทำให้เมื่อเกิดปัญหาซ้ำไม่สามารถอ้างอิงข้อมูลเก่าได้
- การกรองข้อมูลเคสย้อนหลังของทั้งแผนกอาจติดปัญหา Delegation Limit ของ SharePoint ทำให้ตัวเลขสรุปหรือเคสในอดีตตกหล่น
- ขาดฟิลด์สรุปผลการปิดงานที่เป็นมาตรฐาน (Structured Resolution) สำหรับดึงไปทำรายงานหรือ Power BI

**พฤติกรรมการใช้งาน (User Journey)**:
1. **Entry**: เปิดหน้า Dashboard เพื่อดูสรุปตัวชี้วัดประจำวัน (Total Cases, Active, SLA Breached)
2. **Action**: กรองดูเคสของแต่ละระบบ หรือเคสที่ปิดแล้วในรอบเดือน เพื่อสุ่มตรวจสอบไฟล์หลักฐานและแนวทางการแก้ปัญหา
3. **Outcome**: ได้รับข้อมูลที่ถูกต้อง เคสทุกเคสมีหลักฐานตรวจสอบได้ ข้อมูลใน SharePoint มีความสมบูรณ์พร้อมส่งต่อฝ่ายบริหาร

**ผลกระทบต่อข้อกำหนด (Implications for Requirements)**:
- เพิ่มกฎการตรวจสอบ (Validation Rule) บังคับกรอก `ResolutionSummary` และบังคับแนบไฟล์หลักฐานก่อนปิดเคส
- ใช้สูตร Power Fx ที่ Delegable 100% และกำหนด Indexed Columns บน SharePoint เพื่อให้ข้อมูลแสดงผลครบถ้วนเสมอ
- เตรียมตัวแปรและโครงสร้างข้อมูลสำหรับคำนวณเวลาการแก้ไข (Resolution Hours / SLA Met)

---

## ตารางความสัมพันธ์ Persona กับความต้องการ (Persona-Requirement Matrix)

| ความต้องการ (Requirement Area) | สมชาย (Operator) | วิภา (Supervisor) | Priority |
|---|---|---|---|
| REQ-01: Modern Enterprise UI (ลบ Emoji ทั้งหมด ใช้ Fluent Design) | Primary | Primary | High |
| REQ-02: Laptop Master-Detail Split Grid & Side Drawer | Primary | Secondary | High |
| REQ-03: Delegable High-Volume Search & Filter | Primary | Primary | High |
| REQ-04: Resolution Summary & Evidence Attachment Component | Primary | Primary | High |
| REQ-05: Strict Validation for Case Resolution | Secondary | Primary | High |
| REQ-06: KPI Summary Bar & SLA Status Tracking | Secondary | Primary | Medium |
| REQ-07: SharePoint Schema & Indexing Configuration Guidance | N/A | Primary | High |

**คำอธิบายระดับ**: Primary (ความต้องการหลักประจำวัน), Secondary (ความต้องการรอง/ติดตามผล), N/A (ไม่เกี่ยวข้องโดยตรงกับระดับปฏิบัติการ)

---

## ผลต่อการออกแบบระบบ (Design Implications)

- **UI/UX**: เน้นความสะอาดตา โทนสีมาตรฐานองค์กร (Corporate Slate / Deep Blue) คอลัมน์ตารางชัดเจน ขอบมนเล็กน้อย (Rounded 4px) ข้อมูลแสดงผลแบบ Compact เพื่อให้แสดงผลแถวได้ 15-20 แถวต่อหนึ่งหน้าจอบน Laptop 1080p/768p
- **Data & Architecture**: การสืบค้นข้อมูลใน Power Fx จะต้องไม่ใช้ฟังก์ชันที่ไม่รองรับ Delegation บน SharePoint เช่น ฟังก์ชันกลุ่ม Text Manipulation ที่ซับซ้อน หรือตัวดำเนินการที่ตัดทอนชุดข้อมูลในหน่วยความจำ
- **Validation**: ฟอร์มการปิดงานจะต้องมีระบบตรวจเช็คไฟล์แนบ `CountRows(DataCardValue_Attachments.Attachments) > 0` และ `!IsBlank(txt_ResolutionSummary.Text)` ก่อนอนุญาตให้กดบันทึก
