# คู่มือการตั้งค่าคอลัมน์และ Index บน SharePoint List: Cases
## สำหรับระบบ Monitor_case_Helpdesk (IT Helpdesk Case Monitor)

เอกสารฉบับนี้จัดทำขึ้นเพื่อให้ผู้ดูแลระบบ (SharePoint / M365 Administrator) ดำเนินการปรับแต่ง **SharePoint List `Cases`** เพื่อรองรับ:
1. การบันทึกสรุปและหลักฐานประกอบการปิดเคส (Resolution Evidence)
2. การค้นหาและกรองข้อมูลปริมาณมากโดยไม่ติดขีดจำกัด Delegation (Server-Side Query Delegation เกิน 2,000 ถึง 50,000+ แถว)
3. การเตรียมความพร้อมของโครงสร้างข้อมูลสำหรับการวิเคราะห์เชิงสถิติ (Power BI / Root Cause Analytics)

---

### ข้อมูลเบื้องต้นของระบบ
- **SharePoint Site**: `https://devesinsurance.sharepoint.com/sites/PowerAppPRD`
- **Target List**: `Cases` (List ID: `b8b22b0d-45c6-43c9-bc66-06e5e45b1237`)
- **Lookup List**: `Systems` (List ID: `37a7b3db-d9ef-4cf8-b3f7-920f0ee3ee9a`)

---

## ส่วนที่ 1: การเพิ่มคอลัมน์ใหม่ 2 คอลัมน์ (New Columns)

ให้เข้าไปที่ SharePoint List `Cases` > คลิกไอคอน **ฟันเฟือง (Settings)** ขวาบน > เลือก **List settings** > เลื่อนลงไปที่ส่วน **Columns** แล้วคลิก **Create column** ตามรายละเอียดด้านล่าง:

### 1. คอลัมน์: ResolutionSummary
คอลัมน์สำหรับให้เจ้าหน้าที่ไอทีบันทึกสรุปรายละเอียดการแก้ไขปัญหาจริงที่ได้ดำเนินการไป

| การตั้งค่า (Setting) | ค่าที่ต้องกำหนด (Value) |
|----------------------|-------------------------|
| **Column name** | `ResolutionSummary` |
| **The type of information** | **Multiple lines of text** |
| **Require that this column contains information** | No (เนื่องจากตอนเปิดเคสจะยังไม่มีข้อมูลนี้ จะบังคับกรอกผ่าน Power Apps ตอนปิดเคส) |
| **Number of lines for editing** | `6` |
| **Type of text to allow** | **Plain text** (ห้ามเลือก Rich text หรือ Enhanced rich text เพื่อรองรับการค้นหาและ Delegation) |
| **Append Changes to Existing Text** | No |

---

### 2. คอลัมน์: ResolutionCategory
คอลัมน์ตัวเลือกสำหรับจัดหมวดหมู่วิธีการแก้ไขปัญหา ช่วยให้สามารถทำรายงาน Pareto Analysis วิเคราะห์สาเหตุหลักของปัญหาไอทีได้ในอนาคต

| การตั้งค่า (Setting) | ค่าที่ต้องกำหนด (Value) |
|----------------------|-------------------------|
| **Column name** | `ResolutionCategory` |
| **The type of information** | **Choice** (menu to choose from) |
| **Require that this column contains information** | No |
| **Type each choice on a separate line** | พิมพ์ตัวเลือกดังต่อไปนี้ บรรทัดละ 1 ข้อ:<br>`แก้ไขข้อมูล`<br>`ปรับแต่งสิทธิ์`<br>`แก้ไขบั๊กโปรแกรม`<br>`สอนการใช้งาน`<br>`ประสานงานภายนอก`<br>`อื่นๆ` |
| **Display choices using** | **Drop-Down Menu** |
| **Allow 'Fill-in' choices** | No |
| **Default value** | *(ลบออกให้ว่างไว้ ไม่ต้องมีค่าเริ่มต้น)* |

---

## ส่วนที่ 2: การตรวจสอบการเปิดใช้งานระบบไฟล์แนบ (Attachments)

1. ในหน้า **List settings** > คลิกที่หัวข้อ **Advanced settings** (ใต้ General Settings)
2. เลื่อนไปที่หัวข้อ **Attachments**
3. ตรวจสอบว่าเลือกเป็น **Enabled**
4. คลิก **OK** ด้านล่างสุด

> [!NOTE]
> ระบบ Power Apps Canvas App ได้ผูกการทำงานเข้ากับ Native Attachments ของ SharePoint เรียบร้อยแล้ว เมื่อเจ้าหน้าที่แนบไฟล์รูปภาพหรือเอกสาร (PNG, JPG, PDF, XLSX) ผ่านระบบ ไฟล์จะถูกส่งเข้ามาผูกกับรายการเคสนั้นๆ โดยอัตโนมัติ

---

## ส่วนที่ 3: การสร้าง 6 Indexed Columns เพื่อรองรับ Delegation ปริมาณมาก (สำคัญมาก)

