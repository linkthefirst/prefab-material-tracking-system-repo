/*
Purpose:
Prepares the expected material list for comparison against received warehouse material.

Overview:
- Pulls manually entered expected material rows from an Excel table named MaterialList.
- Keeps only the fields needed for matching and quantity comparison.
- Removes blank work orders and blank descriptions.
- Cleans text fields.
- Groups duplicate material lines by Work Order, Description, and Unit.
- Outputs one expected quantity per material item.

Input:
Excel table: MaterialList

Required columns:
- WO
- Description
- Quantity
- Unit

Output columns:
- WO
- Description
- Unit
- Expected Qty

Notes:
- This query uses local workbook data only.
- No company-specific URLs, IDs, or internal records are included.
*/

let
    Source = Excel.CurrentWorkbook(){[Name="MaterialList"]}[Content],

    #"Kept Columns" = Table.SelectColumns(
        Source,
        {
            "WO",
            "Description",
            "Quantity",
            "Unit"
        }
    ),

    #"Filtered Rows" = Table.SelectRows(
        #"Kept Columns",
        each [WO] <> null 
            and Text.Trim(Text.From([WO])) <> "" 
            and [Description] <> null 
            and Text.Trim(Text.From([Description])) <> ""
    ),

    #"Changed Type" = Table.TransformColumnTypes(
        #"Filtered Rows",
        {
            {"WO", type text},
            {"Description", type text},
            {"Quantity", Int64.Type},
            {"Unit", type text}
        }
    ),

    #"Trimmed Text" = Table.TransformColumns(
        #"Changed Type",
        {
            {"WO", each Text.Trim(_), type text},
            {"Description", each Text.Trim(_), type text},
            {"Unit", each Text.Trim(_), type text}
        }
    ),

    #"Grouped Rows" = Table.Group(
        #"Trimmed Text",
        {"WO", "Description", "Unit"},
        {
            {"Expected Qty", each List.Sum([Quantity]), type number}
        }
    ),

    #"Sorted Rows" = Table.Sort(
        #"Grouped Rows",
        {
            {"WO", Order.Descending},
            {"Description", Order.Ascending}
        }
    )
in
    #"Sorted Rows"