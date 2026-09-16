# DRAFT: CreateCaseAndAck flow

ฉบับร่างของ flow `CreateCaseAndAck` (rebuild จาก `NewcaseHelpDesk` — ตัด nested For_each, named inputs, ack ถึงผู้แจ้ง, error handling → ErrorLog)

## วิธีใช้
1. หลัง provision SharePoint lists แล้ว เติม placeholder เหล่านี้ให้ครบ:
   - `@@CASES_LIST_GUID@@` — GUID ของ list `Cases`
   - `@@SLACONFIG_LIST_GUID@@` — GUID ของ list `SLAConfig`
   - `@@KNOWLEDGEGAPS_LIST_GUID@@` — GUID ของ list `KnowledgeGaps`
   - `@@ERRORLOG_LIST_GUID@@` — GUID ของ list `ErrorLog`
   - `@@ADMIN_EMAIL@@` — อีเมล admin สำหรับแจ้ง error
   - (Routing GUID `3d5264cb-...` และ site URL ใส่ค่าจริงไว้แล้ว)
   > หา GUID ของ list: `m365 spo list get --webUrl "https://dvsins.sharepoint.com/sites/PowerAppPRD" --title "Cases"` (ดูค่า `Id`)
2. คัดลอกบล็อก JSON ด้านล่างไปไว้ที่ `HelpMe Agent/workflows/CreateCaseAndAck/workflow.json`
3. สร้าง `metadata.yml` (เนื้อหาอยู่ท้ายไฟล์นี้) โดยใส่ `workflowId` เป็น GUID ใหม่ (สร้างด้วย `[guid]::NewGuid()`)
4. `pac copilot push` แล้วทดสอบใน UAT

