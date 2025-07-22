#!/usr/bin/env bash
set -euo pipefail
# Usage: get-project-info.sh <ORG> <PROJECT_NUMBER>
ORG="$1"
PROJECT_NUMBER="$2"

RESPONSE=$(gh api graphql -f query='
  query($org: String!, $number: Int!) {
    organization(login: $org) {
      projectV2(number: $number) {
        id
        fields(first: 100) {
          nodes {
            ... on ProjectV2FieldCommon {
              id
              name
              dataType
            }
            ... on ProjectV2SingleSelectField {
              name
              options { id name }
            }
          }
        }
      }
    }
  }' \
  -f org="$ORG" -F number="$PROJECT_NUMBER")

echo "$RESPONSE" > project_data.json
echo "project_id=$(jq -r '.data.organization.projectV2.id' project_data.json)" >> "$GITHUB_OUTPUT"
