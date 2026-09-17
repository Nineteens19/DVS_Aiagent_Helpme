# คู่มือการติดตั้งและจัดเตรียมฐานความรู้ (Knowledge Base Setup Guide)
## สำหรับ HelpMe Agent บน Microsoft Copilot Studio & SharePoint Online

เอกสารฉบับนี้จัดทำขึ้นเพื่อให้ผู้ดูแลระบบ (SharePoint / M365 Administrator / IT Helpdesk) ดำเนินการจัดเตรียม **SharePoint Document Library** และ **SharePoint List** บน Site กลาง เพื่อใช้เป็นระบบจัดการองค์ความรู้ (Knowledge Base Management System) ที่ปลอดภัย สะดวก และเชื่อมต่อกับ HelpMe Agent ได้อย่างเต็มประสิทธิภาพ

---

### ข้อมูลสภาพแวดล้อมระบบ (Environment Information)
- **SharePoint Site กลาง**: `https://dvsins.sharepoint.com/sites/PowerAppPRD` (Site เดียวกับ `Cases` และ `KnowledgeGaps`)
- **Copilot Studio Agent**: `HelpMe Agent` (`cr616_helpMeAgentUat`)

---

## ส่วนที่ 1: การสร้าง Document Library สำหรับคู่มือระบบ (SystemManuals)

ส่วนนี้ใช้สำหรับเก็บไฟล์คู่มือระบบ (PDF, Word, Excel, PowerPoint) เพื่อให้ HelpMe Agent ทำ Semantic Search ค้นหาเนื้อหาภายในเล่มมาตอบผู้ใช้ได้ทันที

### 1.1 ขั้นตอนการสร้าง Library
1. เข้าไปที่หน้าแรกของ SharePoint Site: `https://dvsins.sharepoint.com/sites/PowerAppPRD`
2. คลิกปุ่ม **+ New** (ด้านซ้ายบน) > เลือก **Document library**
3. กำหนดชื่อ Library:
   - **Name**: `SystemManuals`
   - **Description**: `แหล่งเก็บเอกสารและคู่มือการใช้งานระบบสำหรับ HelpMe AI Agent`
   - คลิก **Create**

### 1.2 การสร้าง Folder แยกตามระบบ
เพื่อความเป็นระเบียบและง่ายต่อการดูแล ให้คลิก **+ New** > **Folder** สร้างโฟลเดอร์ดังต่อไปนี้:
- `DSS`
- `Renewal_Motor`
- `PCS`
- `Polisy_400`
- `CMI`
- `General` (สำหรับเอกสารทั่วไปหรือนโยบายไอที)

### 1.3 การเพิ่ม Metadata Columns (ออกแบบเพื่อประสิทธิภาพ AI สูงสุด)
ในหน้า Library `SystemManuals` ให้คลิก **+ Add column** ด้านขวาสุดของหัวตาราง เพื่อสร้างคอลัมน์ดังนี้:

| ชื่อคอลัมน์ (Column Name) | ประเภท (Type) | คำอธิบายและการตั้งค่า (AI-Optimized Configuration) |
|--------------------------|---------------|--------------------------------------------------|
| `SystemName` | **Single line of text** | **ดีที่สุดสำหรับ AI**: บันทึกชื่อระบบเป็นข้อความตรงๆ (เช่น `DSS`, `Renewal Motor`, `PCS`, `Polisy 400`, `CMI`, `General`) โดยอิงตาม Master List `Systems`<br>*(การเก็บเป็น Text ทำให้ Copilot Studio Semantic Search สแกนและจับคู่ชื่อระบบได้แม่นยำที่สุด 100% ไม่ติดขัดกับ OData Object)* |
| `DocType` | **Choice** | ตัวเลือก: `User Manual`, `Work Instruction`, `FAQ Document`, `Release Note`<br>*(ตั้งค่า Allow 'Fill-in' choices = Yes เพื่อให้พิมพ์ประเภทเอกสารใหม่เพิ่มเติมได้เอง)* |
| `IsActive` | **Yes/No** | Default value: `Yes` |

---

## ส่วนที่ 2: การสร้าง SharePoint List สำหรับข้อมูล Q&A (AI_KnowledgeBase)

ส่วนนี้ใช้สำหรับเก็บข้อคำถาม-คำตอบสำเร็จรูป (Approved Answers) ที่มีขั้นตอนชัดเจน กฎการ Escalation และการระบุข้อมูลที่จำเป็น (Required Information)

