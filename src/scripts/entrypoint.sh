#!/usr/bin/env bash
set -euo pipefail

ORG="$1"
PROJECT_NUMBER="$2"
OWNER="$3"
REPO="$4"
ISSUE_NUMBER="$5"

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get project info
"$SCRIPT_DIR/get-project-info.sh" "$ORG" "$PROJECT_NUMBER"
PROJECT_ID=$(jq -r '.data.organization.projectV2.id' project_data.json)

# Find item id
"$SCRIPT_DIR/find-item-id.sh" "$OWNER" "$REPO" "$ISSUE_NUMBER" "$PROJECT_ID"
ITEM_ID=$(cat $GITHUB_OUTPUT | grep '^item_id=' | tail -1 | cut -d= -f2-)

# Update fields
"$SCRIPT_DIR/update-fields.sh" "$PROJECT_ID" "$ITEM_ID" "${6:-field-config.json}"
