 

USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS web.api.mcp.tools.get_progress_database_schema INHERITS web.api.mcp.tools.base.tool :  

   METHOD PUBLIC OVERRIDE LONGCHAR ToolDefinition():
        RETURN  '
           ~{
          "name": "get_progress_database_schema",
          "description": "Lists all available user tables in the Progress OpenEdge database.",
          "inputSchema": ~{
            "type": "object",
            "properties": ~{
            ~},
          "required": []
        ~}
        ~}'.
    END.

    
    METHOD PUBLIC OVERRIDE Progress.Json.ObjectModel.JsonObject Execute(id AS integer,  poArguments AS Progress.Json.ObjectModel.JsonObject ):
       
        DEFINE VARIABLE lBody  AS LONGCHAR NO-UNDO. 
        DEFINE VARIABLE hDataset AS HANDLE NO-UNDO. 
       
        RUN web\api\databaseschema_abl.p (OUTPUT DATASET-HANDLE hDataset). 
        hDataset:WRITE-JSON("longchar",lBody, TRUE).
         
        RETURN CreateMcpResponseText(id,lBody,true).
    END. 

END CLASS.