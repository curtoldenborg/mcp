 
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
     
    DEFINE PROTECTED VARIABLE RequestBodyLogFileName AS CHAR INIT 'c:\temp\mcp_master_log.txt' NO-UNDO.
    
    METHOD OVERRIDE PROTECTED INTEGER HandlePost(INPUT poRequest AS OpenEdge.Web.IWebRequest):
        DEFINE VARIABLE eMcpMethodEnum AS web.api.mcp.methodenum          NO-UNDO.     

        doLogBodyToFile(poRequest,RequestBodyLogFileName).
        eMcpMethodEnum = getMcpMethod(poRequest).  
     
        CASE eMcpMethodEnum:
            WHEN web.api.mcp.methodenum:Initialize THEN  mcp_Initialize(poRequest).
            WHEN web.api.mcp.methodenum:Notifications_Initialized THEN  mcp_notifications_initialized(poRequest).
            WHEN web.api.mcp.methodenum:Tools_List THEN  mcp_Tools_List(poRequest).
            WHEN web.api.mcp.methodenum:Tools_Call THEN  mcp_Tools_call(poRequest).
            OTHERWISE  
            UNDO, THROW NEW Progress.Lang.AppError("Not supported MCP Method!" ).
        END CASE.
        RETURN 0.
    END METHOD.
  
  
    METHOD PROTECTED web.api.mcp.methodenum getMcpMethod(INPUT poRequest AS OpenEdge.Web.IWebRequest):
        DEFINE VARIABLE cMethod   AS CHARACTER              NO-UNDO. 
        DEFINE VARIABLE eMethod   AS web.api.mcp.methodenum NO-UNDO. 
        DEFINE VARIABLE oJsonBody AS JsonObject             NO-UNDO.
       
        IF TYPE-OF(poRequest:Entity, JsonObject) THEN 
        DO:
            oJsonBody = CAST(poRequest:Entity, JsonObject).
            IF oJsonBody:Has("method") THEN 
            DO:
                cMethod = oJsonBody:GetCharacter("method").
                eMethod = web.api.mcp.methodenum:GetEnum(REPLACE(cMethod, "/", "_")) NO-ERROR.
            END. 
            ELSE  LOG-MANAGER:WRITE-MESSAGE("Missing method in body!","ERR").  
        END.     
        ELSE  LOG-MANAGER:WRITE-MESSAGE("Missing jsonobject in body!","ERR").  
        LOG-MANAGER:WRITE-MESSAGE("Request " + cMethod ,"REQ").  
        RETURN eMethod.            
    END. 
  
    METHOD PROTECTED VOID doLogBodyToFile(INPUT poRequest AS OpenEdge.Web.IWebRequest,filename AS CHARACTER):
        DEFINE VARIABLE cRawJson AS LONGCHAR NO-UNDO.
       
        cRawJson = CAST(poRequest:Entity, JsonObject):GetJsonText().
        OUTPUT TO VALUE(filename) APPEND.
        PUT UNFORMATTED  STRING(NOW) + " | " + string(cRawJson) SKIP.
        OUTPUT CLOSE.
    END. 
  
  
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
  
        DEFINE VARIABLE oRequest   AS JsonObject        NO-UNDO.
        DEFINE VARIABLE oParams    AS JsonObject        NO-UNDO.
        DEFINE VARIABLE oArguments AS JsonObject        NO-UNDO.
        
        DEFINE VARIABLE cMethod    AS CHARACTER         NO-UNDO.
        DEFINE VARIABLE cToolName  AS CHARACTER         NO-UNDO.
        DEFINE VARIABLE cClassName AS CHARACTER         NO-UNDO. 
        DEFINE VARIABLE oTool      AS web.api.mcp.tools.basetool  NO-UNDO.
        DEFINE VARIABLE oResponse AS JsonObject NO-UNDO.
   
        oRequest = CAST(poRequest:Entity, JsonObject).
        /* 1. Navigate into "params" to get tool metadata */
        oParams   = oRequest:GetJsonObject("params").
        cToolName = oParams:GetCharacter("name"). /* "toolname class" */
        cClassName = "web.api.mcp.tools." + cToolName.
   
        /* 2. Dynamically instantiate the class */
        /* This requires the class to have a default (no-arg) constructor */
        oTool = DYNAMIC-NEW cClassName().

        /* 3. Execute and get results */
        oArguments = oParams:GetJsonObject("arguments").
        oResponse  = oTool:Execute(oArguments).
        
        CATCH e AS Progress.Lang.Error:
            /* Handle class not found or execution errors */
            MESSAGE "Error loading tool: " + cClassName VIEW-AS ALERT-BOX.
        END CATCH.

/*  
        DEFINE VARIABLE oResponse AS OpenEdge.Net.HTTP.IHttpResponse NO-UNDO.
        DEFINE VARIABLE oWriter   AS OpenEdge.Web.WebResponseWriter  NO-UNDO.
        
   
        oResponse = NEW OpenEdge.Web.WebResponse().
        oResponse:StatusCode  = INTEGER(StatusCodeEnum:OK). // 200 OK
        oResponse:ContentType = "application/json":u.

        oWriter = NEW WebResponseWriter(oResponse).
        DEFINE VARIABLE resp AS LONGCHAR. 
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
*/
    END. 
  
    METHOD PROTECTED INTEGER mcp_tools_list(INPUT poRequest AS OpenEdge.Web.IWebRequest):
  
        DEFINE VARIABLE oResponse AS OpenEdge.Net.HTTP.IHttpResponse NO-UNDO.
        DEFINE VARIABLE oWriter   AS OpenEdge.Web.WebResponseWriter  NO-UNDO.
   
        oResponse = NEW OpenEdge.Web.WebResponse().
        oResponse:StatusCode  = INTEGER(StatusCodeEnum:OK). // 200 OK
        oResponse:ContentType = "application/json":u.

        oWriter = NEW WebResponseWriter(oResponse).
        
        DEFINE VARIABLE resp AS LONGCHAR. 
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

        DEFINE VARIABLE response  AS WebResponse                     NO-UNDO.
        DEFINE VARIABLE oResponse AS OpenEdge.Net.HTTP.IHttpResponse NO-UNDO.
        DEFINE VARIABLE oWriter   AS OpenEdge.Web.WebResponseWriter  NO-UNDO.
        DEFINE VARIABLE oRoot     AS JsonObject                      NO-UNDO.
        DEFINE VARIABLE oResult   AS JsonObject                      NO-UNDO.
        DEFINE VARIABLE oServInfo AS JsonObject                      NO-UNDO.

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

