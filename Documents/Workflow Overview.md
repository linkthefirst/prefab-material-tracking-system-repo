# Workflow Overview

This project tracks expected material, received material, and material sign-outs across a Microsoft 365 workflow.

## 1. Expected Material

Expected material starts from a material list or requisition file. The `ExpectedMaterials` Power Query cleans the data and groups duplicate material lines by work order, description, and unit.

## 2. Received Material

Received material comes from warehouse movement records stored in SharePoint. The `ReceivedMaterials` Power Query parses multi-line material entries and extracts:

- Work order
- Material description
- Received quantity
- Unit
- Check-in date
- Source SharePoint item ID

## 3. Expected vs. Received Comparison

The `ExpectedVsReceived` query compares expected material against received material by work order and description.

Each row is assigned a status:

- Not Received
- Partially Received
- Fully Received
- Over Received

## 4. Material Sign-Out

The Power App allows users to select material from a work order and create a sign-out record. Manual material can also be added when needed.

## 5. PDF Generation

Power Automate generates a PDF sign-out sheet from selected material. The PDF can be saved to SharePoint and shared with the appropriate users.

## 6. Reporting

The cleaned data can support Excel reports, Power BI dashboards, or foreman-facing material status views.