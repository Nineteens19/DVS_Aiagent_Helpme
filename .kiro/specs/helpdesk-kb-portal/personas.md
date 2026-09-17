# Personas: Helpdesk Knowledge Base Management Portal

## Overview
ระบบ **Helpdesk Knowledge Base Management Portal (`helpdesk-kb-portal`)** ให้บริการผู้ใช้งาน 3 กลุ่มหลักที่มีเป้าหมายและลักษณะการใช้งานที่แตกต่างกันอย่างชัดเจน

---

## Persona 1: สมชาย — IT Helpdesk Administrator (ผู้ดูแลระบบงานประจำวัน)

**Demographics**:
- **ตำแหน่ง**: Senior IT Helpdesk Support Specialist
- **ความเชี่ยวชาญด้านเทคนิค**: สูง (เข้าใจสถาปัตยกรรมระบบ, โครงสร้างข้อมูล SharePoint, และการทำงานของ AI Chatbot)
- **ความถี่ในการใช้งาน**: ทุกวัน (Daily, 5-10 ครั้งต่อวัน)

**Goals**:
- จัดการไฟล์คู่มือระบบ (PDF/Word) ให้ตรงหมวดหมู่และระบบงานอย่างรวดเร็ว
- แก้ไขข้อคำถาม-คำตอบ (Q&A) เมื่อพบว่ามีขั้นตอนการทำงานหรือลิงก์ของระบบเปลี่ยนไป
- สลับปิดการใช้งานคำถามที่หมดอายุ (`Inactive`) ได้ทันทีในคลิกเดียว เพื่อไม่ให้ AI นำข้อมูลเก่าไปตอบผู้ใช้
- นำคำถามที่พนักงานถามเข้ามาแล้ว AI ตอบไม่ได้ (จาก `KnowledgeGaps`) มาเขียนคำตอบและแปลงเข้าสู่ฐานข้อมูล Q&A ได้ง่ายๆ โดยไม่ต้องคัดลอกข้ามไปมา

**Pain Points**:
- การจัดการไฟล์และโฟลเดอร์ผ่าน SharePoint Modern View ปกติมีความเทอะทะ ช้า และสับสนเมื่อมีไฟล์จำนวนมาก
- เวลาต้องการสลับสถานะ Q&A เป็น Inactive ต้องกดเข้าไปในฟอร์มแก้ไขหลายขั้นตอน
- เมื่อเห็นคำถามใน Knowledge Gaps ต้องเปิดแท็บใหม่เพื่อไปเพิ่มใน Q&A และพิมพ์ข้อมูลซ้ำซ้อน

**User Journey**:
1. **Entry**: เปิดแอปพลิเคชันพอร์ทัลบนคอมพิวเตอร์ Laptop (Desktop 16:9) เพื่อตรวจดูสถานะคลังความรู้
2. **Action**: ตรวจดูคำถามในแท็บ Knowledge Gaps แล้วกดปุ่ม "แปลงเป็น Q&A" เพื่อใส่คำตอบ แล้วกดบันทึก
3. **Outcome**: AI มีข้อมูลตอบคำถามข้อนั้นทันทีในรอบการสืบค้นถัดไป ช่วยลดจำนวนเคสโทรสอบถาม IT Helpdesk

**Implications for Requirements**:
- หน้าจอต้องจัดแบบ High Data Density แถวกระชับ 44px เห็นข้อมูลได้เยอะต่อหน้าจอ Laptop
- มีปุ่ม Quick Toggle สำหรับเปลี่ยนสถานะ `Active`/`Inactive` ทันทีในแถวตาราง
- มีปุ่ม 1-Click Convert จาก Knowledge Gaps ไปยังแบบฟอร์ม Q&A ทันที

---

## Persona 2: กัญญา — Business Analyst / System Owner (ผู้ตรวจสอบและอนุมัติมาตรฐาน)

**Demographics**:
- **ตำแหน่ง**: Lead Business Analyst & Application Owner
- **ความเชี่ยวชาญด้านเทคนิค**: ปานกลาง-สูง (เชี่ยวชาญ Flow ธุรกิจและระเบียบปฏิบัติมาตรฐาน SOP ของแต่ละระบบ)
- **ความถี่ในการใช้งาน**: สัปดาห์ละ 2-3 ครั้ง (Weekly)

**Goals**:
- ตรวจสอบความถูกต้องของเอกสารคู่มือระบบและขั้นตอนการทำงานก่อนเผยแพร่ให้พนักงานใช้งาน
- อนุมัติสถานะคู่มือเป็น `Approved` เพื่อให้ AI ดึงไปใช้ตอบอย่างเป็นทางการ
- เพิ่มรายชื่อระบบงานใหม่ใน Master List `Systems` เมื่อมีโครงการหรือระบบใหม่เริ่มใช้งานในองค์กร
- ติดตามตัวชี้วัดความครอบคลุมของคลังความรู้ (Coverage KPIs)

**Pain Points**:
- ไม่มั่นใจว่าเอกสารที่เจ้าหน้าที่ Helpdesk อัปโหลดเป็นเวอร์ชันล่าสุดและผ่านการตรวจสอบแล้วหรือไม่
- กลัวว่า AI จะนำเอกสารฉบับร่าง (Draft) หรือเอกสารเก่าที่ยกเลิกไปแล้วมาตอบพนักงาน

