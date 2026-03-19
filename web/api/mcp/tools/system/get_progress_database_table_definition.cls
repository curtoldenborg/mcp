 

USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS web.api.mcp.tools.system.get_progress_database_table_definition INHERITS web.api.mcp.tools.base.tool :  

   METHOD PUBLIC OVERRIDE LONGCHAR ToolDefinition():
        RETURN  '
    ~{
  "name": "get_progress_database_table_definition",
  "description": "Retrieves the schema definition for a specific Progress OpenEdge database table, including field names, data types, mandatory flags, and primary index information.",
  "inputSchema": ~{
    "type": "object",
    "properties": ~{
      "table_name": ~{
        "type": "string",
        "description": "The exact name of the table to inspect (e.g., ~'Customer~', ~'Order~', ~'invoice~')."
      ~}
    ~},
    "required": ["table_name"]
  ~}
~}
'.
    END.
    
    METHOD PUBLIC OVERRIDE Progress.Json.ObjectModel.JsonObject Execute(id AS integer,  poArguments AS Progress.Json.ObjectModel.JsonObject ):
       
        DEFINE VARIABLE cTableName   AS CHAR NO-UNDO. 
        DEFINE VARIABLE hDataset     AS HANDLE NO-UNDO. 
        DEFINE VARIABLE lBody        AS LONGCHAR NO-UNDO. 
         
        cTablename   = poArguments:GetCharacter("table_name").
            
        RUN web\api\tabledefinition.p (INPUT cTableName, OUTPUT DATASET-HANDLE hDataset). 
        hDataset:WRITE-JSON("longchar",lBody, TRUE).
         
        RETURN CreateMcpResponseText(id,string(lbody),true).
    END. 

END CLASS.