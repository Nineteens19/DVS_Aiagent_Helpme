const fs = require('fs');
const path = require('path');
const YAML = require('../scratch/node_modules/yaml');

const REPO_ROOT = path.resolve(__dirname, '..');
const KB_DIR = path.join(REPO_ROOT, 'Helpdesk_KB_Portal');
const YAML_PATH = path.join(KB_DIR, 'Src', 'Home_KB.pa.yaml');
const OUT_CTRL4 = path.join(KB_DIR, 'Controls', '4.json');
const PROP_PATH = path.join(KB_DIR, 'Properties.json');
const PUB_PATH = path.join(KB_DIR, 'Resources', 'PublishInfo.json');

console.log('Loading Home_KB.pa.yaml...');
const yamlText = fs.readFileSync(YAML_PATH, 'utf8');
const parsed = YAML.parse(yamlText);

let currentId = 5;
let publishOrder = 0;
const controlCounts = {
    screen: 1,
    groupContainer: 0,
    label: 0,
    text: 0,
    combobox: 0,
    gallery: 0,
    galleryTemplate: 0,
    rectangle: 0,
    icon: 0,
    form: 0,
    typedDataCard: 0
};

function createTemplate(name, version) {
    const id = name === 'rectangle' ? 'http://microsoft.com/appmagic/shapes/rectangle' : `http://microsoft.com/appmagic/${name}`;
    return {
        CustomGroupControlTemplateName: '',
        FirstParty: true,
        Id: id,
        IsComponentDefinition: false,
        IsCustomGroupControlTemplate: false,
        IsPremiumPcfControl: false,
        LastModifiedTimestamp: '0',
        Name: name,
        OverridableProperties: {},
        Version: version
    };
}

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
        'ConfirmExit', 'BackEnabled', 'Tooltip'
    ]);
    const constDataProps = new Set([
        'SizeBreakpoints'
    ]);

    if (behaviorProps.has(propName)) return 'Behavior';
    if (dataProps.has(propName)) return 'Data';
    if (constDataProps.has(propName)) return 'ConstantData';
    return 'Design';
}

function convertProperties(props, isScreen = false) {
    const rules = [];
    const state = [];
    if (!props) return { rules, state };

    for (const [key, val] of Object.entries(props)) {
        let script = String(val);
        if (script.startsWith('=')) {
            script = script.slice(1);
        }
        const rule = {
            Category: getPropertyCategory(key),
            InvariantScript: script,
            Property: key,
            RuleProviderType: 'Unknown'
        };
        rules.push(rule);
        state.push(key);
    }
    return { rules, state };
}

function processNode(nodeName, nodeData, parentName, index) {
    const myId = String(currentId++);
    const pubIndex = publishOrder++;

    const rawControl = nodeData.Control || '';
    let tmplName = 'groupContainer';
    let tmplVersion = '1.5.0';
    let styleName = 'defaultGroupContainerStyle';
    let isGroup = false;

    if (rawControl.includes('GroupContainer')) {
        tmplName = 'groupContainer';
        tmplVersion = '1.5.0';
        styleName = 'defaultGroupContainerStyle';
        isGroup = true;
        controlCounts.groupContainer++;
    } else if (rawControl.includes('Label')) {
        tmplName = 'label';
        tmplVersion = '2.5.1';
        styleName = 'defaultLabelStyle';
        controlCounts.label++;
    } else if (rawControl.includes('TextInput')) {
        tmplName = 'text';
        tmplVersion = '2.3.2';
        styleName = 'defaultTextStyle';
        controlCounts.text++;
    } else if (rawControl.includes('ComboBox')) {
        tmplName = 'combobox';
        tmplVersion = '2.4.0';
        styleName = 'defaultComboboxStyle';
        controlCounts.combobox++;
    } else if (rawControl.includes('Gallery')) {
        tmplName = 'gallery';
        tmplVersion = '2.15.0';
        styleName = 'defaultGalleryStyle';
        controlCounts.gallery++;
    }

    let variant = '';
    const props = nodeData.Properties || {};
    if (tmplName === 'groupContainer') {
        const dir = props.LayoutDirection || '';
        if (dir.includes('Vertical')) {
            variant = 'verticalAutoLayoutContainer';
        } else if (dir.includes('Horizontal')) {
            variant = 'horizontalAutoLayoutContainer';
        } else if (nodeData.Variant === 'AutoLayout') {
            variant = 'autoLayoutContainer';
        }
    } else if (tmplName === 'gallery') {
        variant = nodeData.Variant || 'BrowseLayout_Vertical_TwoTextOneImageVariant_ver5.0';
    }

    const { rules, state } = convertProperties(props);

    const children = [];

    // If gallery, inject galleryTemplate first
    if (tmplName === 'gallery') {
        const gtId = String(currentId++);
        const gtPub = publishOrder++;
        controlCounts.galleryTemplate++;
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
            Template: createTemplate('galleryTemplate', '1.0'),
            Type: 'ControlInfo',
            VariantName: ''
        });
    }

    // Process children
    if (nodeData.Children) {
        let childIdx = tmplName === 'gallery' ? 1 : 0;
        for (const childObj of nodeData.Children) {
            const childName = Object.keys(childObj)[0];
            const childData = childObj[childName];
            const childControl = processNode(childName, childData, nodeName, childIdx++);
            children.push(childControl);
        }
    }

    return {
        AllowAccessToGlobals: true,
        Children: children,
        ControlPropertyState: state,
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
        Rules: rules,
        StyleName: styleName,
        Template: createTemplate(tmplName, tmplVersion),
        Type: 'ControlInfo',
        VariantName: variant
    };
}