## workflow.json
```json
{
  "properties": {
    "connectionReferences": {
      "shared_sharepointonline": {
        "api": { "name": "shared_sharepointonline" },
        "connection": { "connectionReferenceLogicalName": "cr616_helpMeAgentUat.cr.KjQFMKAz" },
        "runtimeSource": "invoker"
      },
      "shared_office365": {
        "api": { "name": "shared_office365" },
        "connection": { "connectionReferenceLogicalName": "new_sharedoffice365_71ca1" },
        "runtimeSource": "invoker"
      }
    },
    "definition": {
      "$schema": "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#",
      "contentVersion": "1.0.0.0",
      "parameters": {
        "$authentication": { "defaultValue": {}, "type": "SecureObject" },
        "$connections": { "defaultValue": {}, "type": "Object" }
      },
      "triggers": {
        "manual": {
          "type": "Request",
          "kind": "Skills",
          "inputs": {
            "schema": {
              "type": "object",
              "properties": {
                "contactEmail": { "title": "contactEmail", "type": "string", "x-ms-content-hint": "TEXT", "x-ms-dynamically-added": true },
                "contactName": { "title": "contactName", "type": "string", "x-ms-content-hint": "TEXT", "x-ms-dynamically-added": true },
                "contactTel": { "title": "contactTel", "type": "string", "x-ms-content-hint": "TEXT", "x-ms-dynamically-added": true },
                "systemName": { "title": "systemName", "type": "string", "x-ms-content-hint": "TEXT", "x-ms-dynamically-added": true },
                "caseType": { "title": "caseType", "type": "string", "x-ms-content-hint": "TEXT", "x-ms-dynamically-added": true },
                "priority": { "title": "priority", "type": "string", "x-ms-content-hint": "TEXT", "x-ms-dynamically-added": true },
                "severity": { "title": "severity", "type": "string", "x-ms-content-hint": "TEXT", "x-ms-dynamically-added": true },
                "issueDetail": { "title": "issueDetail", "type": "string", "x-ms-content-hint": "TEXT", "x-ms-dynamically-added": true },
                "issueSummary": { "title": "issueSummary", "type": "string", "x-ms-content-hint": "TEXT", "x-ms-dynamically-added": true },
                "kbRef": { "title": "kbRef", "type": "string", "x-ms-content-hint": "TEXT", "x-ms-dynamically-added": true },
                "username": { "title": "username", "type": "string", "x-ms-content-hint": "TEXT", "x-ms-dynamically-added": true }
              },
              "required": ["contactEmail", "contactName", "systemName", "caseType", "issueDetail"]
            }
          }
        }
      },
      "actions": {
        "Init_CaseID": { "type": "InitializeVariable", "inputs": { "variables": [ { "name": "CaseID", "type": "string" } ] }, "runAfter": {} },
        "Init_MailTo": { "type": "InitializeVariable", "inputs": { "variables": [ { "name": "MailTo", "type": "string" } ] }, "runAfter": { "Init_CaseID": [ "Succeeded" ] } },
        "Init_MailCC": { "type": "InitializeVariable", "inputs": { "variables": [ { "name": "MailCC", "type": "string" } ] }, "runAfter": { "Init_MailTo": [ "Succeeded" ] } },
        "Scope_Main": {
          "type": "Scope",
          "runAfter": { "Init_MailCC": [ "Succeeded" ] },
          "actions": {
            "Create_item_Cases": {
              "type": "OpenApiConnection",
              "inputs": {
                "parameters": {
                  "dataset": "https://dvsins.sharepoint.com/sites/PowerAppPRD",
                  "table": "@@CASES_LIST_GUID@@",
                  "item/CaseType/Value": "@triggerBody()?['caseType']",
                  "item/SystemName": "@triggerBody()?['systemName']",
                  "item/Priority/Value": "@triggerBody()?['priority']",
                  "item/Severity/Value": "@triggerBody()?['severity']",
                  "item/ProblemDetail": "@triggerBody()?['issueDetail']",
                  "item/IssueSummary": "@triggerBody()?['issueSummary']",
                  "item/KBRef": "@triggerBody()?['kbRef']",
                  "item/Username": "@triggerBody()?['username']",
                  "item/ReporterName": "@triggerBody()?['contactName']",
                  "item/ReporterEmail": "@triggerBody()?['contactEmail']",
                  "item/ReporterTel": "@triggerBody()?['contactTel']",
                  "item/Statuscase/Value": "Open"
                },
                "host": { "apiId": "/providers/Microsoft.PowerApps/apis/shared_sharepointonline", "operationId": "PostItem", "connectionName": "shared_sharepointonline" }
              }
            },
            "Set_CaseID": {
              "type": "SetVariable",
              "inputs": { "name": "CaseID", "value": "@concat('HD-', formatDateTime(utcNow(),'yyyyMMdd'), '-', string(outputs('Create_item_Cases')?['body/ID']))" },
              "runAfter": { "Create_item_Cases": [ "Succeeded" ] }
            },
            "Update_item_CaseID": {
              "type": "OpenApiConnection",
              "inputs": {
                "parameters": {
                  "dataset": "https://dvsins.sharepoint.com/sites/PowerAppPRD",
                  "table": "@@CASES_LIST_GUID@@",
                  "id": "@outputs('Create_item_Cases')?['body/ID']",
                  "item/CaseID": "@variables('CaseID')"
                },
                "host": { "apiId": "/providers/Microsoft.PowerApps/apis/shared_sharepointonline", "operationId": "PatchItem", "connectionName": "shared_sharepointonline" }
              },
              "runAfter": { "Set_CaseID": [ "Succeeded" ] }
            },
            "Get_Routing_bySystem": {
              "type": "OpenApiConnection",
              "inputs": {
                "parameters": {
                  "dataset": "https://dvsins.sharepoint.com/sites/PowerAppPRD",
                  "table": "3d5264cb-65f6-4db5-8afa-fa68a6ea61e1",
                  "$filter": "SystemName eq '@{triggerBody()?['systemName']}'",
                  "$top": 1
                },
                "host": { "apiId": "/providers/Microsoft.PowerApps/apis/shared_sharepointonline", "operationId": "GetItems", "connectionName": "shared_sharepointonline" }
              },
              "runAfter": { "Update_item_CaseID": [ "Succeeded" ] }
            },
            "Condition_Routing_found": {
              "type": "If",
              "expression": { "greater": [ "@length(outputs('Get_Routing_bySystem')?['body/value'])", 0 ] },
              "runAfter": { "Get_Routing_bySystem": [ "Succeeded" ] },
              "actions": {
                "Set_MailTo_fromSystem": { "type": "SetVariable", "inputs": { "name": "MailTo", "value": "@concat(coalesce(first(outputs('Get_Routing_bySystem')?['body/value'])?['ToNotifyBA'],''), ';', coalesce(first(outputs('Get_Routing_bySystem')?['body/value'])?['ToNotifySA'],''))" } },
                "Set_MailCC_fromSystem": { "type": "SetVariable", "inputs": { "name": "MailCC", "value": "@coalesce(first(outputs('Get_Routing_bySystem')?['body/value'])?['CCNotify'],'')" }, "runAfter": { "Set_MailTo_fromSystem": [ "Succeeded" ] } }
              },
              "else": {
                "actions": {
                  "Get_Routing_Helpdesk": {
                    "type": "OpenApiConnection",
                    "inputs": {
                      "parameters": {
                        "dataset": "https://dvsins.sharepoint.com/sites/PowerAppPRD",
                        "table": "3d5264cb-65f6-4db5-8afa-fa68a6ea61e1",
                        "$filter": "SystemName eq 'Helpdesk'",
                        "$top": 1
                      },
                      "host": { "apiId": "/providers/Microsoft.PowerApps/apis/shared_sharepointonline", "operationId": "GetItems", "connectionName": "shared_sharepointonline" }
                    }
                  },
                  "Set_MailTo_Helpdesk": { "type": "SetVariable", "inputs": { "name": "MailTo", "value": "@concat(coalesce(first(outputs('Get_Routing_Helpdesk')?['body/value'])?['ToNotifyBA'],''), ';', coalesce(first(outputs('Get_Routing_Helpdesk')?['body/value'])?['ToNotifySA'],''))" }, "runAfter": { "Get_Routing_Helpdesk": [ "Succeeded" ] } },
                  "Set_MailCC_Helpdesk": { "type": "SetVariable", "inputs": { "name": "MailCC", "value": "@coalesce(first(outputs('Get_Routing_Helpdesk')?['body/value'])?['CCNotify'],'')" }, "runAfter": { "Set_MailTo_Helpdesk": [ "Succeeded" ] } }
                }
              }
            },
            "Get_SLA_bySeverity": {
              "type": "OpenApiConnection",
              "inputs": {
                "parameters": {
                  "dataset": "https://dvsins.sharepoint.com/sites/PowerAppPRD",
                  "table": "@@SLACONFIG_LIST_GUID@@",
                  "$filter": "Severity eq '@{triggerBody()?['severity']}'",
                  "$top": 1
                },
                "host": { "apiId": "/providers/Microsoft.PowerApps/apis/shared_sharepointonline", "operationId": "GetItems", "connectionName": "shared_sharepointonline" }
              },
              "runAfter": { "Condition_Routing_found": [ "Succeeded" ] }
            },
            "Update_item_SLA": {
              "type": "OpenApiConnection",
              "inputs": {
                "parameters": {
                  "dataset": "https://dvsins.sharepoint.com/sites/PowerAppPRD",
                  "table": "@@CASES_LIST_GUID@@",
                  "id": "@outputs('Create_item_Cases')?['body/ID']",
                  "item/AssignedOwner": "@variables('MailTo')",
                  "item/SlaDueDate": "@if(greater(length(outputs('Get_SLA_bySeverity')?['body/value']),0), addHours(utcNow(), int(coalesce(first(outputs('Get_SLA_bySeverity')?['body/value'])?['ResolutionHours'],'48'))), addHours(utcNow(),48))"
                },
                "host": { "apiId": "/providers/Microsoft.PowerApps/apis/shared_sharepointonline", "operationId": "PatchItem", "connectionName": "shared_sharepointonline" }
              },
              "runAfter": { "Get_SLA_bySeverity": [ "Succeeded" ] }
            },
            "Send_email_team": {
              "type": "OpenApiConnection",
              "inputs": {
                "parameters": {
                  "emailMessage/To": "@variables('MailTo')",
                  "emailMessage/Cc": "@variables('MailCC')",
                  "emailMessage/Subject": "[AI Helpdesk] เคสใหม่ @{variables('CaseID')} - @{triggerBody()?['systemName']}",
                  "emailMessage/Body": "<p>เรียนเจ้าหน้าที่</p><p>CaseID: @{variables('CaseID')}<br>ระบบ: @{triggerBody()?['systemName']}<br>ประเภท: @{triggerBody()?['caseType']}<br>เร่งด่วน: @{triggerBody()?['priority']} (@{triggerBody()?['severity']})</p><p>สรุป: @{triggerBody()?['issueSummary']}</p><p>รายละเอียด: @{triggerBody()?['issueDetail']}</p><p>ผู้แจ้ง: @{triggerBody()?['contactName']} - @{triggerBody()?['contactTel']} - @{triggerBody()?['contactEmail']}</p><p>KB: @{triggerBody()?['kbRef']}</p><hr>ระบบ AI Helpdesk",
                  "emailMessage/Importance": "Normal"
                },
                "host": { "apiId": "/providers/Microsoft.PowerApps/apis/shared_office365", "operationId": "SendEmailV2", "connectionName": "shared_office365" }
              },
              "runAfter": { "Update_item_SLA": [ "Succeeded" ] }
            },
            "Send_email_ack_reporter": {
              "type": "OpenApiConnection",
              "inputs": {
                "parameters": {
                  "emailMessage/To": "@triggerBody()?['contactEmail']",
                  "emailMessage/Subject": "[AI Helpdesk] รับเรื่องแล้ว @{variables('CaseID')}",
                  "emailMessage/Body": "<p>เรียน @{triggerBody()?['contactName']}</p><p>ระบบได้รับเรื่องของท่านแล้ว และส่งต่อให้เจ้าหน้าที่ดูแล</p><p>หมายเลขเคส (CaseID): @{variables('CaseID')}<br>ระบบ: @{triggerBody()?['systemName']}<br>เรื่อง: @{triggerBody()?['issueSummary']}</p><p>พิมพ์หมายเลขเคสนี้กับ AI Helpdesk เพื่อติดตามสถานะได้ และจะได้รับอีเมลแจ้งเมื่อสถานะเปลี่ยน</p><hr>ระบบ AI Helpdesk",
                  "emailMessage/Importance": "Normal"
                },
                "host": { "apiId": "/providers/Microsoft.PowerApps/apis/shared_office365", "operationId": "SendEmailV2", "connectionName": "shared_office365" }
              },
              "runAfter": { "Send_email_team": [ "Succeeded" ] }
            },
            "Condition_write_gap": {
              "type": "If",
              "expression": { "equals": [ "@toLower(coalesce(triggerBody()?['kbRef'],''))", "" ] },
              "runAfter": { "Send_email_ack_reporter": [ "Succeeded" ] },
              "actions": {
                "Create_item_Gap": {
                  "type": "OpenApiConnection",
                  "inputs": {
                    "parameters": {
                      "dataset": "https://dvsins.sharepoint.com/sites/PowerAppPRD",
                      "table": "@@KNOWLEDGEGAPS_LIST_GUID@@",
                      "item/Title": "@triggerBody()?['systemName']",
                      "item/UserQuestion": "@triggerBody()?['issueDetail']",
                      "item/SystemGuess": "@triggerBody()?['systemName']",
                      "item/RelatedCaseID": "@variables('CaseID')",
                      "item/GapStatus/Value": "New"
                    },
                    "host": { "apiId": "/providers/Microsoft.PowerApps/apis/shared_sharepointonline", "operationId": "PostItem", "connectionName": "shared_sharepointonline" }
                  }
                }
              },
              "else": { "actions": {} }
            }
          }
        },
        "Scope_Catch": {
          "type": "Scope",
          "runAfter": { "Scope_Main": [ "Failed", "TimedOut" ] },
          "actions": {
            "Create_item_ErrorLog": {
              "type": "OpenApiConnection",
              "inputs": {
                "parameters": {
                  "dataset": "https://dvsins.sharepoint.com/sites/PowerAppPRD",
                  "table": "@@ERRORLOG_LIST_GUID@@",
                  "item/Title": "CreateCaseAndAck failed",
                  "item/FlowName": "CreateCaseAndAck",
                  "item/ErrorCode/Value": "CASE_001",
                  "item/ErrorMessage": "@{result('Scope_Main')}",
                  "item/ContextData": "system=@{triggerBody()?['systemName']}; reporter=@{triggerBody()?['contactEmail']}",
                  "item/Notified": true
                },
                "host": { "apiId": "/providers/Microsoft.PowerApps/apis/shared_sharepointonline", "operationId": "PostItem", "connectionName": "shared_sharepointonline" }
              }
            },
            "Send_admin_email": {
              "type": "OpenApiConnection",
              "inputs": {
                "parameters": {
                  "emailMessage/To": "@@ADMIN_EMAIL@@",
                  "emailMessage/Subject": "[AI Helpdesk] Flow error - CreateCaseAndAck",
                  "emailMessage/Body": "<p>CreateCaseAndAck ล้มเหลว</p><p>ระบบ: @{triggerBody()?['systemName']}</p><p>ผู้แจ้ง: @{triggerBody()?['contactEmail']}</p><p>โปรดตรวจสอบ ErrorLog</p>",
                  "emailMessage/Importance": "High"
                },
                "host": { "apiId": "/providers/Microsoft.PowerApps/apis/shared_office365", "operationId": "SendEmailV2", "connectionName": "shared_office365" }
              },
              "runAfter": { "Create_item_ErrorLog": [ "Succeeded" ] }
            }
          }
        },
        "Response": {
          "type": "Response",
          "kind": "Skills",
          "runAfter": { "Scope_Main": [ "Succeeded" ], "Scope_Catch": [ "Succeeded", "Skipped" ] },
          "inputs": {
            "statusCode": 200,
            "body": { "caseId": "@variables('CaseID')", "status": "@if(equals(variables('CaseID'),''),'error','created')" },
            "schema": {
              "type": "object",
              "properties": {
                "caseId": { "title": "caseId", "type": "string", "x-ms-content-hint": "TEXT" },
                "status": { "title": "status", "type": "string", "x-ms-content-hint": "TEXT" }
              }
            }
          }
        }
      },
      "outputs": {},
      "description": "helpdesk-agent CreateCaseAndAck"
    }
  },
  "schemaVersion": "1.0.0.0"
}
```