### 2.1 ขั้นตอนการสร้าง List
1. เข้าไปที่ SharePoint Site: `https://dvsins.sharepoint.com/sites/PowerAppPRD`
2. คลิกปุ่ม **+ New** > เลือก **List**
3. เลือก **Blank list**
4. กำหนดชื่อ:
   - **Name**: `AI_KnowledgeBase`
   - **Description**: `ฐานความรู้ Q&A ที่ผ่านการอนุมัติสำหรับ HelpMe Agent`
   - คลิก **Create**

### 2.2 การเปลี่ยนชื่อคอลัมน์ตั้งต้น (Default Title Column)
- คอลัมน์ `Title` ที่มีอยู่แต่เดิม ให้เปลี่ยนชื่อ (Rename) เป็น **`KB_ID`** (เช่น `KB-DSS-001`, `KB-POL-005`)

### 2.3 การสร้างคอลัมน์เพิ่มเติม (Custom Columns)
เข้าไปที่ **Settings (รูปฟันเฟือง)** ขวาบน > **List settings** > คลิก **Create column** เพื่อสร้างคอลัมน์ตามตารางด้านล่าง:

| ชื่อคอลัมน์ (Column Name) | ประเภทข้อมูล (Type) | คำอธิบายและการตั้งค่าที่สำคัญ (Dynamic Configuration) |
|--------------------------|---------------------|--------------------------------------------------|
| `Issue_Title` | Single line of text | หัวข้อปัญหา / คำถามหลักที่พบบ่อย |
| `System` | **Single line of text** | **ดีที่สุดสำหรับ AI**: บันทึกชื่อระบบเป็นข้อความตรงๆ (เช่น `DSS`, `Renewal Motor`, `PCS`, `Polisy 400`, `CMI`, `General`) โดยอิงตาม Master List `Systems`<br>*(การเก็บเป็น Text ทำให้ Copilot Studio และ AI Generative Model จับคู่ความหมายและค้นหาได้แม่นยำที่สุด 100% ไม่ติดขัดกับ OData Object)* |
| `Category` | Choice | ตัวเลือก: `Login/Access`, `Error/Bug`, `How-To`, `Report`, `Master Data`<br>*(ตั้งค่า Allow 'Fill-in' choices = Yes เพื่อให้พิมพ์หมวดหมู่ใหม่เพิ่มเติมได้)* |
| `Keywords` | Multiple lines of text | **เลือก Plain text** — คำค้นหาใกล้เคียง หรือคำพ้องความหมาย (Synonyms) |
| `Approved_Answer` | Multiple lines of text | **เลือก Plain text** — คำตอบและแนวทางแก้ไขที่ยืนยันแล้ว |
| `Required_Information` | Multiple lines of text | **เลือก Plain text** — ข้อมูลที่ผู้ใช้ต้องระบุ (เช่น เลขเคลม, รหัสพนักงาน) |
| `Followup_Question` | Multiple lines of text | **เลือก Plain text** — คำถามที่ AI จะถามเพิ่มหากผู้ใช้ระบุข้อมูลไม่ครบ |
| `Action_Type` | Choice | ตัวเลือก: `Self-Service`, `Incident`, `Service Request`, `Business Support` |
| `Escalation_Rule` | Single line of text | เงื่อนไขการส่งต่อ (เช่น ส่งต่อทีมเคลมหากเป็นเคสเร่งด่วน) |
| `Owner` | Single line of text | ผู้รับผิดชอบ/ทีมงาน เช่น `Helpdesk Tier 2`, `IT Application Support` |
| `Review_Status` | Choice | ตัวเลือก: `Draft`, `Review Required`, `Approved` (ค่าเริ่มต้น: `Draft`) |
| `Is_Active` | Choice | ตัวเลือก: `Active`, `Inactive` (ค่าเริ่มต้น: `Active`) |

> [!IMPORTANT]
> ในคอลัมน์ที่เป็น **Multiple lines of text** ทุกคอลัมน์ ต้องเลือกเป็น **Plain text** เท่านั้น ห้ามเลือก Rich Text หรือ Enhanced Rich Text เพื่อให้ Copilot Studio และ Power Apps ดึงข้อมูลได้สมบูรณ์โดยไม่มี HTML Tags ปะปน

---

## ส่วนที่ 3: ระบบจัดการข้อมูล Master Systems แบบ Dynamic (เพิ่ม/ลด/แก้ไขได้เอง)

เพื่อให้ตัวเลือกระบบงานทั้งหมดในองค์กร (ทั้งบนเอกสารคู่มือ, Q&A, หน้าจอแจ้งเคส, และเมนูแชท AI) สามารถเพิ่ม/ลด/เปลี่ยนชื่อได้แบบ Dynamic โดยไม่ต้องแก้โค้ดหรือโครงสร้างตาราง:

