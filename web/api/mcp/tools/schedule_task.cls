 

USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.


CLASS web.api.mcp.tools.schedule_task INHERITS web.api.mcp.tools.base.tool :  

   METHOD PUBLIC OVERRIDE LONGCHAR ToolDefinition():
        RETURN  '
      ~{
          "name": "schedule_task",
          "description": "Schedules a trigger for an n8n workflow by sending a payload to a webhook URL at a specific time.",
          "inputSchema": ~{
            "type": "object",
            "properties": ~{
              "scheduled_time": ~{
                "type": "string",
                "description": "When to trigger the webhook. Supports ISO 8601 timestamps (2025-05-20T09:00:00Z) or relative offsets like +30 minutes."
              ~},
              "chat_input": ~{
                "type": "string",
                "description": "The specific message, query, or data from the chat that n8n should process."
              ~},
              "additional_data": ~{
                "type": "object",
                "description": "Any extra metadata or JSON structure needed for the n8n workflow nodes."
              ~}
            ~},
            "required": ["scheduled_time", "chat_input"]
          ~}
        ~}'.
      
    END.
    
    METHOD PUBLIC OVERRIDE Progress.Json.ObjectModel.JsonObject Execute(id AS integer,  poArguments AS Progress.Json.ObjectModel.JsonObject ):

        DEFINE VARIABLE cTime  AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cInput AS CHARACTER NO-UNDO.
        
        /* Get values from the AI request */
        cTime  = poArguments:GetCharacter("scheduled_time").
        cInput = poArguments:GetCharacter("chat_input").

        /*
        /* TODO: Add your logic here to call n8n or save to a task table */
        DEFINE VARIABLE oResponse AS JsonObject NO-UNDO.
        oResponse = NEW JsonObject().
        oResponse:Add("status", "success").
        oResponse:Add("message", "Task scheduled for " + cTime).
        RETURN oResponse.
        */
         
        RETURN CreateMcpResponseText(id,"Task scheduled for " + cTime,false).
    END. 

END CLASS.