## metadata.yml
```yaml
jsonFileName: workflows/CreateCaseAndAck/workflow.json
workflowId: REPLACE_WITH_NEW_GUID
name: CreateCaseAndAck
type: 1
description: helpdesk-agent - create case + acknowledgment + team notify + error handling
subprocess: false
category: 5
mode: 0
scope: 4
onDemand: false
triggerOnCreate: false
triggerOnDelete: false
asyncAutodelete: false
syncWorkflowLogOnFailure: false
stateCode: 1
statusCode: 2
runAs: 1
isTransacted: true
introducedVersion: 1.0
isCustomizable:
  value: true
  canBeChanged: true
  managedPropertyLogicalName: iscustomizableanddeletable
businessProcessType: 0
modernFlowType: 1
primaryEntity: none
connectionReferences:
- cr616_helpMeAgentUat.cr.KjQFMKAz
- new_sharedoffice365_71ca1
```

## หมายเหตุการออกแบบ
- **ตัด nested For_each** ของเดิม → ใช้ `GetItems` + `$filter` + `first()` แทน (INV-2 routing + fallback Helpdesk)
- **ack ถึงผู้แจ้ง** (`Send_email_ack_reporter`) + คืน `caseId` ให้ agent แสดงในแชท (INV-3, US-010)
- **error handling**: `Scope_Catch` เขียน `ErrorLog` + แจ้ง admin (INV-5, ไม่จบเงียบ)
- **gap**: เขียน `KnowledgeGaps` เมื่อไม่มี `kbRef` (เปิดเคสเพราะตอบไม่ได้) — US-014
- **SlaDueDate**: คำนวณจาก `SLAConfig.ResolutionHours` (fallback 48 ชม.)
