#!/usr/bin/env bash
set -euo pipefail

## Usage: update-fields.sh [PROJECT_ID] [ITEM_ID]
## If arguments are not provided, falls back to environment variables.


# Accept PROJECT_ID, ITEM_ID, and CONFIG_PATH as arguments, fallback to env vars
PROJECT_ID="${1:-${PROJECT_ID:-}}"
ITEM_ID="${2:-${ITEM_ID:-}}"
CONFIG_PATH="${3:-field-config.json}"

if [ -z "$PROJECT_ID" ] || [ -z "$ITEM_ID" ]; then
  echo "Error: PROJECT_ID and ITEM_ID must be provided as arguments or environment variables."
  exit 1
fi

FIELD_DATA=$(jq '.data.organization.projectV2.fields.nodes' project_data.json)


if [ ! -f "$CONFIG_PATH" ]; then
  echo "Missing $CONFIG_PATH"
  exit 1
fi

while IFS= read -r FIELD; do
  NAME=$(echo "$FIELD" | jq -r .field_name)
  VALUE_RAW=$(echo "$FIELD" | jq -r .field_value)
  TYPE=$(echo "$FIELD" | jq -r .field_type)

  if [ "$VALUE_RAW" = "auto" ]; then
    case "$NAME" in
      Week)   VALUE=$(date +%V) ;;
      Month)  VALUE=$(date +%b) ;;
      Date)   VALUE=$(date +%F) ;;
      *)      VALUE=$(date +%F) ;;
    esac
  else
    VALUE="$VALUE_RAW"
  fi

  FIELD_NODE=$(echo "$FIELD_DATA" | jq -c --arg name "$NAME" '.[] | select(.name == $name)')
  if [ -z "$FIELD_NODE" ] || ! echo "$FIELD_NODE" | jq empty 2>/dev/null; then
    echo "Field '$NAME' not found or FIELD_NODE is not valid JSON. Skipping."
    continue
  fi

  FIELD_ID=$(echo "$FIELD_NODE" | jq -r .id)
  case "$TYPE" in
    singleSelect)
      OPTION_ID=$(echo "$FIELD_NODE" | jq -r --arg val "$VALUE" '.options[] | select(.name == $val) | .id')
      if [ -z "$OPTION_ID" ]; then
        echo "Option '$VALUE' not found for field '$NAME'"
        continue
      fi
      VALUE_BLOCK="singleSelectOptionId: \"$OPTION_ID\""
      ;;
    number)
      VALUE_BLOCK="number: $VALUE"
      ;;
    text)
      ESCAPED_VALUE=$(printf '%s' "$VALUE" | jq -aRs .)
      VALUE_BLOCK="text: $ESCAPED_VALUE"
      ;;
    date)
      VALUE_BLOCK="date: \"$VALUE\""
      ;;
    *)
      echo "Unsupported field type: $TYPE"
      continue
      ;;
  esac

  echo "Updating $NAME to '$VALUE'"
  gh api graphql --raw-field query="mutation { updateProjectV2ItemFieldValue(input: { projectId: \"$PROJECT_ID\", itemId: \"$ITEM_ID\", fieldId: \"$FIELD_ID\", value: { $VALUE_BLOCK } }) { projectV2Item { id } } }" > /dev/null
done < <(jq -c '.[]' "$CONFIG_PATH")
