#!/usr/bin/env bash
# ==============================================================================
# Script: pack-kb-portal.sh
# Description: Packs the Helpdesk_KB_Portal Canvas App sources into .msapp package
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

CANVAS_SRC="${REPO_ROOT}/Helpdesk_KB_Portal"
MSAPP_OUT="${REPO_ROOT}/Helpdesk_KB_Portal.msapp"

echo "================================================================="
echo "📦 Packing Helpdesk KB Portal Canvas App (SourceCode Layout)"
echo "================================================================="

PAC_BIN="${HOME}/.dotnet/tools/pac"
if ! command -v "${PAC_BIN}" &> /dev/null; then
    if command -v pac &> /dev/null; then
        PAC_BIN="pac"
    else
        echo "❌ Error: pac CLI not found. Ensure Power Platform CLI is installed."
        exit 1
    fi
fi

# Step 1: Compile AST controls and update editorstate
echo "--> Compiling AST controls and rules with valid categories..."
NODE_PATH="${REPO_ROOT}/scratch/node_modules" node "${REPO_ROOT}/scripts/compile-kb-controls.js"

# Step 2: Rebuild Helpdesk_KB_Portal.msapr
echo "--> Syncing and rebuilding Helpdesk_KB_Portal.msapr..."
node -e '
const fs = require("fs");
const path = require("path");
const { execSync } = require("child_process");

const baseDir = "Helpdesk_KB_Portal";
const msaprDir = path.join("scratch", "msapr_build");

execSync(`rm -rf ${msaprDir} && mkdir -p ${msaprDir}/msapp/Controls ${msaprDir}/msapp/References ${msaprDir}/msapp/Resources`);

const msaprHeader = {
  "MsaprStructureVersion": "0.1",
  "UnpackedConfiguration": {
    "ContentTypes": [
      "PaYamlSourceCode"
    ]
  }
};
fs.writeFileSync(path.join(msaprDir, "msapr-header.json"), JSON.stringify(msaprHeader, null, 2), "utf8");

fs.copyFileSync(path.join(baseDir, "Header.json"), path.join(msaprDir, "msapp", "Header.json"));
fs.copyFileSync(path.join(baseDir, "Properties.json"), path.join(msaprDir, "msapp", "Properties.json"));
fs.copyFileSync(path.join(baseDir, "Resources", "PublishInfo.json"), path.join(msaprDir, "msapp", "Resources", "PublishInfo.json"));
fs.copyFileSync(path.join(baseDir, "Controls", "1.json"), path.join(msaprDir, "msapp", "Controls", "1.json"));

const refFiles = fs.readdirSync(path.join(baseDir, "References"));
refFiles.forEach(f => {
  fs.copyFileSync(path.join(baseDir, "References", f), path.join(msaprDir, "msapp", "References", f));
});

const outMsapr = path.join(baseDir, "Helpdesk_KB_Portal.msapr");
fs.rmSync(outMsapr, { force: true });
execSync(`cd ${msaprDir} && zip -q -r "${path.resolve(outMsapr)}" msapr-header.json msapp`);
'

# Step 3: Pack Canvas App sources using SourceCode layout
echo "--> Packing Canvas App sources with SourceCode layout..."
"${PAC_BIN}" canvas pack --sources "${CANVAS_SRC}" --msapp "${MSAPP_OUT}" --layout SourceCode --overwrite
echo "✅ Canvas App packed: ${MSAPP_OUT}"

# Step 4: Verify binary contents and structure
python3 -c "
import zipfile, json

with zipfile.ZipFile('${MSAPP_OUT}') as z:
    names = [n.replace('\\\\', '/') for n in z.namelist()]
    assert 'Src/Home_KB.pa.yaml' in names, 'Missing Src/Home_KB.pa.yaml!'
    assert 'packed.json' in names, 'Missing packed.json!'
    for name in z.namelist():
        data = z.read(name)
        assert not data.startswith(b'\xef\xbb\xbf'), f'UTF-8 BOM found in {name}'
        if name.endswith('.json'):
            json.loads(data.decode('utf-8'))
print('✅ Binary verification passed: Src/Home_KB.pa.yaml, packed.json, valid JSON, zero BOM.')
"

# Step 5: Build Canvas App Package Zip for make.powerapps.com Import
echo "--> Building Helpdesk_KB_Portal_Package.zip..."
PACKAGE_APP_ID="40bcf1d7-11e3-4d46-9082-e040955982f8"
PACKAGE_DIR="${REPO_ROOT}/scratch/package_build"
rm -rf "${PACKAGE_DIR}" "${REPO_ROOT}/Helpdesk_KB_Portal_Package.zip"
mkdir -p "${PACKAGE_DIR}/Microsoft.PowerApps/apps/${PACKAGE_APP_ID}"

cat <<EOF > "${PACKAGE_DIR}/manifest.json"
{
  "schemaVersion": "1.0",
  "details": {
    "displayName": "Helpdesk KB Management Portal",
    "description": "Helpdesk AI Knowledge Base Management Portal (Deves Insurance)",
    "createdTime": "$(date -u +%Y-%m-%dT%H:%M:%S.0000000Z)",
    "packageAttributes": {
      "environment": ""
    },
    "creator": "Deves IT Helpdesk Team",
    "sourceEnvironment": ""
  },
  "resources": {
    "${PACKAGE_APP_ID}": {
      "type": "Microsoft.PowerApps/apps",
      "name": "${PACKAGE_APP_ID}",
      "id": "/providers/Microsoft.PowerApps/apps/${PACKAGE_APP_ID}",
      "suggestedCreationType": "New",
      "creationType": "New",
      "details": {
        "displayName": "Helpdesk KB Management Portal"
      },
      "configurableBy": "User",
      "hierarchy": "Root",
      "dependsOn": []
    }
  }
}
EOF

cat <<EOF > "${PACKAGE_DIR}/Microsoft.PowerApps/apps/${PACKAGE_APP_ID}/${PACKAGE_APP_ID}.json"
{
  "appVersion": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "msappPath": "${PACKAGE_APP_ID}.msapp",
  "appId": "${PACKAGE_APP_ID}",
  "name": "Helpdesk_KB_Portal",
  "displayName": "Helpdesk KB Management Portal",
  "description": "Helpdesk AI Knowledge Base Management Portal (Deves Insurance)"
}
EOF

cp "${MSAPP_OUT}" "${PACKAGE_DIR}/Microsoft.PowerApps/apps/${PACKAGE_APP_ID}/${PACKAGE_APP_ID}.msapp"
(cd "${PACKAGE_DIR}" && zip -q -r "${REPO_ROOT}/Helpdesk_KB_Portal_Package.zip" manifest.json Microsoft.PowerApps)
echo "✅ Package Zip created: ${REPO_ROOT}/Helpdesk_KB_Portal_Package.zip"

echo "================================================================="
echo "🎉 Build completed successfully!"
echo "================================================================="