### 3.1 การใช้งาน Master List: `Systems`
บน SharePoint Site `https://dvsins.sharepoint.com/sites/PowerAppPRD` มี List หลักชื่อ **`Systems`** (List ID: `37a7b3db-d9ef-4cf8-b3f7-920f0ee3ee9a`) อยู่แล้ว ซึ่งทำหน้าที่เป็น Single Source of Truth สำหรับรายชื่อระบบ

- **โครงสร้างคอลัมน์ใน `Systems`**:
  - `Title`: ชื่อเต็มระบบ (เช่น `DSS`, `Renewal Motor`, `PCS`, `Polisy 400`, `CMI`, `E-Claim`)
  - `Code`: รหัสย่อระบบ
  - `IsActive`: สถานะเปิด/ปิดการใช้งาน (`Yes`/`No`)
  - `DisplayOrder`: ลำดับที่ต้องการให้แสดงในเมนูตัวเลือก

### 3.2 ขั้นตอนการเพิ่มหรือแก้ไขระบบใหม่ (สำหรับผู้ดูแลระบบ)
1. เข้าไปที่ SharePoint List `Systems`: `https://dvsins.sharepoint.com/sites/PowerAppPRD/Lists/Systems`
2. **การเพิ่มระบบใหม่**: คลิก **+ New** > กรอกชื่อระบบในช่อง `Title` และเลือก `IsActive = Yes` > คลิก **Save**
3. **การแก้ไขชื่อหรือปิดใช้งาน**: คลิก **Edit in grid view** > แก้ไขชื่อ หรือเปลี่ยน `IsActive` เป็น `No` (กรณีระบบถูกยกเลิกการใช้งาน)
4. **ผลลัพธ์ Dynamic และประสิทธิภาพ AI สูงสุด**:
   - ใน Document Library `SystemManuals` และ List `AI_KnowledgeBase`: เก็บชื่อระบบเป็น Text ที่ตรงกับ Master List ทำให้ Generative AI และ Semantic Search สแกนและจับคู่ได้เร็วและแม่นยำที่สุด 100% โดยไม่มีปัญหาเรื่อง OData Lookup Object
   - ใน Power Apps และ SharePoint Modern Form: สามารถผูก Dropdown เข้ากับ List `Systems` ทำให้ผู้ใช้งานคลิกเลือกชื่อระบบได้ทันทีโดยไม่ต้องพิมพ์เอง
   - ใน Copilot Studio: AI สามารถจับคู่ชื่อระบบและคำพ้องความหมาย (Synonyms) จาก Master List ได้อย่างชาญฉลาดและยืดหยุ่น

---

## ส่วนที่ 4: การตั้งค่าสิทธิ์การเข้าถึง (Permissions & Governance)

เพื่อให้ระบบทำงานได้อย่างถูกต้องทั้งการค้นหาของ AI และความปลอดภัยของข้อมูล:

### 4.1 สิทธิ์สำหรับผู้ใช้งานทั่วไป (End Users / ทุกคนในบริษัท)
- **กลุ่มเป้าหมาย**: `Everyone except external users` (หรือกลุ่มพนักงานบริษัท)
- **สิทธิ์ที่ต้องให้**: **Read Only (อ่านอย่างเดียว)**
- **เหตุผล**: เมื่อพนักงานทักถาม HelpMe Agent ระบบจะสืบค้นด้วยสิทธิ์ของผู้ใช้งาน (Invoker Mode) หากผู้ใช้ไม่มีสิทธิ์ Read ใน Library/List นี้ AI จะค้นเนื้อหาไม่พบ

### 4.2 สิทธิ์สำหรับผู้ดูแลองค์ความรู้ (IT Helpdesk / KB Admins)
- **กลุ่มเป้าหมาย**: ทีมงาน IT Helpdesk หรือ Application Support
- **สิทธิ์ที่ต้องให้**: **Edit / Contribute**
- **วิธีใช้งาน**: สามารถอัปโหลดไฟล์คู่มือใหม่ได้ทันที หรือใช้โหมด **Edit in grid view** ของ SharePoint แก้ไขตาราง Q&A เหมือนใช้งาน Microsoft Excel ได้อย่างสะดวก

---

## ส่วนที่ 5: ข้อมูลสำหรับนำไปผูกใน Copilot Studio (IDs & URLs)

เมื่อสร้างเสร็จเรียบร้อยแล้ว ให้คัดลอกข้อมูล 2 ส่วนนี้เตรียมไว้:

