 

USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS web.api.mcp.tools.turn_on_off_coffemachine INHERITS web.api.mcp.tools.base.tool :  

   METHOD PUBLIC OVERRIDE LONGCHAR ToolDefinition():
        RETURN  '
           ~{
        "name": "turn_on_off_coffemachine",
        "description": "power on off coffemachine",
        "inputSchema": ~{
          "type": "object",
          "properties": ~{
            "tableName": ~{ "type": "string", "description": "The table name (e.g., Customer)" ~},
            "whereClause": ~{ "type": "string", "description": "The ABL filter (e.g., CustNum < 50)" ~}
          ~},
          "required": ["tableName", "whereClause"]
        ~}
      ~}'.
    END.
    
    METHOD PUBLIC OVERRIDE Progress.Json.ObjectModel.JsonObject Execute(id AS integer,  poArguments AS Progress.Json.ObjectModel.JsonObject ):
        RETURN CreateMcpResponseText(id,"Completed",true).
    END. 

END CLASS.