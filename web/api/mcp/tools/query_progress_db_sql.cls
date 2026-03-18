 

USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS web.api.mcp.tools.query_progress_db_sql INHERITS web.api.mcp.tools.base.tool :  

   METHOD PUBLIC OVERRIDE LONGCHAR ToolDefinition():
        RETURN  '
      ~{
      "name": "query_progress_db_sql",
      "description": "Executes standard SQL-92 queries against the Progress OpenEdge database. Use ~'PUB.~' prefix for tables (e.g., SELECT * FROM PUB.Customer).",
      "inputSchema": ~{
        "type": "object",
        "properties": ~{
          "sqlQuery": ~{
            "type": "string",
            "description": "A full SQL-92 statement (e.g., ~'SELECT Name, Balance FROM PUB.Customer WHERE Balance > 1000~')."
          ~}
        ~},
        "required": ["sqlQuery"]
      ~}
    ~}
    '.
    END.
    
    METHOD PUBLIC OVERRIDE Progress.Json.ObjectModel.JsonObject Execute(id AS integer,  poArguments AS Progress.Json.ObjectModel.JsonObject ):
        var handle hDataset . 
        var longchar lBody. 
        
        DEF VAR cQuery AS CHAR NO-UNDO. 
        cQuery = poArguments:GetCharacter("sqlQuery") no-error.
        
        
        LOG-MANAGER:WRITE-MESSAGE("Query SQL:" + quoter(cquery),"LOG" ).    
        if cQuery ne "" then 
        do:
           RUN web\api\executesqlquery.p (INPUT cQuery, OUTPUT DATASET-HANDLE hDataset). 
           hDataset:WRITE-JSON("longchar",lBody, TRUE).
        end. 
        
        RETURN CreateMcpResponseText(id,lBody,true).
        
        CATCH e AS Progress.Lang.Error:
            LOG-MANAGER:WRITE-MESSAGE("Execute - error sql query","ERR").
            
            DEFINE VARIABLE iLoop AS INTEGER NO-UNDO.
    
            /* Loop through all messages in the error stack */
            DO iLoop = 1 TO e:NumMessages:
                LOG-MANAGER:WRITE-MESSAGE(
                    SUBSTITUTE("Error &1: &2", 
                    e:GetMessageNum(iLoop), 
                    e:GetMessage(iLoop)), 
                    "ERR"
                    ).
            END.
            
            RETURN CreateMcpResponseText(id,'error..',false).
        END CATCH. 
    END. 
    
END CLASS.