# Design Specification: Component Architecture (`helpdesk-kb-portal`)

## Overview
สถาปัตยกรรมเชิงคอมโพเนนต์ของแอปพลิเคชัน **Helpdesk Knowledge Base Management Portal (`helpdesk-kb-portal`)** ออกแบบตามมาตรฐาน **4-Tier Container Auto-Layout Desktop 16:9** โดยแบ่งหน้าที่การทำงานของคอมโพเนนต์ออกเป็นส่วนควบคุมโครงสร้างหลักและโมดูลการจัดการคลังความรู้

---

## 1. Core Shell & Navigation Components (`portal-shell-manuals`)

### 1.1 `TopBarHeader` (Tier 1 Component)
- **Container**: `con_Header` (ความสูง 64px, พื้นหลังสี Deves Deep Navy `#012169`)
- **Responsibilities**:
  - แสดงชื่อระบบทางการ: "ระบบบริหารจัดการคลังความรู้ไอที (IT Helpdesk Knowledge Base Portal)"
  - แสดงแท็บสลับโมดูลหลัก 3 แท็บ (Segmented Tab Bar):
    - `tab_Manuals`: คลังคู่มือระบบ (`SystemManuals`)
    - `tab_QnA`: ฐานข้อมูล Q&A (`AI_KnowledgeBase`)
    - `tab_Gaps`: คำถามที่ AI ตอบไม่ได้ (`KnowledgeGaps`)
  - แสดงข้อมูลผู้ใช้งานปัจจุบัน (`varCurrentUser.FullName`), ระดับสิทธิ์ (`varUserRole`), และปุ่มรีเฟรชข้อมูล (`btn_RefreshAll`)

### 1.2 `KPISummaryBar` (Tier 2 Component)
- **Container**: `con_KPIBar` (ความสูง 96px, พื้นหลังสี Light Slate Gray `#F8FAFC`)
- **Responsibilities**:
  - แสดงการ์ดสถิติ 5 ใบ (KPI Stat Cards) พร้อมคำนวณแบบเรียลไทม์:
    1. `card_TotalManuals`: จำนวนไฟล์คู่มือทั้งหมดใน Library
    2. `card_ApprovedManuals`: จำนวนคู่มือสถานะ `Approved` (ที่ AI ใช้งานได้)
    3. `card_TotalQnA`: จำนวนข้อคำถามทั้งหมด (ปัจจุบัน 74+)
    4. `card_ActiveQnA`: จำนวนข้อคำถามสถานะ `Active`
    5. `card_PendingGaps`: จำนวนคำถามที่ AI ตอบไม่ได้และยังรอการเพิ่มคำตอบ
  - รองรับการคลิกที่การ์ดเพื่อทำ Quick Filter ในตารางด้านล่างโดยอัตโนมัติ

### 1.3 `ControlFilterBar` (Tier 3 Component)
- **Container**: `con_FilterBar` (ความสูง 56px, ขอบล่าง `#E2E8F0`)
- **Responsibilities**:
  - `txt_SearchBox`: กล่องค้นหาแบบพิมพ์ทันใจ (Instant Search) ขยายความกว้าง 320px
  - `cmb_SystemFilter`: Dropdown เลือกระบบงาน ผูกตรงกับ Master List `Systems`
  - `btn_ActionPrimary`: ปุ่มดำเนินการหลักตามแท็บปัจจุบัน:
    - ในแท็บคู่มือ: ปุ่ม `+ สร้างโฟลเดอร์ระบบใหม่` และปุ่ม `+ อัปโหลดคู่มือ`
    - ในแท็บ Q&A: ปุ่ม `+ เพิ่ม Q&A ใหม่`
  - `btn_ClearFilters`: ปุ่มรีเซ็ตตัวกรองกลับสู่ค่าตั้งต้น

---

## 2. Module Content & Grid Components

### 2.1 `ManualsLibraryWorkspace` (โมดูลคลังคู่มือระบบ)
- **Component**: `gal_ManualsGrid` & `con_FolderTree`
- **Responsibilities**:
  - ฝั่งซ้าย: แสดงโฟลเดอร์แยกตามระบบงาน (`DSS`, `Renewal_Motor`, `PCS`, `Polisy_400`, `CMI`, `General`)
  - ฝั่งขวา: แสดงตารางไฟล์คู่มือในโฟลเดอร์นั้น ความสูงแถว 44px
  - คอลัมน์ตาราง: ชื่อเอกสาร (`Title`), นามสกุลไฟล์, ระบบงาน (`SystemName`), ประเภท (`DocType`), สถานะ (`Status`), คำสำคัญ (`Keywords`), และปุ่ม Action:
    - ปุ่ม `เปิดดูไฟล์ (View)`: เปิดไฟล์ตัวเต็มในเบราว์เซอร์ผ่าน SharePoint
    - ปุ่ม `Archived`: ระงับเอกสารไม่ให้ AI นำไปตอบ