1. **Document Library URL (สำหรับ Manuals)**:
   ```text
   https://dvsins.sharepoint.com/sites/PowerAppPRD/SystemManuals
   ```
2. **SharePoint List URL (สำหรับ Q&A)**:
   ```text
   https://dvsins.sharepoint.com/sites/PowerAppPRD/Lists/AI_KnowledgeBase
   ```
   - **List GUID**: `95e5e09d-6d20-4811-8833-820cef88fe98`

*(ปัจจุบันไฟล์คอนฟิกของ Copilot Studio ได้รับการอัปเดตและ Publish ขึ้นระบบจริงเรียบร้อยแล้ว)*

---

## ส่วนที่ 6: การบำรุงรักษาและการสั่ง Force Indexing (Admin Maintenance SOP)

### 6.1 กลไกการอัปเดตดัชนีการค้นหา (Index Sync)
- **Automatic Sync**: โดยปกติระบบ Copilot Studio และ Microsoft Graph Indexer จะทยอยอัปเดตข้อมูลใหม่ภายใน 15-60 นาทีโดยอัตโนมัติ
- **Force Indexing ทันที (กรณีมีคู่มือใหม่หรือคำตอบฉุกเฉิน)**:
  1. เข้าสู่ **Microsoft Copilot Studio Portal**: `https://copilotstudio.microsoft.com`
  2. เปิดเอเจนต์ **`HelpMe Agent`**
  3. ไปที่แท็บ **Knowledge**
  4. เลือกแหล่งข้อมูล `SystemManuals` หรือ `AI_KnowledgeBase` แล้วกด **Edit** จากนั้นกด **Save** หรือกดปุ่มรีเฟรช เพื่อกระตุ้นให้ Indexer ทำการ Re-crawl ทันที

### 6.2 การตรวจสอบคุณภาพเนื้อหาก่อนเผยแพร่
- สำหรับ **SystemManuals**: ตรวจสอบว่าคอลัมน์ `Status` เป็น `Approved` เสมอ (เอกสารสถานะ `Draft` หรือ `Archived` จะไม่ถูกนำไปตอบ)
- สำหรับ **AI_KnowledgeBase**: ตรวจสอบว่า `Status` เป็น `Active` และชื่อในคอลัมน์ `System` สะกดตรงกับชื่อใน Master List `Systems` ทุกตัวอักษร

---

## ส่วนที่ 7: เกณฑ์การทดสอบและผลการตรวจสอบ (Verification & Benchmark Matrix)

| หมวดการทดสอบ | ตัวอย่างคำถามทดสอบ | พฤติกรรมที่คาดหวัง | สถานะผลลัพธ์ |
|-------------|-------------------|-------------------|-------------|
| **Positive Q&A (Renewal Motor)** | "Renewal Motor ลืมรหัสผ่านทำอย่างไร" | ตอบขั้นตอนรีเซ็ตรหัสผ่าน พร้อมแสดง Citation และคำถามแนะนำ 2 ข้อ | ผ่าน (Passed) |
| **Positive Q&A (DSS)** | "DSS พิมพ์ใบเสร็จรับเงินไม่ได้" | ตอบวิธีเคลียร์แคชและตั้งค่าเบราว์เซอร์ พร้อมคำถามแนะนำ 2 ข้อ | ผ่าน (Passed) |
| **Positive Q&A (PCS)** | "PCS เข้าใช้งานไม่ได้ ติดสิทธิ์" | อธิบายขั้นตอนขอสิทธิ์ผ่าน IT Helpdesk Form | ผ่าน (Passed) |
| **In-Dialog UX (Topic v4K)** | เลือกเมนู "สอบถามระบบงาน" | แสดง Quick Replies: Renewal Motor, DSS, PCS, Polisy 400 ทันทีใน 0s | ผ่าน (Passed) |
| **Follow-up Suggestions** | ถามคำถามใดๆ จบ | มีบรรทัด `คำถามที่อาจเกี่ยวข้อง:` และ bullet คำถาม 2 ข้อต่อท้ายเสมอ | ผ่าน (Passed) |
| **Negative Case (Off-topic)** | "ขอสูตรทำอาหารเย็นนี้หน่อย" | ปฏิเสธสุภาพ ระบุว่าตอบได้เฉพาะระบบไอทีองค์กรเท่านั้น (Zero Hallucination) | ผ่าน (Passed) |
| **Negative Case (Fake System)** | "ระบบ Galaxy Super ใช้งานยังไง" | แจ้งว่าไม่พบระบบนี้ในสารบบ และเสนอชื่อระบบที่มีอยู่หรือให้เปิดเคส | ผ่าน (Passed) |

