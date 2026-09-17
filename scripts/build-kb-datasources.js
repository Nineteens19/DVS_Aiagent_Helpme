const fs = require('fs');
const path = require('path');

const srcPath = path.join(__dirname, '..', 'Monitor_case_Helpdesk', 'References', 'DataSources.json');
const original = JSON.parse(fs.readFileSync(srcPath, 'utf8'));
const templateDS = original.DataSources.find(ds => ds.Name === 'Cases');
const sampleDSList = original.DataSources.filter(ds => ds.Type === 'StaticDataSourceInfo');

function createConnectedDS(name, tableName, displayName, extraProps = {}) {
  const clone = JSON.parse(JSON.stringify(templateDS));
  clone.Name = name;
  clone.TableName = tableName;
  
  const oldKey = Object.keys(clone.DataEntityMetadataJson)[0];
  const metaObj = JSON.parse(clone.DataEntityMetadataJson[oldKey]);
  metaObj.name = tableName;
  metaObj.title = displayName;
  metaObj.webUrl = `https://dvsins.sharepoint.com/sites/PowerAppPRD/Lists/${name}/AllItems.aspx`;
  
  // Inject extra properties into schema & name mapping
  for (const [col, def] of Object.entries(extraProps)) {
    metaObj.schema.items.properties[col] = def;
    clone.ConnectedDataSourceInfoNameMapping[col] = def.title || col;
  }
  
  clone.DataEntityMetadataJson = {};
  clone.DataEntityMetadataJson[tableName] = JSON.stringify(metaObj);
  return clone;
}

const stringCol = (title) => ({
  title: title,
  type: 'string',
  'x-ms-permission': 'read-write',
  'x-ms-sort': 'asc,desc',
  'x-ms-capabilities': { filterFunctions: ['eq', 'startswith'] },
  maxLength: 255
});

const multiLineCol = (title) => ({
  title: title,
  type: 'string',
  'x-ms-permission': 'read-write',
  'x-ms-sort': 'none'
});

const boolCol = (title) => ({
  title: title,
  type: 'boolean',
  'x-ms-permission': 'read-write',
  'x-ms-sort': 'asc,desc',
  'x-ms-capabilities': { filterFunctions: ['eq'] }
});

const numberCol = (title) => ({
  title: title,
  type: 'number',
  format: 'double',
  'x-ms-permission': 'read-write',
  'x-ms-sort': 'asc,desc',
  'x-ms-capabilities': { filterFunctions: ['eq', 'gt', 'ge', 'lt', 'le', 'ne'] }
});

const aiKbProps = {
  Issue_Title: stringCol('Issue_Title'),
  System: stringCol('System'),
  Approved_Answer: multiLineCol('Approved_Answer'),
  Required_Information: multiLineCol('Required_Information'),
  Keywords: multiLineCol('Keywords'),
  Followup_Question: multiLineCol('Followup_Question'),
  Action_Type: stringCol('Action_Type'),
  Escalation_Rule: stringCol('Escalation_Rule'),
  Owner: stringCol('Owner'),
  Review_Status: stringCol('Review_Status'),
  Is_Active: stringCol('Is_Active')
};

const manualsProps = {
  IsActive: boolCol('IsActive'),
  DocType: stringCol('DocType'),
  Keywords: multiLineCol('Keywords')
};

const systemsProps = {
  DisplayOrder: numberCol('DisplayOrder'),
  IsActive: boolCol('IsActive')
};

const gapsProps = {
  UserQuestion: multiLineCol('UserQuestion'),
  SystemGuess: stringCol('SystemGuess'),
  Frequency: numberCol('Frequency'),
  GapStatus: stringCol('GapStatus'),
  Status: stringCol('Status')
};

const aiKbDS = createConnectedDS('AI_KnowledgeBase', '95e5e09d-6d20-4811-8833-820cef88fe98', 'AI_KnowledgeBase', aiKbProps);
const manualsDS = createConnectedDS('SystemManuals', 'SystemManuals', 'SystemManuals', manualsProps);
manualsDS.DataEntityMetadataJson['SystemManuals'] = manualsDS.DataEntityMetadataJson['SystemManuals'].replace(
  /\/Lists\/SystemManuals\/AllItems\.aspx/,
  '/SystemManuals/Forms/AllItems.aspx'
);
const systemsDS = createConnectedDS('Systems', '37a7b3db-d9ef-4cf8-b3f7-920f0ee3ee9a', 'Systems', systemsProps);
const gapsDS = createConnectedDS('KnowledgeGaps', '9beb45a0-08e2-4717-8eee-5b80bd218005', 'KnowledgeGaps', gapsProps);

const targetDataSources = {
  DataSources: [
    aiKbDS,
    manualsDS,
    systemsDS,
    gapsDS,
    ...sampleDSList
  ]
};

const outPath = path.join(__dirname, '..', 'Helpdesk_KB_Portal', 'References', 'DataSources.json');
fs.writeFileSync(outPath, JSON.stringify(targetDataSources, null, 2), 'utf8');
console.log('Successfully generated Helpdesk_KB_Portal/References/DataSources.json with enriched SharePoint column schemas.');
