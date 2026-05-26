# Architecture Overview

This project demonstrates a material tracking workflow built with Microsoft 365 tools.

## Main Components

- **SharePoint Lists** store warehouse movement records, prefab order records, and sign-out data.
- **Excel / Power Query** cleans and compares expected material against received material.
- **Power Apps** provides a user-facing interface for material sign-out and work order lookup.
- **Power Automate** handles PDF generation, email notifications, and workflow automation.
- **Office Scripts** support Excel automation and structured data export.

## Data Flow

1. Expected material is entered or imported into an Excel table.
2. Warehouse movement records are pulled from SharePoint.
3. Power Query parses received material lines from movement records.
4. Expected and received quantities are compared by work order and material description.
5. Power Apps allows users to review/sign out material.
6. Power Automate generates PDFs and sends notifications.
7. Reports can be used by foremen or warehouse staff to check material status.

## Design Goals

- Reduce manual lookup work
- Improve material traceability
- Show received vs expected material by work order
- Create cleaner handoff documentation
- Keep the workflow usable for field and warehouse users