### 2.2 `QnAKnowledgeGrid` (โมดูลตาราง Q&A ความหนาแน่นสูง)
- **Component**: `gal_QnATable`
- **Responsibilities**:
  - แสดงตารางข้อมูลคำถาม-คำตอบ ความสูงแถว 44px (12-15 แถวต่อหน้าจอ Laptop)
  - คอลัมน์: รหัสคำถาม, ระบบงาน, หมวดหมู่, หัวข้อคำถาม (`Title`), สถานะ (`Status`)
  - **Quick Active Toggle**: ปุ่มสวิตช์ในแถว สลับค่า `Active` / `Inactive` ได้ทันทีใน 1 คลิก พร้อมอัปเดตสถานะใน SharePoint List `AI_KnowledgeBase`
  - คลิกเลือกแถวเพื่อเปิดดูรายละเอียดฉบับเต็มใน Side Drawer

### 2.3 `KnowledgeGapsGrid` (โมดูลคำถามที่ AI ตอบไม่ได้)
- **Component**: `gal_GapsTable`
- **Responsibilities**:
  - แสดงรายการคำถามที่บอทตอบไม่ได้ ดึงจาก List `KnowledgeGaps`
  - คอลัมน์: ข้อความคำถามที่พนักงานถาม, ความถี่ที่ถูกถาม (Frequency), วันที่ถามล่าสุด, สถานะ
  - ปุ่ม **"แปลงเป็น Q&A (Create Q&A)"**: ดึงข้อความคำถามส่งต่อไปยัง Side Drawer เพื่อให้แอดมินพิมพ์คำตอบและบันทึกเข้า `AI_KnowledgeBase` ทันที

---

## 3. Side Drawer & Editor Components (`portal-qna-gaps`)

### 3.1 `SlidingSideDrawer` (หน้าต่างสไลด์ด้านข้างสำหรับแก้ไขและสร้าง)
- **Container**: `con_SideDrawer` (ความกว้าง 480px, ความสูง 100% ลอยจากขอบขวา, เงา Soft Shadow)
- **Visibility**: ควบคุมด้วย `varShowDrawer`
- **Responsibilities**:
  - แถบส่วนหัว: แสดงโหมดการทำงาน ("เพิ่มคำถาม-คำตอบใหม่", "แก้ไขข้อคำถาม", หรือ "สร้างคำตอบจาก Knowledge Gap") พร้อมปุ่มปิด `btn_CloseDrawer`
  - แบบฟอร์มกรอกข้อมูล (`form_QnAEditor`):
    - `txt_QnATitle`: หัวข้อคำถามหลัก (Single line of text)
    - `txt_QnAQuestion`: รายละเอียดคำถามเพิ่มเติม (Multiple lines of text)
    - `txt_QnAAnswer`: คำตอบและขั้นตอนการแก้ปัญหาที่ถูกต้อง (Multiple lines of text)
    - `cmb_QnASystem`: Dropdown เลือกระบบงาน (ผูกตรงกับ Master List `Systems`)
    - `cmb_QnACategory`: หมวดหมู่ปัญหา
    - `txt_QnAKeywords`: คำสำคัญหรือคำพ้องความหมาย (Synonyms)
    - `tgl_QnAStatus`: สวิตช์สถานะ `Active`/`Inactive`
  - ปุ่มบันทึกข้อมูล (`btn_SaveQnA`): ตรวจสอบความถูกต้องและสั่งบันทึกลง SharePoint
  - ปุ่มลบ (`btn_DeleteQnA`): แสดงเฉพาะโหมดแก้ไข พร้อมกล่องยืนยันการลบ

---

## 4. Security & Access Control Component

### 4.1 `RBACGuardController`
- **Responsibilities**:
  - ตรวจสอบอีเมลของผู้ใช้กับรายชื่อกลุ่มสิทธิ์ IT Helpdesk & BA Team ใน `App.OnStart`
  - หากเป็นผู้ใช้ทั่วไป:
    - ซ่อนปุ่ม `+ สร้างโฟลเดอร์`, `+ อัปโหลดคู่มือ`, `+ เพิ่ม Q&A ใหม่`, ปุ่มลบ, และสวิตช์ Toggle
    - เปิดใช้งานในโหมด Read-only เพื่อให้ค้นหาและอ่านคู่มือได้เท่านั้น