SharePoint Online มีข้อจำกัด List View Threshold อยู่ที่ 5,000 รายการ และ Power Apps มีเพดาน Delegation อยู่ที่ 2,000 แถว หากไม่ได้ทำ Index ไว้ เมื่อข้อมูลในตาราง `Cases` มีปริมาณมาก การค้นหาหรือกรองข้อมูลจะไม่สามารถดึงข้อมูลจริงจากเซิร์ฟเวอร์ได้

### วิธีการสร้าง Index
1. ในหน้า **List settings** เลื่อนลงไปที่ส่วน **Columns**
2. คลิกที่ลิงก์ **Indexed columns** (อยู่ใต้รายการคอลัมน์)
3. คลิก **Create a new index**
4. ทำการเลือก **Primary column for this index** และกด **Create** ทีละคอลัมน์จนครบทั้ง 6 คอลัมน์ ดังนี้:

| # | ชื่อคอลัมน์ (Column Name) | วัตถุประสงค์ในระบบ Power Apps |
|---|---------------------------|------------------------------|
| **1** | **`Statuscase`** | กรองสถานะเคส (ทั้งหมด / รอรับเรื่อง / กำลังดำเนินการ / ปิดงานแล้ว) |
| **2** | **`CaseID`** | ค้นหารหัสเคสแบบขึ้นต้นคำด้วย `StartsWith()` |
| **3** | **`SystemName`** | กรองตามระบบงานใน Dropdown ComboBox |
| **4** | **`AssignedOwner`** | กรองงานตามเจ้าหน้าที่ผู้รับผิดชอบเคส |
| **5** | **`Created`** | เรียงลำดับเคสล่าสุดจากเซิร์ฟเวอร์แบบ `Descending` (Delegable 100%) |
| **6** | **`ReporterName`** | ค้นหาเคสตามชื่อผู้ทำรายการ/ผู้แจ้งปัญหาในกล่องค้นหาแบบ `StartsWith()` |

---

## ส่วนที่ 4: สคริปต์ตรวจสอบและสร้างคอลัมน์อัตโนมัติ (สำหรับ M365 / SharePoint Admin)

หากผู้ดูแลระบบต้องการใช้ **PnP PowerShell** เพื่อเพิ่มคอลัมน์และสร้าง Index แบบอัตโนมัติ สามารถใช้สคริปต์ด้านล่างนี้ได้:

```powershell
# ติดตั้งโมดูล PnP.PowerShell (หากยังไม่มี)
# Install-Module -Name PnP.PowerShell -Scope CurrentUser

# 1. เชื่อมต่อสู่ SharePoint Site
$SiteUrl = "https://devesinsurance.sharepoint.com/sites/PowerAppPRD"
Connect-PnPOnline -Url $SiteUrl -Interactive

$ListName = "Cases"

# 2. เพิ่มคอลัมน์ ResolutionSummary
Add-PnPField -List $ListName -DisplayName "ResolutionSummary" -InternalName "ResolutionSummary" -Type Note -AddToDefaultView
Set-PnPField -List $ListName -Identity "ResolutionSummary" -Values @{NumberOfLines=6; RichText=$false}

# 3. เพิ่มคอลัมน์ ResolutionCategory
$Choices = @("แก้ไขข้อมูล", "ปรับแต่งสิทธิ์", "แก้ไขบั๊กโปรแกรม", "สอนการใช้งาน", "ประสานงานภายนอก", "อื่นๆ")
Add-PnPField -List $ListName -DisplayName "ResolutionCategory" -InternalName "ResolutionCategory" -Type Choice -Choices $Choices -AddToDefaultView

# 4. สร้าง Indexed Columns ทั้ง 6 คอลัมน์
$IndexColumns = @("Statuscase", "CaseID", "SystemName", "AssignedOwner", "Created", "ReporterName")
foreach ($col in $IndexColumns) {
    Write-Host "Creating index for column: $col ..."
    Add-PnPIndexedColumn -List $ListName -Field $col
}

Write-Host "การตั้งค่าโครงสร้าง SharePoint List Cases เสร็จสมบูรณ์พร้อมใช้งาน 100%" -ForegroundColor Green
```

---

## ส่วนที่ 5: การนำเข้าและอัปเดต Power Apps Canvas App

หลังจากสร้างคอลัมน์และ Index เรียบร้อยแล้ว:
1. ไฟล์ไบนารีที่ปรับปรุงเสร็จแล้วอยู่ที่: [`Monitor_case_Helpdesk.msapp`](file:///e:/DVS/Project/Aiagent_Helpme/Monitor_case_Helpdesk.msapp)
2. เข้าสู่ **Power Apps Maker Portal** (`https://make.powerapps.com`)
3. เลือกสภาพแวดล้อม **Deves Insurance Default**
4. ไปที่ **Apps** > เลือกเปิดแก้ไข (Edit) แอปพลิเคชัน **`Monitor_case_Helpdesk`**
5. ที่เมนู **File** > เลือก **Open** > **Browse** > เลือกไฟล์ `Monitor_case_Helpdesk.msapp`
6. ตรวจสอบใน Data panel ให้กด **Refresh** บน Data Source `Cases` เพื่อให้ Power Apps ดึง Schema คอลัมน์ใหม่เข้ามา
7. กด **Save** และ **Publish** เพื่อให้เจ้าหน้าที่ Helpdesk ใช้งานเวอร์ชันล่าสุดได้ทันที
