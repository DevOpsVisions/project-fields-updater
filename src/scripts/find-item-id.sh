#!/usr/bin/env bash
set -euo pipefail
# Usage: find-item-id.sh <OWNER> <REPO> <ISSUE_NUMBER> <PROJECT_ID>
OWNER="$1"
REPO="$2"
ISSUE_NUMBER="$3"
PROJECT_ID="$4"

ISSUE_ID=$(gh api graphql -f query='
  query($owner: String!, $repo: String!, $issueNumber: Int!) {
    repository(owner: $owner, name: $repo) {
      issue(number: $issueNumber) {
        id
      }
    }
  }' \
  -f owner="$OWNER" \
  -f repo="$REPO" \
  -F issueNumber="$ISSUE_NUMBER" \
  --jq '.data.repository.issue.id')

ITEM_ID=$(gh api graphql -f query='
  query($projectId: ID!) {
    node(id: $projectId) {
      ... on ProjectV2 {
        items(first: 100) {
          nodes {
            id
            content {
              ... on Issue {
                id
              }
            }
          }
        }
      }
    }
  }' \
  -f projectId="$PROJECT_ID" \
  --jq ".data.node.items.nodes[] | select(.content.id == \"$ISSUE_ID\") | .id")

echo "item_id=$ITEM_ID" >> "$GITHUB_OUTPUT"
