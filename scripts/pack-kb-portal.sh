#!/usr/bin/env bash
# ==============================================================================
# Script: pack-kb-portal.sh
# Description: Packs the Helpdesk_KB_Portal Canvas App sources into 100% hydrated .msapp and package
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

MSAPP_OUT="${REPO_ROOT}/Helpdesk_KB_Portal.msapp"

echo "================================================================="
echo "📦 Building Fully-Hydrated Helpdesk KB Portal Canvas App"
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

# Step 1: Ensure extracted reference templates exist
if [ ! -d "${REPO_ROOT}/scratch/msapr_extracted" ]; then
    echo "--> Downloading live reference templates from tenant..."
    "${PAC_BIN}" canvas download --name "Monitor_case_Helpdesk" --file-name "${REPO_ROOT}/scratch/live_downloaded_monitor.msapp" --overwrite
    rm -rf "${REPO_ROOT}/scratch/live_unpacked_pac"
    "${PAC_BIN}" canvas unpack --msapp "${REPO_ROOT}/scratch/live_downloaded_monitor.msapp" --sources "${REPO_ROOT}/scratch/live_unpacked_pac" --layout SourceCode
    python3 -c "
import zipfile
with zipfile.ZipFile('${REPO_ROOT}/scratch/live_unpacked_pac/live_downloaded_monitor.msapr') as z:
    z.extractall('${REPO_ROOT}/scratch/msapr_extracted')
"
fi

# Step 2: Compile fully-hydrated AST from Home_KB.pa.yaml and live templates
echo "--> Compiling fully-hydrated AST (6,489 rules across 136 controls)..."
NODE_PATH="${REPO_ROOT}/scratch/node_modules" node "${REPO_ROOT}/scripts/compile-hydrated-kb.js"

# Step 3: Package .msapp binary with native Power Apps Studio structure
echo "--> Packaging Helpdesk_KB_Portal.msapp binary..."
python3 -c "
import zipfile, os

msapp_path = '${MSAPP_OUT}'
if os.path.exists(msapp_path):
    os.remove(msapp_path)

with zipfile.ZipFile(msapp_path, 'w', zipfile.ZIP_DEFLATED) as z:
    with open('${REPO_ROOT}/Helpdesk_KB_Portal/Header.json', 'rb') as f:
        z.writestr('Header.json', f.read())
    with open('${REPO_ROOT}/Helpdesk_KB_Portal/Properties.json', 'rb') as f:
        z.writestr('Properties.json', f.read())
    with open('${REPO_ROOT}/Helpdesk_KB_Portal/Controls/1.json', 'rb') as f:
        z.writestr('Controls\\\\1.json', f.read())
    with open('${REPO_ROOT}/scratch/hydrated_c4.json', 'rb') as f:
        z.writestr('Controls\\\\4.json', f.read())
    with open('${REPO_ROOT}/Helpdesk_KB_Portal/References/Themes.json', 'rb') as f:
        z.writestr('References\\\\Themes.json', f.read())
    with open('${REPO_ROOT}/Helpdesk_KB_Portal/References/DataSources.json', 'rb') as f:
        z.writestr('References\\\\DataSources.json', f.read())
    with open('${REPO_ROOT}/Helpdesk_KB_Portal/References/ModernThemes.json', 'rb') as f:
        z.writestr('References\\\\ModernThemes.json', f.read())
    with open('${REPO_ROOT}/Helpdesk_KB_Portal/References/Resources.json', 'rb') as f:
        z.writestr('References\\\\Resources.json', f.read())
    with open('${REPO_ROOT}/Helpdesk_KB_Portal/References/Templates.json', 'rb') as f:
        z.writestr('References\\\\Templates.json', f.read())
    with open('${REPO_ROOT}/Helpdesk_KB_Portal/Resources/PublishInfo.json', 'rb') as f:
        z.writestr('Resources\\\\PublishInfo.json', f.read())
    with open('${REPO_ROOT}/Helpdesk_KB_Portal/Src/_EditorState.pa.yaml', 'rb') as f:
        z.writestr('Src\\\\_EditorState.pa.yaml', f.read())
    with open('${REPO_ROOT}/Helpdesk_KB_Portal/Src/Home_KB.pa.yaml', 'rb') as f:
        z.writestr('Src\\\\Home_KB.pa.yaml', f.read())
    with open('${REPO_ROOT}/Helpdesk_KB_Portal/Src/App.pa.yaml', 'rb') as f:
        z.writestr('Src\\\\App.pa.yaml', f.read())
"
echo "✅ Canvas App packed: ${MSAPP_OUT}"

# Step 4: Validate integrity with PAC CLI unpack
TMP_UNPACK="$(mktemp -d)"
trap 'rm -rf "${TMP_UNPACK}"' EXIT

echo "--> Validating .msapp integrity via pac canvas unpack..."
"${PAC_BIN}" canvas unpack --msapp "${MSAPP_OUT}" --sources "${TMP_UNPACK}" --layout SourceCode --overwrite
echo "✅ Unpack validation succeeded!"

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
