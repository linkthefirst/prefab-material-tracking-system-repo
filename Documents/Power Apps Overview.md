# Power Apps Overview

The Power App provides a user-facing interface for warehouse and field users to search work order material, select items, add manual material lines, and generate material sign-out documentation.

## Main Features

- Search material by work order
- Display expected and received material
- Select material lines for sign-out
- Add manual material lines when needed
- Generate a material sign-out PDF
- Link back to source warehouse movement records

## Main Collections / Variables

| Name | Purpose |
|---|---|
| `colSelectedMaterial` | Stores material lines selected for sign-out |
| `gallerySignOutMaterial` | Displays selected sign-out material |
| `varCurrentWorkOrder` | Stores the active work order |
| `varPDFLink` | Stores the generated PDF link |
| `varPDFCreated` | Tracks whether PDF generation succeeded |

## Design Notes

The app is designed to keep warehouse users from needing to manually search through SharePoint or Excel. The goal is to make material handoff faster, cleaner, and easier to document.