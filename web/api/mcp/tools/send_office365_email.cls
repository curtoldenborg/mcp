  /*------------------------------------------------------------------------
    File        : send_office365_email
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS web.api.mcp.tools.send_office365_email INHERITS web.api.mcp.tools.base.tool : 
    
    CONSTRUCTOR PUBLIC send_office365_email ( ):
       SUPER ().
    END CONSTRUCTOR.

    // testing    
    CONSTRUCTOR PUBLIC send_office365_email (toEmailAddress AS CHARACTER, subject AS CHARACTER, body AS CHARACTER ):
       SUPER ().
       RUN web\api\sendmail.p (INPUT toEmailAddress,input Subject,input Body). 
    END CONSTRUCTOR.
    
    METHOD PUBLIC OVERRIDE LONGCHAR ToolDefinition():
        RETURN  '
            ~{
            "name": "send_office365_email",
            "description": "Sends an email through the corporate mail server.",
            "inputSchema": ~{
              "type": "object",
              "properties": ~{
                "to": ~{ "type": "string", "format": "email" ~},
                "subject": ~{ "type": "string" ~},
                "body": ~{ "type": "string" ~}
              ~},
              "required": ["to", "subject", "body"]
            ~}
          ~}'.
    END.

    METHOD PUBLIC OVERRIDE Progress.Json.ObjectModel.JsonObject Execute(id AS integer,  poArguments AS Progress.Json.ObjectModel.JsonObject ):
       DEFINE VARIABLE cTo AS CHARACTER NO-UNDO. 
       DEFINE VARIABLE cSubject AS CHARACTER NO-UNDO. 
       DEFINE VARIABLE cBody AS CHARACTER NO-UNDO. 
     
        ASSIGN 
            cTo      = poArguments:GetCharacter("to")
            cSubject = poArguments:GetCharacter("subject")
            cBody    = poArguments:GetCharacter("body").

       RUN web\api\sendmail.p (INPUT cTo,input cSubject,input cBody). 
       RETURN CreateMcpResponseText(id,"Email sendt",true).
    END. 

END CLASS.
