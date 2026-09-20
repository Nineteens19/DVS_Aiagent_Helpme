const fs = require('fs');
const path = require('path');
const YAML = require('../scratch/node_modules/yaml');

const REPO_ROOT = path.resolve(__dirname, '..');
const KB_DIR = path.join(REPO_ROOT, 'Helpdesk_KB_Portal');
const YAML_PATH = path.join(KB_DIR, 'Src', 'Home_KB.pa.yaml');
const OUT_CTRL4 = path.join(REPO_ROOT, 'scratch', 'hydrated_c4.json');

// 1. Read live templates
const liveC4 = JSON.parse(fs.readFileSync(path.join(REPO_ROOT, 'scratch', 'msapr_extracted', 'msapp', 'Controls', '4.json'), 'utf8').replace(/^\uFEFF/, ''));
const liveC75 = JSON.parse(fs.readFileSync(path.join(REPO_ROOT, 'scratch', 'msapr_extracted', 'msapp', 'Controls', '75.json'), 'utf8').replace(/^\uFEFF/, ''));

const templateDefaults = {};

function getDefaults(node) {
  const tname = node.Template && node.Template.Name;
  if (tname && !templateDefaults[tname]) {
    const rulesMap = {};
    if (node.Rules) {
      node.Rules.forEach(r => {
        rulesMap[r.Property] = { ...r };
      });
    }
    templateDefaults[tname] = {
      Template: JSON.parse(JSON.stringify(node.Template)),
      StyleName: node.StyleName || '',
      Rules: rulesMap,
      ControlPropertyState: [...(node.ControlPropertyState || [])]
    };
  }
  if (node.Children) {
    node.Children.forEach(getDefaults);
  }
}

getDefaults(liveC4.TopParent);
getDefaults(liveC75.TopParent);

// 2. Load Home_KB.pa.yaml
const homeYaml = fs.readFileSync(YAML_PATH, 'utf8');
const parsed = YAML.parse(homeYaml);

let currentId = 5;
let publishOrder = 0;

function getPropertyCategory(propName) {
  const behaviorProps = new Set([
    'OnSelect', 'OnChange', 'OnCheck', 'OnUncheck', 'OnStart', 'OnVisible',
    'OnHidden', 'OnNew', 'OnEdit', 'OnView', 'OnSave', 'OnCancel',
    'OnSuccess', 'OnFailure', 'OnReset'
  ]);
  const dataProps = new Set([
    'Default', 'DefaultSelectedItems', 'Items', 'Text', 'Value',
    'Selected', 'SelectedItems', 'Update', 'DataField', 'Required',
    'Valid', 'Error', 'ErrorMessage', 'Mode', 'DataSource', 'HintText',
    'InputTextPlaceholder', 'SelectMultiple', 'IsSearchable', 'SearchItems',
    'ConfirmExit', 'BackEnabled', 'Tooltip', 'ContentLanguage'
  ]);
  const constDataProps = new Set(['SizeBreakpoints']);

  if (behaviorProps.has(propName)) return 'Behavior';
  if (dataProps.has(propName)) return 'Data';
  if (constDataProps.has(propName)) return 'ConstantData';
  return 'Design';
}

