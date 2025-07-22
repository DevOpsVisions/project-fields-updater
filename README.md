# Auto Update Project Fields on Issue Close

This GitHub Action automatically updates custom fields of items in an **Organization Project** (GitHub Projects v2) when an issue is closed. It is designed for organizations using GitHub Projects (v2) to track issues and automate field updates based on configurable rules.

## Features
- **Automated Field Updates:** Updates custom fields for project items when issues are closed.
- **Supports Multiple Field Types:** Number, SingleSelect, Date, and Text fields are supported.
- **Configurable:** Supports custom field configuration via a JSON file.
- **Secure:** Requires a GitHub token for authentication.

## Usage
Add the following to your workflow YAML:

```yaml
on:
  issues:
    types: [closed]

env:
  GH_TOKEN: ${{ secrets.GH_PAT }}

jobs:
  update-custom-fields:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Update Project Item Custom Fields
        uses: DevOpsVisions/project-fields-updater@main
        with:
          org: ${{ github.repository_owner }}
          project_number: 52
          owner: ${{ github.repository_owner }}
          repo: ${{ github.event.repository.name }}
          issue_number: ${{ github.event.issue.number }}
          config_path: configs/fields-config.json
```

## Inputs
| Name           | Description                          | Required | Default              |
|----------------|--------------------------------------|----------|----------------------|
| org            | The organization name                | Yes      | -                    |
| project_number | The project number                   | Yes      | -                    |
| owner          | The repository owner                 | Yes      | -                    |
| repo           | The repository name                  | Yes      | -                    |
| issue_number   | The issue number                     | Yes      | -                    |
| config_path    | Path to the fields-config.json file   | No       | fields-config.json   |

## Field Configuration
Supported field types: **Number**, **SingleSelect**, **Date**, and **Text**.

Create a `fields-config.json` file in your repository to specify which fields to update and how. Example:

```json
[
  {
    "field_name": "Week",
    "field_type": "number",
    "field_value": "30"
  },
  {
    "field_name": "Month",
    "field_type": "singleSelect",
    "field_value": "Jul"
  },
  {
    "field_name": "Date",
    "field_type": "date",
    "field_value": "2025-07-22"
  },
  {
    "field_name": "Reason",
    "field_type": "text",
    "field_value": "Reason for the change"
  }
]
```
### Organization Default Use Case

In our organization, we initially created this action to automatically update the following fields when closing an issue:
- **Week**: with the current week number
- **Month**: with the current month (e.g., "Jul")
- **Date**: with the current date

If this matches your use case, set the `field_value` to `auto` for these fields in your config, and the action will update them with the current values automatically.

Example (`fields-config.json`):

```json
[
  {
    "field_name": "Week",
    "field_type": "number",
    "field_value": "auto"
  },
  {
    "field_name": "Month",
    "field_type": "singleSelect",
    "field_value": "auto"
  },
  {
    "field_name": "Date",
    "field_type": "date",
    "field_value": "auto"
  }
]
```

## How It Works
1. **Install GitHub CLI:** The action installs the GitHub CLI (`gh`) for API access.
2. **Find Project Item:** Locates the project item for the closed issue.
3. **Update Fields:** Updates the specified fields using the configuration file.

## Requirements
- Organization Projects (GitHub Projects v2)
- GitHub CLI (`gh`)
- `GITHUB_TOKEN` with the following permissions:
  - **Organization permissions:** Read and Write access to issue fields and organization projects
  - **Repository permissions:** Read access to code, issues, and metadata

## Scripts
Scripts are located in `src/scripts/`:
- `entrypoint.sh`: Main entry point
- `get-project-info.sh`: Fetches project info
- `find-item-id.sh`: Finds the project item ID
- `update-fields.sh`: Updates custom fields

## License
MIT

## Author
DevOpsVisions



