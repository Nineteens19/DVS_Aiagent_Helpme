# Implementation Specification — Monitor_case_Helpdesk

## Code Organization & Project Layout

**Technology Stack**: Microsoft Power Apps Canvas App (YAML Source Code Format)  
**Packaging Tool**: Power Platform CLI (`pac canvas`)  
**Repository Pattern**: Componentized Canvas Screen within Local Git Workspace

```
Monitor_case_Helpdesk/
  ├── CanvasManifest.json              # เมตาดาต้าและเวอร์ชันของ Canvas App
  ├── Properties.json                  # การตั้งค่าแอปและ App Display Settings
  ├── References/
  │     ├── DataSources.json           # การเชื่อมต่อ SharePoint Lists (Cases, Systems)
  │     └── Resources.json             # ทรัพยากรไฟล์ภาพและ Media
  └── Src/
        ├── App.pa.yaml                # OnStart logic, ธีมสีทางการ และตัวแปรระบบ
        ├── Home_incident.pa.yaml      # หน้าจอหลัก Single-Screen Master-Detail (4 Tiers + Drawer)
        └── updateincident.pa.yaml     # หน้าจอเดิมที่ปรับแต่งเป็น Modern Style (Fallback compatibility)
```

---

## Control Hierarchy & Naming Conventions

เพื่อให้โค้ด YAML อ่านง่ายและบำรุงรักษาสะดวก ได้กำหนดโครงสร้างชื่อคอนโทรลตามมาตรฐาน Enterprise Canvas App Naming Standards:

```
Home_incident (Screen)
  └── con_Root (Vertical Auto-Layout Container, 100% W x 100% H, Fill: #F8F9FA)
        ├── con_Header (Tier 1: 56px H, Fill: #012169)
        │     ├── lbl_HeaderTitle ("ระบบบริหารจัดการเคสไอที")
        │     ├── lbl_HeaderSubtitle ("IT Helpdesk Monitoring")
        │     ├── btn_ManualRefresh (Icon / Button)
        │     └── con_UserProfile
        ├── con_KpiBar (Tier 2: 84px H, Horizontal Layout)
        │     ├── con_KpiCard_Total
        │     ├── con_KpiCard_Open
        │     ├── con_KpiCard_InProgress
        │     ├── con_KpiCard_Resolved
        │     └── con_KpiCard_SlaBreach
        ├── con_ControlBar (Tier 3: 52px H, Horizontal Layout, Fill: #FFFFFF)
        │     ├── con_StatusTabs (All, Open, In Progress, Resolved)
        │     ├── cmb_SystemFilter (Dropdown)
        │     ├── txt_Search (Search TextInput)
        │     └── btn_ClearFilters (Button)
        └── con_Workspace (Tier 4: Fill Remaining Height, Horizontal Layout)
              ├── con_LeftPane (Flexible Width: If(varShowDrawer, Parent.Width - 480, Parent.Width))
              │     ├── con_GridHeader (TableHeader with Column Titles)
              │     └── gal_Cases (Dense Table Gallery, Row Height: 44px)
              │           ├── lbl_RowCaseID
              │           ├── lbl_RowSystem
              │           ├── lbl_RowTitle
              │           ├── lbl_RowOwner
              │           ├── lbl_RowCreated
              │           ├── con_StatusPill (Semantic Badge)
              │           │     └── lbl_RowStatus
              │           └── btn_RowAction ("ดูรายละเอียด / ปิดเคส")
              └── con_SideDrawer (Tier 4 Right: Width: 480px, Visible: varShowDrawer, Fill: #FFFFFF)
                    ├── con_DrawerHeader (Title + btn_CloseDrawer)
                    ├── con_CaseSummaryCard (Read-only quick case context)
                    └── frm_CaseResolution (EditForm bound to Cases)
                          ├── DataCard_ResolutionCategory (Choice Dropdown)
                          ├── DataCard_ResolutionSummary (Multi-line TextInput, 6 lines)
                          ├── DataCard_Attachments (Native SharePoint Attachments Control)
                          └── con_DrawerActions
                                ├── btn_SubmitResolution ("ยืนยันการปิดเคส")
                                └── btn_CancelResolution ("ยกเลิก")
```

---

## Key Power Fx Implementation Formulas