// Build screen TopParent
const screenProps = parsed.Screens.Home_KB.Properties || {};
const { rules: screenRules, state: screenState } = convertProperties(screenProps, true);

// Ensure default screen rules if missing
const defaultScreenRules = {
    Height: 'Max(App.Height, App.MinScreenHeight)',
    Width: 'Max(App.Width, App.MinScreenWidth)',
    ImagePosition: 'ImagePosition.Fit',
    Size: '1 + CountRows(App.SizeBreakpoints) - CountIf(App.SizeBreakpoints, Value >= Self.Width)',
    Orientation: 'If(Self.Width < Self.Height, Layout.Vertical, Layout.Horizontal)',
    LoadingSpinner: 'LoadingSpinner.None'
};

for (const [rKey, rVal] of Object.entries(defaultScreenRules)) {
    if (!screenState.includes(rKey)) {
        screenRules.push({
            Property: rKey,
            Category: 'Design',
            InvariantScript: rVal,
            RuleProviderType: 'Unknown'
        });
        screenState.push(rKey);
    }
}

const screenChildren = [];
let topChildIdx = 0;
for (const childObj of parsed.Screens.Home_KB.Children) {
    const childName = Object.keys(childObj)[0];
    const childData = childObj[childName];
    screenChildren.push(processNode(childName, childData, 'Home_KB', topChildIdx++));
}

const topParent = {
    AllowAccessToGlobals: true,
    Children: screenChildren,
    ControlPropertyState: screenState,
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
    Rules: screenRules,
    StyleName: 'defaultScreenStyle',
    Template: createTemplate('screen', '1.0'),
    Type: 'ControlInfo',
    VariantName: ''
};

const ctrl4Data = { TopParent: topParent };

fs.writeFileSync(OUT_CTRL4, JSON.stringify(ctrl4Data, null, 2), { encoding: 'utf8' });
console.log(`Generated Controls/4.json (${(fs.statSync(OUT_CTRL4).size / 1024).toFixed(1)} KB)`);

// Update Properties.json
const propData = JSON.parse(fs.readFileSync(PROP_PATH, 'utf8'));
propData.Name = 'Helpdesk_KB_Portal';
propData.AppDescription = 'Helpdesk AI Knowledge Base Management Portal (Deves Insurance)';
propData.ControlCount = controlCounts;
fs.writeFileSync(PROP_PATH, JSON.stringify(propData, null, 2), { encoding: 'utf8' });
console.log('Updated Properties.json with control counts:', controlCounts);

// Update PublishInfo.json
const pubData = JSON.parse(fs.readFileSync(PUB_PATH, 'utf8'));
pubData.AppName = 'Helpdesk_KB_Portal';
fs.writeFileSync(PUB_PATH, JSON.stringify(pubData), { encoding: 'utf8' });
console.log('Updated Resources/PublishInfo.json with AppName: Helpdesk_KB_Portal');

console.log('Done.');
