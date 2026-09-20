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

# Step 3: Prepare SourceCode directory and pack with PAC CLI
echo "--> Preparing SourceCode directory for PAC CLI packaging..."
SRC_DIR="${REPO_ROOT}/scratch/sourcecode_build"
rm -rf "${SRC_DIR}"
mkdir -p "${SRC_DIR}/Src"

# Copy msapr files into a valid msapr container
python3 -c "
import zipfile, os

msapr_path = '${SRC_DIR}/Helpdesk_KB_Portal.msapr'
with zipfile.ZipFile(msapr_path, 'w', zipfile.ZIP_DEFLATED) as z:
    z.writestr('msapr-header.json', '{\"MsaprStructureVersion\":\"0.1\",\"UnpackedConfiguration\":{\"ContentTypes\":[\"PaYamlSourceCode\"]}}')
    with open('${REPO_ROOT}/Helpdesk_KB_Portal/Header.json', 'rb') as f:
        z.writestr('msapp/Header.json', f.read())
    with open('${REPO_ROOT}/Helpdesk_KB_Portal/Properties.json', 'rb') as f:
        z.writestr('msapp/Properties.json', f.read())
    with open('${REPO_ROOT}/Helpdesk_KB_Portal/Controls/1.json', 'rb') as f:
        z.writestr('msapp/Controls/1.json', f.read())
    with open('${REPO_ROOT}/scratch/hydrated_c4.json', 'rb') as f:
        z.writestr('msapp/Controls/4.json', f.read())
    with open('${REPO_ROOT}/Helpdesk_KB_Portal/References/Themes.json', 'rb') as f:
        z.writestr('msapp/References/Themes.json', f.read())
    with open('${REPO_ROOT}/Helpdesk_KB_Portal/References/DataSources.json', 'rb') as f:
        z.writestr('msapp/References/DataSources.json', f.read())
    with open('${REPO_ROOT}/Helpdesk_KB_Portal/References/ModernThemes.json', 'rb') as f:
        z.writestr('msapp/References/ModernThemes.json', f.read())
    with open('${REPO_ROOT}/Helpdesk_KB_Portal/References/Resources.json', 'rb') as f:
        z.writestr('msapp/References/Resources.json', f.read())
    with open('${REPO_ROOT}/Helpdesk_KB_Portal/References/Templates.json', 'rb') as f:
        z.writestr('msapp/References/Templates.json', f.read())
    with open('${REPO_ROOT}/Helpdesk_KB_Portal/Resources/PublishInfo.json', 'rb') as f:
        z.writestr('msapp/Resources/PublishInfo.json', f.read())
"

cp "${REPO_ROOT}/Helpdesk_KB_Portal/Src/App.pa.yaml" "${SRC_DIR}/Src/"
cp "${REPO_ROOT}/Helpdesk_KB_Portal/Src/Home_KB.pa.yaml" "${SRC_DIR}/Src/"
cp "${REPO_ROOT}/Helpdesk_KB_Portal/Src/_EditorState.pa.yaml" "${SRC_DIR}/Src/"

echo "--> Packing .msapp via PAC CLI..."
"${PAC_BIN}" canvas pack --sources "${SRC_DIR}" --msapp "${MSAPP_OUT}" --layout SourceCode --overwrite
echo "✅ Canvas App packed successfully via PAC CLI: ${MSAPP_OUT}"

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