### 1. App.OnStart (การกำหนดค่าเริ่มต้นระบบและตัวแปรส่วนกลาง)
```powerfx
// กำหนดสถานะเริ่มต้น
Set(varSelectedStatus, "All");
Set(varShowDrawer, false);
Set(varSelectedCase, Blank());
Set(varLastRefreshedTime, Now());

// กำหนด Color Tokens ทางการ (Deves Corporate Fluent)
Set(gblColorPrimary, ColorValue("#012169"));
Set(gblColorBg, ColorValue("#F8F9FA"));
Set(gblColorSurface, ColorValue("#FFFFFF"));
Set(gblColorBorder, ColorValue("#E2E8F0"));
Set(gblColorTextPrimary, ColorValue("#0F172A"));
Set(gblColorTextSecondary, ColorValue("#64748B"));

// Status Badge Tokens
Set(gblColorOpenBg, ColorValue("#F1F5F9"));
Set(gblColorOpenText, ColorValue("#475569"));
Set(gblColorInProgBg, ColorValue("#FEF3C7"));
Set(gblColorInProgText, ColorValue("#B45309"));
Set(gblColorResolvedBg, ColorValue("#D1FAE5"));
Set(gblColorResolvedText, ColorValue("#047857"));
Set(gblColorSlaBreachBg, ColorValue("#FFE4E6"));
Set(gblColorSlaBreachText, ColorValue("#BE123C"));
```

### 2. gal_Cases.Items (สูตร Server-Side Delegable Filter 100%)
```powerfx
SortByColumns(
    Filter(
        Cases,
        (varSelectedStatus = "All" || Statuscase.Value = varSelectedStatus) &&
        (IsBlank(cmb_SystemFilter.Selected.Value) || SystemName = cmb_SystemFilter.Selected.Value) &&
        (IsBlank(txt_Search.Text) || StartsWith(CaseID, txt_Search.Text) || StartsWith(Title, txt_Search.Text))
    ),
    "Created",
    SortOrder.Descending
)
```

### 3. Selection & Drawer Opening (แถวใน Gallery)
```powerfx
// OnSelect ของปุ่ม btn_RowAction หรือตัวแถว gal_Cases
Set(varSelectedCase, ThisItem);
Set(varShowDrawer, true);
EditForm(frm_CaseResolution);
```

### 4. Close Drawer & Clear State
```powerfx
// OnSelect ของปุ่ม btn_CloseDrawer หรือ btn_CancelResolution
ResetForm(frm_CaseResolution);
Set(varShowDrawer, false);
Set(varSelectedCase, Blank());
```

### 5. Resolution Submit & Validation (ปุ่ม btn_SubmitResolution)
```powerfx
// DisplayMode ของปุ่ม btn_SubmitResolution:
If(
    !IsBlank(DataCardValue_ResolutionCategory.Selected.Value) &&
    Len(Trim(DataCardValue_ResolutionSummary.Text)) >= 10 &&
    CountRows(DataCardValue_Attachments.Attachments) > 0,
    DisplayMode.Edit,
    DisplayMode.Disabled
)

// OnSelect ของปุ่ม btn_SubmitResolution:
SubmitForm(frm_CaseResolution);

// OnSuccess ของฟอร์ม frm_CaseResolution:
Notify("บันทึกการปิดเคส " & varSelectedCase.CaseID & " สำเร็จเรียบร้อยแล้ว", NotificationType.Success);
Set(varShowDrawer, false);
Set(varSelectedCase, Blank());
Refresh(Cases);

// OnFailure ของฟอร์ม frm_CaseResolution:
Notify("เกิดข้อผิดพลาดในการบันทึกข้อมูล: " & frm_CaseResolution.ErrorMessage, NotificationType.Error);
```

---

## Build, Packaging & Deployment Lifecycle

การทำงานปรับแต่งซอร์สโค้ดและรวมแพ็กเกจดำเนินการผ่าน Command-Line:

1. **Unpack (แตกไฟล์ซอร์สโค้ด)**:
   ```powershell
   pac canvas unpack --msapp Monitor_case_Helpdesk.msapp --sources Monitor_case_Helpdesk --layout SourceCode
   ```
   > **สำคัญ**: ต้องระบุ `--layout SourceCode` เสมอ ถ้าไม่ระบุ CLI จะ fallback ไปใช้ layout `Experimental` (deprecated) ซึ่ง JSON parser ของมันไม่รองรับ UTF-8 BOM ที่ `pac canvas pack` แทรกไว้ในไฟล์ `Controls/*.json`, `References/DataSources.json`, `Properties.json` เสมอ ทำให้เกิด error `System.Text.Json.JsonReaderException: '0xEF' is an invalid start of a value` และ CLI ค้าง/ปิดตัวแบบ non-recoverable
2. **Pack (รวมซอร์สโค้ดกลับเป็นไบนารี .msapp)**:
   ```powershell
   pac canvas pack --sources Monitor_case_Helpdesk --msapp Monitor_case_Helpdesk.msapp --layout SourceCode --overwrite
   ```
3. **Integrity Validation**:
   - ตรวจสอบว่า `pac canvas pack` สำเร็จโดยไม่มีคำเตือนข้อผิดพลาดทางไวยากรณ์ (Syntax Errors)
   - ทำการ unpack ซ้ำไปยังโฟลเดอร์ชั่วคราวเพื่อตรวจสอบความสมบูรณ์ของโครงสร้าง
