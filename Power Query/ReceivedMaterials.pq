/*
Purpose:
Parses received material lines from a SharePoint warehouse movement list.

Overview:
- Pulls warehouse movement records from SharePoint.
- Keeps only the columns needed for material tracking and traceability.
- Splits multi-line material contents into individual rows.
- Splits records with multiple work orders into separate rows.
- Extracts material description and received quantity from lines formatted like:
  Description xQuantity
- Detects unit as FT when quantity text ends with an apostrophe, otherwise EA.
- Groups received quantities by Work Order, Description, Unit, and Check-In Date.
- Adds a SharePoint item link for click-through traceability.

Input:
SharePoint list: Warehouse Movements

Required columns:
- WorkOrder
- Job
- Contents
- Location/Status
- ShippingNotes
- Attn/Notes
- TypeofPackage:
- Check-InDate
- ID

Output columns:
- WO
- Description
- Unit
- Received Qty
- Check-InDate
- Warehouse Movement Link
- SharePointEntryID

Notes:
- SharePoint URL and list ID are sanitized placeholders.
- Replace the example SharePoint URL, list ID, and list path with your own environment values.
*/

let
    Source = SharePoint.Tables(
        "https://contoso.sharepoint.com/sites/ExampleSite/",
        [Implementation=null, ApiVersion=15]
    ),

    #"Warehouse Movements List" =
        Source{[Id="00000000-0000-0000-0000-000000000000"]}[Items],

    #"Renamed Columns" = Table.RenameColumns(
        #"Warehouse Movements List",
        {{"ID", "SharePointEntryID"}}
    ),

    #"Kept Columns" = Table.SelectColumns(
        #"Renamed Columns",
        {
            "WorkOrder",
            "Job",
            "Contents",
            "Location/Status",
            "ShippingNotes",
            "Attn/Notes",
            "TypeofPackage:",
            "Check-InDate",
            "SharePointEntryID"
        }
    ),

    #"Filtered Rows" = Table.SelectRows(
        #"Kept Columns",
        each [WorkOrder] <> null
            and Text.Trim(Text.From([WorkOrder])) <> ""
            and [Contents] <> null
    ),

    #"Normalized Contents" = Table.TransformColumns(
        #"Filtered Rows",
        {
            {
                "Contents",
                each
                    if _ = null then null
                    else
                        Text.Replace(
                            Text.Replace(
                                Text.From(_),
                                "#(cr)#(lf)",
                                "#(lf)"
                            ),
                            "#(cr)",
                            "#(lf)"
                        ),
                type text
            }
        }
    ),

    #"Split Contents To Rows" = Table.ExpandListColumn(
        Table.TransformColumns(
            #"Normalized Contents",
            {
                {
                    "Contents",
                    each
                        List.Select(
                            List.Transform(
                                Text.Split(_, "#(lf)"),
                                each Text.Trim(_)
                            ),
                            each _ <> ""
                        ),
                    type list
                }
            }
        ),
        "Contents"
    ),

    #"Renamed Line" = Table.RenameColumns(
        #"Split Contents To Rows",
        {{"Contents", "Raw Line"}}
    ),

    #"Split WO" = Table.TransformColumns(
        #"Renamed Line",
        {
            {
                "WorkOrder",
                each List.Transform(
                    Text.Split(Text.From(_), ","),
                    each Text.Trim(_)
                ),
                type list
            }
        }
    ),

    #"Expanded WO" = Table.ExpandListColumn(
        #"Split WO",
        "WorkOrder"
    ),

    #"Added LastX" = Table.AddColumn(
        #"Expanded WO",
        "LastX",
        each
            let
                txt = [Raw Line]
            in
                if txt = null or Text.Trim(Text.From(txt)) = "" then
                    -1
                else
                    let
                        upperTxt = Text.Upper(Text.From(txt)),
                        pos = List.PositionOfAny(
                            List.Reverse(Text.ToList(upperTxt)),
                            {"X"}
                        )
                    in
                        if pos = -1 then -1 else Text.Length(upperTxt) - pos - 1,
        Int64.Type
    ),

    #"Added Description" = Table.AddColumn(
        #"Added LastX",
        "Description",
        each
            if [LastX] < 0 then
                Text.Trim([Raw Line])
            else
                Text.Trim(Text.Start([Raw Line], [LastX])),
        type text
    ),

    #"Added QtyText" = Table.AddColumn(
        #"Added Description",
        "QtyText",
        each
            if [LastX] < 0 then
                null
            else
                Text.Trim(Text.Range([Raw Line], [LastX] + 1)),
        type text
    ),

    #"Added Unit" = Table.AddColumn(
        #"Added QtyText",
        "Unit",
        each
            if [QtyText] = null then null
            else if Text.End(Text.Trim([QtyText]), 1) = "'" then "FT"
            else "EA",
        type text
    ),

    #"Added Received" = Table.AddColumn(
        #"Added Unit",
        "Received",
        each
            let
                s = [QtyText],
                num = if s = null then "" else Text.Select(s, {"0".."9"})
            in
                if num = "" then null else Number.From(num),
        type number
    ),

    #"Filtered Valid Rows" = Table.SelectRows(
        #"Added Received",
        each [Description] <> null
            and Text.Trim([Description]) <> ""
            and [Received] <> null
    ),

    #"Selected Final Columns" = Table.SelectColumns(
        #"Filtered Valid Rows",
        {
            "WorkOrder",
            "Description",
            "Unit",
            "Received",
            "Check-InDate",
            "SharePointEntryID"
        }
    ),

    #"Renamed Final" = Table.RenameColumns(
        #"Selected Final Columns",
        {
            {"WorkOrder", "WO"}
        }
    ),

    #"Changed Type" = Table.TransformColumnTypes(
        #"Renamed Final",
        {
            {"WO", type text},
            {"Description", type text},
            {"Unit", type text},
            {"Received", type number},
            {"Check-InDate", type date},
            {"SharePointEntryID", Int64.Type}
        }
    ),

    #"Trimmed Text" = Table.TransformColumns(
        #"Changed Type",
        {
            {"WO", each if _ = null then null else Text.Trim(_), type text},
            {"Description", each if _ = null then null else Text.Trim(_), type text},
            {"Unit", each if _ = null then null else Text.Trim(_), type text}
        }
    ),

    #"Grouped Rows" = Table.Group(
        #"Trimmed Text",
        {"WO", "Description", "Unit", "Check-InDate"},
        {
            {"Received Qty", each List.Sum([Received]), type number},
            {"SharePointEntryID", each List.Max([SharePointEntryID]), Int64.Type}
        }
    ),

    #"Added Warehouse Movement Link" = Table.AddColumn(
        #"Grouped Rows",
        "Warehouse Movement Link",
        each
            "https://contoso.sharepoint.com/sites/ExampleSite/Lists/WarehouseMovements/DispForm.aspx?ID="
            & Text.From([SharePointEntryID]),
        type text
    ),

    #"Reordered Columns" = Table.ReorderColumns(
        #"Added Warehouse Movement Link",
        {
            "WO",
            "Description",
            "Unit",
            "Received Qty",
            "Check-InDate",
            "Warehouse Movement Link",
            "SharePointEntryID"
        }
    ),

    #"Sorted Rows" = Table.Sort(
        #"Reordered Columns",
        {
            {"WO", Order.Descending},
            {"Check-InDate", Order.Descending},
            {"Description", Order.Ascending}
        }
    )
in
    #"Sorted Rows"