function processNode(nodeName, nodeData, parentName, index) {
  const myId = String(currentId++);
  const pubIndex = publishOrder++;

  const rawControl = nodeData.Control || '';
  let tmplName = 'groupContainer';

  if (rawControl.includes('GroupContainer')) {
    tmplName = 'groupContainer';
  } else if (rawControl.includes('Label')) {
    tmplName = 'label';
  } else if (rawControl.includes('TextInput')) {
    tmplName = 'text';
  } else if (rawControl.includes('ComboBox')) {
    tmplName = 'combobox';
  } else if (rawControl.includes('Gallery')) {
    tmplName = 'gallery';
  }

  const baseDef = templateDefaults[tmplName];
  if (!baseDef) throw new Error('No base template for ' + tmplName);

  const rulesMap = {};
  for (const [pKey, pRule] of Object.entries(baseDef.Rules)) {
    rulesMap[pKey] = {
      Category: pRule.Category || getPropertyCategory(pKey),
      InvariantScript: pRule.InvariantScript,
      Property: pKey,
      RuleProviderType: pRule.RuleProviderType || 'Unknown'
    };
  }

  const props = nodeData.Properties || {};
  for (const [pKey, pVal] of Object.entries(props)) {
    let script = String(pVal);
    if (script.startsWith('=')) script = script.slice(1);
    rulesMap[pKey] = {
      Category: rulesMap[pKey] ? rulesMap[pKey].Category : getPropertyCategory(pKey),
      InvariantScript: script,
      Property: pKey,
      RuleProviderType: 'Unknown'
    };
  }

  const finalRules = [];
  const finalState = [];
  const handled = new Set();

  for (const pKey of baseDef.ControlPropertyState) {
    if (rulesMap[pKey]) {
      finalRules.push(rulesMap[pKey]);
      finalState.push(pKey);
      handled.add(pKey);
    }
  }

  for (const [pKey, r] of Object.entries(rulesMap)) {
    if (!handled.has(pKey)) {
      finalRules.push(r);
      finalState.push(pKey);
      handled.add(pKey);
    }
  }

  let variant = '';
  if (tmplName === 'groupContainer') {
    const dir = props.LayoutDirection || '';
    if (dir.includes('Vertical')) variant = 'verticalAutoLayoutContainer';
    else if (dir.includes('Horizontal')) variant = 'horizontalAutoLayoutContainer';
    else if (nodeData.Variant === 'AutoLayout') variant = 'autoLayoutContainer';
  } else if (tmplName === 'gallery') {
    variant = nodeData.Variant || 'BrowseLayout_Vertical_TwoTextOneImageVariant_ver5.0';
  }

  const children = [];

  if (tmplName === 'gallery') {
    const gtId = String(currentId++);
    const gtPub = publishOrder++;
    children.push({
      AllowAccessToGlobals: true,
      Children: [],
      ControlPropertyState: ['TemplateFill'],
      ControlUniqueId: gtId,
      HasDynamicProperties: false,
      Index: 0,
      IsAutoGenerated: false,
      IsDataControl: true,
      IsFromScreenLayout: false,
      IsGroupControl: false,
      IsLocked: false,
      LayoutName: '',
      MetaDataIDKey: '',
      Name: `${nodeName}Template1`,
      OptimizeForDevices: 'Off',
      Parent: nodeName,
      PersistMetaDataIDKey: false,
      PublishOrderIndex: gtPub,
      Rules: [
        {
          Category: 'Design',
          InvariantScript: 'RGBA(0, 0, 0, 0)',
          Property: 'TemplateFill',
          RuleProviderType: 'Unknown'
        }
      ],
      StyleName: '',
      Template: {
        CustomGroupControlTemplateName: '',
        FirstParty: true,
        Id: 'http://microsoft.com/appmagic/galleryTemplate',
        IsComponentDefinition: false,
        IsCustomGroupControlTemplate: false,
        IsPremiumPcfControl: false,
        LastModifiedTimestamp: '0',
        Name: 'galleryTemplate',
        OverridableProperties: {},
        Version: '1.0'
      },
      Type: 'ControlInfo',
      VariantName: ''
    });
  }

  if (nodeData.Children) {
    let childIdx = tmplName === 'gallery' ? 1 : 0;
    for (const childObj of nodeData.Children) {
      const childName = Object.keys(childObj)[0];
      const childData = childObj[childName];
      children.push(processNode(childName, childData, nodeName, childIdx++));
    }
  }

  return {
    AllowAccessToGlobals: true,
    Children: children,
    ControlPropertyState: finalState,
    ControlUniqueId: myId,
    HasDynamicProperties: false,
    Index: index,
    IsAutoGenerated: false,
    IsDataControl: false,
    IsFromScreenLayout: false,
    IsGroupControl: false,
    IsLocked: false,
    LayoutName: '',
    MetaDataIDKey: '',
    Name: nodeName,
    OptimizeForDevices: 'Off',
    Parent: parentName,
    PersistMetaDataIDKey: false,
    PublishOrderIndex: pubIndex,
    Rules: finalRules,
    StyleName: baseDef.StyleName,
    Template: JSON.parse(JSON.stringify(baseDef.Template)),
    Type: 'ControlInfo',
    VariantName: variant
  };
}

// 3. Screen TopParent
const screenBase = templateDefaults['screen'];
const screenRulesMap = {};
for (const [pKey, pRule] of Object.entries(screenBase.Rules)) {
  screenRulesMap[pKey] = { ...pRule };
}
const screenProps = parsed.Screens.Home_KB.Properties || {};
for (const [pKey, pVal] of Object.entries(screenProps)) {
  let script = String(pVal);
  if (script.startsWith('=')) script = script.slice(1);
  screenRulesMap[pKey] = {
    Category: 'Design',
    InvariantScript: script,
    Property: pKey,
    RuleProviderType: 'Unknown'
  };
}

const finalScreenRules = [];
const finalScreenState = [];
const sHandled = new Set();
for (const pKey of screenBase.ControlPropertyState) {
  if (screenRulesMap[pKey]) {
    finalScreenRules.push(screenRulesMap[pKey]);
    finalScreenState.push(pKey);
    sHandled.add(pKey);
  }
}
for (const [pKey, r] of Object.entries(screenRulesMap)) {
  if (!sHandled.has(pKey)) {
    finalScreenRules.push(r);
    finalScreenState.push(pKey);
    sHandled.add(pKey);
  }
}

const screenChildren = [];
let topIdx = 0;
for (const childObj of parsed.Screens.Home_KB.Children) {
  const childName = Object.keys(childObj)[0];
  const childData = childObj[childName];
  screenChildren.push(processNode(childName, childData, 'Home_KB', topIdx++));
}

const topParent = {
  AllowAccessToGlobals: true,
  Children: screenChildren,
  ControlPropertyState: finalScreenState,
  ControlUniqueId: '4',
  Index: 0,
  IsAutoGenerated: false,
  IsDataControl: false,
  IsFromScreenLayout: false,
  IsGroupControl: false,
  IsLocked: false,
  LayoutName: '',
  MetaDataIDKey: '',
  Name: 'Home_KB',
  OptimizeForDevices: 'Off',
  Parent: '',
  PersistMetaDataIDKey: false,
  PublishOrderIndex: 0,
  Rules: finalScreenRules,
  StyleName: '',
  Template: JSON.parse(JSON.stringify(screenBase.Template)),
  Type: 'ControlInfo',
  VariantName: ''
};

fs.writeFileSync(OUT_CTRL4, JSON.stringify({ TopParent: topParent }, null, 2), 'utf8');
console.log(`Generated fully-hydrated Controls/4.json: ${(fs.statSync(OUT_CTRL4).size / 1024).toFixed(1)} KB`);
