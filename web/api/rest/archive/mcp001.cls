 
 /*------------------------------------------------------------------------
    File        : databaseschema
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : colde
    Created     : Sat Mar 15 14:11:49 CET 2025
    Notes       : 
  ----------------------------------------------------------------------*/


USING Progress.Json.ObjectModel.*.
USING Progress.Lang.*.
USING OpenEdge.Net.*.
USING OpenEdge.Net.HTTP.*.
USING OpenEdge.Web.*.


BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS web.api.rest.mcp INHERITS OpenEdge.Web.WebHandler: 

   
    METHOD OVERRIDE PROTECTED INTEGER HandlePost(INPUT poRequest AS OpenEdge.Web.IWebRequest):
        DEFINE VARIABLE response       AS WebResponse                NO-UNDO.
        DEFINE VARIABLE oResponse AS OpenEdge.Net.HTTP.IHttpResponse NO-UNDO.
        DEFINE VARIABLE oWriter   AS OpenEdge.Web.WebResponseWriter  NO-UNDO.
        DEFINE VARIABLE oJsonBody AS JsonObject NO-UNDO.
        DEFINE VARIABLE oRoot     AS JsonObject         NO-UNDO.
        DEFINE VARIABLE oResult   AS JsonObject         NO-UNDO.
        DEFINE VARIABLE oServInfo AS JsonObject         NO-UNDO.
        DEFINE VARIABLE cRawJson AS LONGCHAR NO-UNDO.
        define variable cMethod as char no-undo.     
     
       log-manager:write-message("HandlePost-mcp","REQ").
    
        /* 1. Extract the JSON from the request entity */
        IF TYPE-OF(poRequest:Entity, JsonObject) THEN DO:
            oJsonBody = CAST(poRequest:Entity, JsonObject).
             IF oJsonBody:Has("method") THEN 
            cMethod = oJsonBody:GetCharacter("method").
        ELSE 
            cMethod = "UNKNOWN-METHOD".
          
          log-manager:write-message("Request " + cMethod ,"REQ").  
            
            /* 2. Write it to a file on the server disk */
            /* Params: Target Path, Formatted (Logical), Encoding */
/*            oJsonBody:WriteFile("c:\temp\mcp_request_log.json", TRUE, "UTF-8").
            DEFINE VARIABLE cTimestamp AS CHARACTER NO-UNDO.
            cTimestamp = REPLACE(ISO-DATE(NOW), ":", "-"). 
            oJsonBody:WriteFile(SUBSTITUTE("c:\temp\mcp_req_&1.json", cTimestamp), TRUE, "UTF-8").
  */          
             /* 1. Convert JsonObject to a single-line string */
            cRawJson = CAST(poRequest:Entity, JsonObject):GetJsonText().
        
            /* 2. Append to file with a timestamp and newline */
            OUTPUT TO "c:\temp\mcp_master_log.txt" APPEND.
                put unformatted  
                    STRING(NOW) + " | " + string(cRawJson) skip.
            OUTPUT CLOSE.
            
            
        END.
      
        if cMethod = "initialize"  then mcp_Initialize(poRequest).
        if cMethod = "notifications/initialized"  then mcp_notifications_initialized(poRequest).
        if cMethod = "tools/list"  then mcp_Tools_List(poRequest).
        if cMethod = "tools/call"  then mcp_Tools_call(poRequest).
        
    
        RETURN 0.
       
    END METHOD.
  
   METHOD PROTECTED INTEGER mcp_notifications_initialized(INPUT poRequest AS OpenEdge.Web.IWebRequest):
        DEFINE VARIABLE oResponse AS OpenEdge.Net.HTTP.IHttpResponse NO-UNDO.
        DEFINE VARIABLE oWriter   AS OpenEdge.Web.WebResponseWriter  NO-UNDO.
   
        oResponse = NEW WebResponse().
        oResponse:StatusCode  = INTEGER(StatusCodeEnum:OK). // 200 OK
        oResponse:ContentType = "application/json":u.
        oWriter = NEW WebResponseWriter(oResponse).
        oWriter:Open().
        oWriter:Close().
    END. 
    
    METHOD PROTECTED INTEGER mcp_tools_call(INPUT poRequest AS OpenEdge.Web.IWebRequest):
  
        DEFINE VARIABLE oResponse AS OpenEdge.Net.HTTP.IHttpResponse NO-UNDO.
        DEFINE VARIABLE oWriter   AS OpenEdge.Web.WebResponseWriter  NO-UNDO.
        
   
        oResponse = NEW OpenEdge.Web.WebResponse().
        oResponse:StatusCode  = INTEGER(StatusCodeEnum:OK). // 200 OK
        oResponse:ContentType = "application/json":u.

        oWriter = NEW WebResponseWriter(oResponse).
def var resp as longchar. 
resp = '
        
