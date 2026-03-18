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

/*

DEFINE VARIABLE oRoot        AS JsonObject NO-UNDO.
DEFINE VARIABLE oContentArr  AS JsonArray  NO-UNDO.
DEFINE VARIABLE oTextObj     AS JsonObject NO-UNDO.
DEFINE VARIABLE oResourceObj AS JsonObject NO-UNDO.
DEFINE VARIABLE oResourceDet AS JsonObject NO-UNDO.
DEFINE VARIABLE lcJson       AS LONGCHAR   NO-UNDO.

/* 1. Create the root object and the 'content' array */
oRoot       = NEW JsonObject().
oContentArr = NEW JsonArray().

/* 2. Build the first 'text' element */
oTextObj = NEW JsonObject().
oTextObj:Add("type", "text").
oTextObj:Add("text", "The report has been generated successfully.").
oContentArr:Add(oTextObj).

/* 3. Build the 'resource' element nested structure */
oResourceObj = NEW JsonObject().
oResourceDet = NEW JsonObject().

oResourceDet:Add("uri", "https://your-server/web/download?id=123").
oResourceDet:Add("mimeType", "application/pdf").
oResourceDet:Add("text", "Download Full Report").

oResourceObj:Add("type", "resource").
oResourceObj:Add("resource", oResourceDet).
oContentArr:Add(oResourceObj).

/* 4. Add the array to the root */
oRoot:Add("content", oContentArr).

/* 5. Export to a string for the MCP Response */
oRoot:Write(lcJson, TRUE). /* TRUE for 'pretty print' formatting */

/* For debugging or returning to the MCP Server agent */
MESSAGE STRING(lcJson) VIEW-AS ALERT-BOX.

/* Cleanup */
DELETE OBJECT oRoot.


    METHOD PUBLIC OVERRIDE Progress.Json.ObjectModel.JsonObject Execute(id AS integer,  poArguments AS Progress.Json.ObjectModel.JsonObject ):
        DEFINE VARIABLE lcPowerPoint AS LONGCHAR NO-UNDO. 
        DEFINE VARIABLE oResult AS Progress.Json.ObjectModel.JsonObject NO-UNDO. 
        DEFINE VARIABLE cBase64 AS LONGCHAR NO-UNDO.
        DEFINE VARIABLE mPtr AS MEMPTR NO-UNDO. 
                
        oResult   = NEW Progress.Json.ObjectModel.JsonObject().

        COPY-LOB FROM FILE "C:\projects\pasoem8m\m8m\resources\documents\Brukerforeningen_2026.pptx" TO mPtr.
        cBase64 = BASE64-ENCODE(mPtr).
        SET-SIZE(mPtr) = 0.

        //oResult:Add("Powerpoint_base64",   cBase64).
        oResult:Add("message","Email sent to curt@proventus.no").
        
            
        RETURN CreateMcpResponseJson(id, oResult, false).
       
    END. 

END CLASS.
*/