# Limitations

This project was built around real warehouse workflows, so some parts depend on consistent data entry.

## Known Limitations

- Material matching depends heavily on consistent descriptions.
- Received material lines must follow a recognizable `Description xQuantity` format.
- SharePoint lookup and choice fields may need adjustment in different environments.
- Power Query source URLs and list IDs are environment-specific.
- Power Automate flows are documented, not directly exported, to avoid exposing tenant-specific details.
- The sample data is simplified and does not include confidential organizational records.

## Future Improvements

- Add a controlled material reference table
- Add standardized receiver input forms
- Improve fuzzy matching for material descriptions
- Add dashboard views for foremen
- Add stronger duplicate detection for imported requisition files