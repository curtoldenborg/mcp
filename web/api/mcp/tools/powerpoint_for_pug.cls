/*------------------------------------------------------------------------
  File        : powerpoint_for_pug
----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS web.api.mcp.tools.powerpoint_for_pug INHERITS web.api.mcp.tools.base.tool : 
    
    CONSTRUCTOR PUBLIC powerpoint_for_pug ( ):
        SUPER ().
    END CONSTRUCTOR.
    
    METHOD PUBLIC OVERRIDE LONGCHAR ToolDefinition():
        RETURN  '
           ~{
        "name": "powerpoint_for_pug",
        "description": "powerpoint presentation for pug (progress user group) meeting 2026, the best there is about ai and telerik components",
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

    METHOD PUBLIC OVERRIDE Progress.Json.ObjectModel.JsonObject Execute(id AS integer, poArguments AS Progress.Json.ObjectModel.JsonObject):
    
        DEFINE VARIABLE oResult      AS Progress.Json.ObjectModel.JsonObject NO-UNDO. 
        DEFINE VARIABLE oContentArr  AS Progress.Json.ObjectModel.JsonArray  NO-UNDO.
        DEFINE VARIABLE oTextObj     AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
        DEFINE VARIABLE oResourceObj AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
        DEFINE VARIABLE oResourceDet AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
    
        /* 1. Initialize the main result object */
        oResult = NEW JsonObject().
        oContentArr = NEW JsonArray().

        /* 2. Add the status message (the "text" part) */
        oTextObj = NEW JsonObject().
        oTextObj:Add("type", "text").
        oTextObj:Add("text", "Email sent to curt@proventus.no. The presentation is also available for download below.").
        oContentArr:Add(oTextObj).

        /* 3. Create the "resource" part with the download link */
        oResourceObj = NEW JsonObject().
        oResourceDet = NEW JsonObject().
    
        /* In a real app, replace localhost with your actual PASOE server name/IP */
        oResourceDet:Add("uri", "http://10.2.0.202:8810/web/filedownload?file=Brukerforeningen_2026.pptx").
        oResourceDet:Add("mimeType", "application/vnd.openxmlformats-officedocument.presentationml.presentation").
        oResourceDet:Add("text", "Brukerforeningen_2026.pptx").

        oResourceObj:Add("type", "resource").
        oResourceObj:Add("resource", oResourceDet).
        oContentArr:Add(oResourceObj).

        /* 4. Assign the array to the result object */
        oResult:Add("content", oContentArr).
    
        /* 5. Return using your existing MCP helper */
        RETURN CreateMcpResponseJson(id, oResult, FALSE).
   
    END METHOD.
 END. 