**User Journey**:
1. **Entry**: ได้รับแจ้งว่ามีคู่มือระบบงานเวอร์ชันใหม่เข้าสู่ระบบ
2. **Action**: เปิดแท็บคลังคู่มือระบบ เลือกกรองดูเอกสารสถานะ `Draft` เปิดพรีวิวอ่านเนื้อหา และคลิกปรับสถานะเป็น `Approved`
3. **Outcome**: ระบบอนุมัติและพร้อมให้ AI ดึงไปสังเคราะห์คำตอบ มั่นใจว่าเนื้อหาถูกต้องตามนโยบายบริษัท 100%

**Implications for Requirements**:
- ต้องมีตัวกรองสถานะเอกสาร (`Draft`, `Approved`, `Archived`) ที่เด่นชัด
- มีระบบพรีวิวเปิดดูไฟล์ได้ทันทีโดยไม่ต้องดาวน์โหลดลงเครื่อง
- มีแท็บจัดการ Master List `Systems` เพื่อเพิ่มระบบใหม่และกำหนดการแสดงผล

---

## Persona 3: นารี — General Employee (พนักงานทั่วไป / ผู้ใช้งานอ่านอย่างเดียว)

**Demographics**:
- **ตำแหน่ง**: พนักงานสายงานรับประกันภัย/สินไหม/สำนักงานใหญ่
- **ความเชี่ยวชาญด้านเทคนิค**: ทั่วไป (ใช้งานแอปพลิเคชันผ่านเบราว์เซอร์)
- **ความถี่ในการใช้งาน**: เป็นครั้งคราว (เมื่อต้องการค้นหาคู่มือระบบเต็มเล่ม)

**Goals**:
- ค้นหาคู่มือการใช้งานระบบฉบับทางการ (Official User Manuals) ที่ถูกต้องและอัปเดตล่าสุด
- เปิดอ่านหรือดาวน์โหลดเอกสารคู่มือที่เกี่ยวข้องกับงานของตนเอง

**Pain Points**:
- ไม่ทราบว่าคู่มือของระบบต่างๆ ถูกเก็บไว้ที่ไซต์ใดของ SharePoint
- ค้นหาใน Search ทั่วไปแล้วพบเอกสารซ้ำซ้อนหลายเวอร์ชัน

**User Journey**:
1. **Entry**: เข้าลิงก์พอร์ทัลคลังความรู้ผ่านหน้าอินทราเน็ตองค์กร
2. **Action**: ระบบตรวจจับว่าเป็นพนักงานทั่วไป จึงเปิดโหมด Read-only ให้นารีพิมพ์ค้นหาชื่อระบบและดาวน์โหลดคู่มือ
3. **Outcome**: ได้รับเอกสารทางการฉบับล่าสุด และไม่สามารถเผลอกดแก้ไขหรือลบเอกสารใดๆ ได้

**Implications for Requirements**:
- ต้องมี Role-Based Security: ตรวจจับสิทธิ์อัตโนมัติ ซ่อนปุ่มเพิ่ม/ลบ/แก้ไขสำหรับพนักงานทั่วไป
- มีกล่องค้นหาแบบ Instant Search ที่ใช้งานง่าย ไม่ซับซ้อน

---

## Persona-Requirement Matrix

| รหัสข้อกำหนด | รายละเอียดความต้องการ | สมชาย (Helpdesk) | กัญญา (BA/Owner) | นารี (Employee) | ลำดับความสำคัญ |
|-------------|----------------------|------------------|-------------------|-----------------|----------------|
| **US-PORTAL-001** | Desktop 16:9 Shell & Module Navigation | Primary | Primary | Secondary | High |
| **US-PORTAL-002** | Real-Time Knowledge Base KPI Metrics | Secondary | Primary | N/A | High |
| **US-PORTAL-003** | System Folder Tree & New Folder Creation | Primary | Secondary | N/A | High |
| **US-PORTAL-004** | Manual File Upload, Metadata & Status Governance | Primary | Primary | N/A | High |
| **US-PORTAL-005** | High-Density Q&A Grid with Quick Toggle | Primary | Secondary | Secondary (Read) | High |
| **US-PORTAL-006** | Sliding Side Drawer for Q&A Full Editor | Primary | Primary | N/A | High |
| **US-PORTAL-007** | 1-Click Gap-to-Q&A Converter Loop | Primary | Secondary | N/A | High |
| **US-PORTAL-008** | Master Systems Dynamic Sync & RBAC Guard | Secondary | Primary | Primary (Guard) | High |

---

## Design Implications

- **Architecture**: แยกโมดูลการเข้าถึงข้อมูลตามบทบาท (RBAC Permission Trim) โดยพนักงานทั่วไปเข้าถึงเฉพาะฟังก์ชัน Read-only ของคลังเอกสารและ Q&A
- **UI/UX**: ยึดมาตรฐาน Modern Enterprise Design System แนวนอน 16:9 ใช้ Auto-layout Containers เพื่อรองรับความละเอียดหน้าจอตั้งแต่ 1366x768 ถึง 1920x1080 โดยไม่ต้อง Scroll แนวนอน ปราศจาก Emoji 100%
- **Data & Safety**: คลังคู่มือและ Q&A ต้องมีกลไกป้องกันการลบ (Delete Confirmation Dialog) และบังคับการเลือกชื่อระบบจาก Master List `Systems` เท่านั้น เพื่อป้องกันปัญหาชื่อระบบไม่ตรงกัน
