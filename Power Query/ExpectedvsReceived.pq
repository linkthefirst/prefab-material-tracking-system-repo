/*
Purpose:
Compares expected material quantities against received warehouse material quantities.

Overview:
- Uses the ExpectedMaterials query as the expected material source.
- Uses the ReceivedMaterials query as the received material source.
- Matches records by Work Order and Description.
- Fills missing received quantities with 0.
- Calculates remaining quantity.
- Assigns a material status based on received quantity.

Input queries:
- ExpectedMaterials
- ReceivedMaterials

Expected input columns:
ExpectedMaterials:
- WO
- Description
- Unit
- Expected Qty

ReceivedMaterials:
- WO
- Description
- Received Qty

Output columns:
- WO
- Description
- Unit
- Expected Qty
- Received Qty
- Remaining Qty
- Status

Notes:
- Matching is based on Work Order and Description only.
- Unit is intentionally not used as a merge key because received material text may not always use consistent units.
- This works best when material descriptions are entered consistently between expected and received sources.
*/

let
    Expected = ExpectedMaterials,
    Received = ReceivedMaterials,

    #"Merged Queries" = Table.NestedJoin(
        Expected,
        {"WO", "Description"},
        Received,
        {"WO", "Description"},
        "ReceivedData",
        JoinKind.LeftOuter
    ),

    #"Expanded ReceivedData" = Table.ExpandTableColumn(
        #"Merged Queries",
        "ReceivedData",
        {"Received Qty"},
        {"Received Qty"}
    ),

    #"Replaced Nulls" = Table.ReplaceValue(
        #"Expanded ReceivedData",
        null,
        0,
        Replacer.ReplaceValue,
        {"Received Qty"}
    ),

    #"Added Remaining Qty" = Table.AddColumn(
        #"Replaced Nulls",
        "Remaining Qty",
        each [Expected Qty] - [Received Qty],
        type number
    ),

    #"Added Status" = Table.AddColumn(
        #"Added Remaining Qty",
        "Status",
        each
            if [Received Qty] = 0 then "Not Received"
            else if [Received Qty] < [Expected Qty] then "Partially Received"
            else if [Received Qty] = [Expected Qty] then "Fully Received"
            else "Over Received",
        type text
    ),

    #"Sorted Rows" = Table.Sort(
        #"Added Status",
        {
            {"WO", Order.Descending},
            {"Description", Order.Ascending}
        }
    )
in
    #"Sorted Rows"