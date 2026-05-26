# Prefab Material Tracking System

A sanitized case study of a warehouse and prefabrication material tracking workflow built with Microsoft Power Platform, SharePoint, Excel Power Query, and Office Scripts.

This project demonstrates how prefab assemblies, warehouse material movement, work order status, and expected-vs-received quantities can be tracked in a centralized system to improve visibility, reduce manual entry, and support better communication between warehouse, prefab, and field teams.

All data, work orders, URLs, names, IDs, screenshots, and business-specific details in this repository are fictional or sanitized.

---

## Project Overview

The goal of this project was to improve tracking for prefabricated products and warehouse material tied to work orders.

Before this system, material and prefab status updates were difficult to track consistently. Information could be spread across emails, spreadsheets, SharePoint entries, and manual communication. This created room for lost material, duplicate ordering, unclear delivery status, and delays when the field needed to know whether material had been received or shipped.

This solution centralizes key tracking information and creates cleaner reporting around:

- Prefab assembly status
- Material received by work order
- Expected vs. received material quantities
- Remaining material needed
- Warehouse movement history
- Material sign-off records
- Labor productivity by cost code

---

## Key Features

### Prefab Assembly Tracking

Created a PowerApps and SharePoint-based tracking process for prefab assemblies and containers.

Tracked information includes:

- Prefab assembly ID
- Work order
- Job/project
- Quantity
- Container type
- Container number
- Current status
- Current location
- Notes
- Last updated information

This helped create a clearer chain of custody for prefabricated products as they moved through the shop, warehouse, and delivery process.

---

### QR Code Scanning

Added QR-based lookup functionality so users could quickly scan a prefab assembly ID and pull up the correct record in PowerApps.

This reduced manual searching and made it easier to update status, location, notes, and delivery information from a mobile device or tablet.

---

### Expected vs. Received Material Reporting

Built Excel Power Query reports that compare expected material quantities against received warehouse material.

The reporting logic calculates:

- Expected quantity
- Received quantity
- Remaining quantity
- Material status
- Completion percentage by work order

This gives warehouse, prefab, and field teams a clearer view of what material has arrived and what is still missing.

### ExpectedMaterials.pq

Cleans and groups the expected material list from an Excel table named `MaterialList`.

This query standardizes manually entered expected material data and creates one summarized expected quantity per work order, material description, and unit. The result is later compared against received material from warehouse movement records.

### ReceivedMaterials.pq

Parses received material from a SharePoint warehouse movement list.

This query converts multi-line warehouse movement entries into normalized material rows. It extracts descriptions, received quantities, units, check-in dates, and SharePoint item IDs, then groups received quantities by work order and material description. A sanitized SharePoint link column is included to show how source-record traceability was handled.

### ExpectedVsReceived.pq

Compares expected material against received warehouse material.

This query merges `ExpectedMaterials` with `ReceivedMaterials` by work order and material description. It calculates received quantity, remaining quantity, and a simple status value showing whether each material line is not received, partially received, fully received, or over received.

---

### Warehouse Movement Parsing

Created Power Query logic to clean and transform warehouse movement records into usable material tracking rows.

This included parsing material descriptions and quantities from text-based warehouse entries, then grouping the received quantities by work order and material description.

Example input:

```text
1/2" Hex Nuts x700
1/2" Lock Washers x500