~{
  "jsonrpc": "2.0",
  "id": 2,
  "result": ~{
    "content": [
      ~{
        "type": "text",
        "text": "email sendt"
      ~}
    ],
    "isError": false
  ~}
~}'.

        oWriter:Write(resp).
        oWriter:Open().
        oWriter:Close().

    END. 
  
    METHOD PROTECTED INTEGER mcp_tools_list(INPUT poRequest AS OpenEdge.Web.IWebRequest):
  
        DEFINE VARIABLE oResponse AS OpenEdge.Net.HTTP.IHttpResponse NO-UNDO.
        DEFINE VARIABLE oWriter   AS OpenEdge.Web.WebResponseWriter  NO-UNDO.
   
        oResponse = NEW OpenEdge.Web.WebResponse().
        oResponse:StatusCode  = INTEGER(StatusCodeEnum:OK). // 200 OK
        oResponse:ContentType = "application/json":u.

        oWriter = NEW WebResponseWriter(oResponse).
        
def var resp as longchar. 
resp = '
 ~{
  "jsonrpc": "2.0",
  "id": 1,
  "result": ~{
    "tools": [
      ~{
        "name": "read_progress_db",
        "description": "Queries the OpenEdge database using a standard ABL WHERE clause.",
        "inputSchema": ~{
          "type": "object",
          "properties": ~{
            "tableName": ~{ "type": "string", "description": "The table name (e.g., Customer)" ~},
            "whereClause": ~{ "type": "string", "description": "The ABL filter (e.g., CustNum < 50)" ~}
          ~},
          "required": ["tableName", "whereClause"]
        ~}
      ~},
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
      ~}
    ]
  ~}
~}'.
        oWriter:Write(resp).
        oWriter:Open().
        oWriter:Close().
   
    END. 
    
    METHOD PROTECTED INTEGER mcp_initialize(INPUT poRequest AS OpenEdge.Web.IWebRequest):

        DEFINE VARIABLE response  AS WebResponse                NO-UNDO.
        DEFINE VARIABLE oResponse AS OpenEdge.Net.HTTP.IHttpResponse NO-UNDO.
        DEFINE VARIABLE oWriter   AS OpenEdge.Web.WebResponseWriter  NO-UNDO.
        DEFINE VARIABLE oRoot     AS JsonObject         NO-UNDO.
        DEFINE VARIABLE oResult   AS JsonObject         NO-UNDO.
        DEFINE VARIABLE oServInfo AS JsonObject         NO-UNDO.

        /* 1. Build the nested JSON hierarchy */
        oRoot     = NEW JsonObject().
        oResult   = NEW JsonObject().
        oServInfo = NEW JsonObject().

        oServInfo:Add("name", "my-pasoe-mcp-server").
        oServInfo:Add("version", "1.0.0").

        /* Add capabilities as empty objects as per your sample */
        oResult:Add("protocolVersion", "2025-11-25").
        oResult:Add("capabilities",    NEW JsonObject()).
        oResult:GetJsonObject("capabilities"):Add("tools",     NEW JsonObject()).
        oResult:GetJsonObject("capabilities"):Add("resources", NEW JsonObject()).
        oResult:GetJsonObject("capabilities"):Add("logging",   NEW JsonObject()).
        oResult:Add("serverInfo",      oServInfo).

        oRoot:Add("jsonrpc", "2.0").
        oRoot:Add("id", 0).
        oRoot:Add("result", oResult).

        oRoot:WriteFile("c:\temp\mcp_response_sent.json", TRUE, "UTF-8").
        
        /* 2. Prepare the HTTP Response */
        oResponse = NEW WebResponse().
        oResponse:StatusCode  = INTEGER(StatusCodeEnum:OK). // 200 OK
        oResponse:ContentType = "application/json":u.
        oResponse:Entity      = oRoot.

        /* 3. Write and Close the response stream */
        oWriter = NEW WebResponseWriter(oResponse).
        oWriter:Open().
        oWriter:Close().
    
    END. 
         
    METHOD OVERRIDE PROTECTED INTEGER HandleGet(INPUT poRequest AS OpenEdge.Web.IWebRequest):
        LOG-MANAGER:WRITE-MESSAGE("Method=" + quoter(poRequest:Method),"REQUEST").
        UNDO, THROW NEW Progress.Lang.AppError("METHOD NOT IMPLEMENTED").
    END. 
    
    /* PUT - save */
    METHOD OVERRIDE PROTECTED INTEGER HandlePut(INPUT poRequest AS OpenEdge.Web.IWebRequest):
        LOG-MANAGER:WRITE-MESSAGE("Method=" + quoter(poRequest:Method),"REQUEST").
        UNDO, THROW NEW Progress.Lang.AppError("METHOD NOT IMPLEMENTED").
    END. 
    METHOD OVERRIDE PROTECTED INTEGER HandleNotAllowedMethod( INPUT poRequest AS OpenEdge.Web.IWebRequest ):
        UNDO, THROW NEW Progress.Lang.AppError("METHOD NOT IMPLEMENTED").
    END METHOD.

    METHOD OVERRIDE PROTECTED INTEGER HandleNotImplemented( INPUT poRequest AS OpenEdge.Web.IWebRequest ):
        UNDO, THROW NEW Progress.Lang.AppError("METHOD NOT IMPLEMENTED").
    END METHOD.    
    
END CLASS.

