
USING Progress.Json.ObjectModel.*.
USING Progress.Lang.*.
USING OpenEdge.Net.*.
USING OpenEdge.Net.HTTP.*.
USING OpenEdge.Web.*.


BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS web.api.rest.mcphandler INHERITS OpenEdge.Web.WebHandler: 
     
    DEFINE PROTECTED VARIABLE uid AS CHAR NO-UNDO. 
  

    CONSTRUCTOR PUBLIC mcphandler (  ):
        SUPER ().
        uid = REPLACE(GUID(GENERATE-UUID),'-','').
    END CONSTRUCTOR.
  
    
    METHOD OVERRIDE PROTECTED INTEGER HandlePost(INPUT poRequest AS OpenEdge.Web.IWebRequest):
        DEFINE VARIABLE eMcpMethodEnum AS web.api.mcp.methodenum NO-UNDO.     

        doLogBodyToFile(CAST(poRequest:Entity, JsonObject),'Request').
        eMcpMethodEnum = getMcpMethod(poRequest).  
     
        CASE eMcpMethodEnum:
            WHEN web.api.mcp.methodenum:Initialize                THEN  mcp_Initialize(poRequest).
            WHEN web.api.mcp.methodenum:Notifications_Initialized THEN  mcp_notifications_initialized(poRequest).
            WHEN web.api.mcp.methodenum:Notifications_Cancelled   THEN  mcp_notifications_Cancelled  (poRequest).
            WHEN web.api.mcp.methodenum:Tools_List                THEN  mcp_Tools_List(poRequest).
            WHEN web.api.mcp.methodenum:Tools_Call                THEN  mcp_Tools_call(poRequest).
            WHEN web.api.mcp.methodenum:Resources_List            THEN  mcp_Resources_List(poRequest).
            
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
  
    METHOD PROTECTED VOID doLogBodyToFile(INPUT oRequestJson AS jsonobject,direction AS CHARACTER):
        DEFINE VARIABLE cRawJson AS LONGCHAR NO-UNDO.
        DEFINE VARIABLE cFIle AS CHAR NO-UNDO. 
              
        //cRawJson = oRequestJson:GetJsonText(). // unformatted 
        oRequestJson:Write(cRawJson, TRUE).      // formatted 
        
        cFile   = system.config:projectpath  + 'log\' + uid +  '_' +  direction + '.json'.
        COPY-LOB FROM cRawJson TO FILE cFile NO-CONVERT.       
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

    METHOD PROTECTED INTEGER mcp_Resources_List(INPUT poRequest AS OpenEdge.Web.IWebRequest):
        DEFINE VARIABLE oResponse AS OpenEdge.Net.HTTP.IHttpResponse NO-UNDO.
        DEFINE VARIABLE oWriter   AS OpenEdge.Web.WebResponseWriter  NO-UNDO.
   
        oResponse = NEW WebResponse().
        oResponse:StatusCode  = INTEGER(StatusCodeEnum:OK). // 200 OK
        oResponse:ContentType = "application/json":u.
        oWriter = NEW WebResponseWriter(oResponse).
        oWriter:Open().
        oWriter:Close().
    END. 

    METHOD PROTECTED INTEGER mcp_notifications_Cancelled(INPUT poRequest AS OpenEdge.Web.IWebRequest):
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
        DEFINE VARIABLE oRequest      AS JsonObject                      NO-UNDO.
        DEFINE VARIABLE oParams       AS JsonObject                      NO-UNDO.
        DEFINE VARIABLE oArguments    AS JsonObject                      NO-UNDO.
        DEFINE VARIABLE cMethod       AS CHARACTER                       NO-UNDO.
        DEFINE VARIABLE cToolName     AS CHARACTER                       NO-UNDO.
        DEFINE VARIABLE cClassName    AS CHARACTER                       NO-UNDO. 
        DEFINE VARIABLE oTool         AS web.api.mcp.tools.base.tool     NO-UNDO.
        DEFINE VARIABLE oJsonResponse AS JsonObject                      NO-UNDO.
        DEFINE VARIABLE oResponse     AS OpenEdge.Net.HTTP.IHttpResponse NO-UNDO.
        DEFINE VARIABLE oWriter       AS OpenEdge.Web.WebResponseWriter  NO-UNDO.
        DEFINE VARIABLE iRequestId    AS INTEGER                         NO-UNDO.
       
        oRequest = CAST(poRequest:Entity, JsonObject).
         
        IF oRequest:Has("id") THEN iRequestId = oRequest:GetInteger("id").
        
        /* 1. Navigate into "params" to get tool metadata */
        oParams   = oRequest:GetJsonObject("params").
        cToolName = oParams:GetCharacter("name"). /* "toolname class" */
        cClassName = web.api.mcp.tools:GetToolClassName(cToolname).
   
        LOG-MANAGER:WRITE-MESSAGE("Exec tool:" + cToolname + " id:" + STRING(iRequestId)).
  
        oResponse = NEW OpenEdge.Web.WebResponse().
        oResponse:StatusCode  = INTEGER(StatusCodeEnum:OK). // 200 OK
        oResponse:ContentType = "application/json":u.
     
        /* 2. Dynamically instantiate the class */
        /* This requires the class to have a default (no-arg) constructor */
        oTool = DYNAMIC-NEW cClassName().

        /* 3. Execute and get results */
  
        oArguments = oParams:GetJsonObject("arguments") no-error.
        oJsonResponse  = oTool:Execute(iRequestId,oArguments).
        
        oResponse:Entity = oJsonResponse.
        
        doLogBodyToFile(oJsonResponse,'Response').
        
        oWriter = NEW WebResponseWriter(oResponse).
        oWriter:Open().
        oWriter:Close().
        
        
        CATCH e AS Progress.Lang.Error:
            DEFINE VARIABLE iLoop AS INTEGER NO-UNDO.
            DEFINE VARIABLE cFullErr AS CHARACTER NO-UNDO.
        
           /* 1. Build a detailed error string: "Error 75: Record not found | Error 123: ..." */
            DO iLoop = 1 TO e:NumMessages:
                cFullErr = cFullErr 
                         + (IF cFullErr > "" THEN " | " ELSE "") 
                         + "Error " + STRING(e:GetMessageNum(iLoop)) + ": " 
                         + e:GetMessage(iLoop).
            END.
        
            /* 2. Log it specifically for server-side debugging */
            LOG-MANAGER:WRITE-MESSAGE(SUBSTITUTE("MCP Tool Failure [&1]: &2", cClassName, cFullErr), "ERR").

            oJsonResponse = web.api.mcp.tools.base.tool:CreateMcpResponseTextIsError(iRequestid,cFullErr).
            oResponse:Entity = oJsonResponse.
            oWriter = NEW WebResponseWriter(oResponse).
            oWriter:Open().
            oWriter:Close().
            LOG-MANAGER:WRITE-MESSAGE("Error - sendt", "ERR").
                    
        END CATCH.
        
    END. 

    METHOD PROTECTED INTEGER mcp_tools_list(INPUT poRequest AS OpenEdge.Web.IWebRequest):
        DEFINE VARIABLE oResponse   AS OpenEdge.Net.HTTP.IHttpResponse NO-UNDO.
        DEFINE VARIABLE oWriter     AS OpenEdge.Web.WebResponseWriter  NO-UNDO.
        DEFINE VARIABLE oTools      AS web.api.mcp.tools               NO-UNDO. 
        DEFINE VARIABLE oRoot       AS JsonObject                      NO-UNDO.
        DEFINE VARIABLE oResult     AS JsonObject                      NO-UNDO.
        DEFINE VARIABLE oToolsArray AS jsonArray                       NO-UNDO. 
     
        oResponse = NEW OpenEdge.Web.WebResponse().
        oResponse:StatusCode  = INTEGER(StatusCodeEnum:OK). // 200 OK
        oResponse:ContentType = "application/json":u.

        oWriter = NEW WebResponseWriter(oResponse).
  
        oTools    = NEW web.api.mcp.tools().
        oRoot     = NEW JsonObject().
        oRoot:Add("jsonrpc", "2.0").
        oRoot:Add("id", 1).
  
        oResult   = NEW JsonObject().
        oToolsArray = oTools:getRegisteredtools(). 
        oResult:Add("tools",oToolsArray).
        oRoot:Add("result", oResult).
         
        oResponse:Entity = oRoot.
        LOG-MANAGER:WRITE-MESSAGE('mcp_tools_list:Complete','LOG').
        doLogBodyToFile(oRoot,'Response').
    
        oWriter = NEW WebResponseWriter(oResponse).
        oWriter:Open().
        oWriter:Close().
        
        FINALLY:
            delete object oResult. 
            DELETE OBJECT owriter. 
            delete object oRoot. 
            delete object oTools. 
            delete object oResponse.    
        END FINALLY.
        
    END. 

    
    METHOD PROTECTED INTEGER mcp_initialize(INPUT poRequest AS OpenEdge.Web.IWebRequest):
        DEFINE VARIABLE response   AS WebResponse                     NO-UNDO.
        DEFINE VARIABLE oResponse  AS OpenEdge.Net.HTTP.IHttpResponse NO-UNDO.
        DEFINE VARIABLE oWriter    AS OpenEdge.Web.WebResponseWriter  NO-UNDO.
        DEFINE VARIABLE oRoot      AS JsonObject                      NO-UNDO.
        DEFINE VARIABLE oResult    AS JsonObject                      NO-UNDO.
        DEFINE VARIABLE oServInfo  AS JsonObject                      NO-UNDO.
        DEFINE VARIABLE oRequest   AS JsonObject                      NO-UNDO.
        DEFINE VARIABLE iRequestId AS INTEGER                         INIT 0 NO-UNDO.
       
        oRequest = CAST(poRequest:Entity, JsonObject).
        IF oRequest:Has("id") THEN iRequestId = oRequest:GetInteger("id").

        /* 1. Build the nested JSON hierarchy */
        oRoot     = NEW JsonObject().
        oResult   = NEW JsonObject().
        oServInfo = NEW JsonObject().

        oServInfo:Add("name", "Sports2000_database").
        oServInfo:Add("version", "1.0.0").

        /* Add capabilities as empty objects as per your sample */
        oResult:Add("protocolVersion", "2025-11-25").
        oResult:Add("capabilities",    NEW JsonObject()).
        oResult:GetJsonObject("capabilities"):Add("tools",     NEW JsonObject()).
        oResult:GetJsonObject("capabilities"):Add("resources", NEW JsonObject()).
        oResult:GetJsonObject("capabilities"):Add("logging",   NEW JsonObject()).
        oResult:Add("serverInfo",      oServInfo).

        oRoot:Add("jsonrpc", "2.0").
        oRoot:Add("id", iRequestId).
        oRoot:Add("result", oResult).

        //oRoot:WriteFile("c:\temp\mcp_response_sent.json", TRUE, "UTF-8").
        
        /* 2. Prepare the HTTP Response */
        oResponse = NEW WebResponse().
        oResponse:StatusCode  = INTEGER(StatusCodeEnum:OK). // 200 OK
        oResponse:ContentType = "application/json":u.
        oResponse:Entity      = oRoot.
        
        LOG-MANAGER:WRITE-MESSAGE('mcp_initialize:Complete','LOG').
        doLogBodyToFile(oRoot,'Response').
         
        /* 3. Write and Close the response stream */
        oWriter = NEW WebResponseWriter(oResponse).
        oWriter:Open().
        oWriter:Close().
       
        FINALLY:
            DELETE OBJECT oResponse NO-ERROR.
            DELETE OBJECT oWriter NO-ERROR. 
            DELETE OBJECT oRoot NO-ERROR.     
        END FINALLY.
    END. 
      
    METHOD OVERRIDE PROTECTED INTEGER HandleGet(INPUT poRequest AS OpenEdge.Web.IWebRequest):
        LOG-MANAGER:WRITE-MESSAGE("Method=" + quoter(poRequest:Method),"REQUEST").
        DEFINE VARIABLE oResponse AS OpenEdge.Net.HTTP.IHttpResponse NO-UNDO.
        DEFINE VARIABLE oWriter   AS OpenEdge.Web.WebResponseWriter  NO-UNDO.
        DEFINE VARIABLE oRoot     AS JsonObject                      NO-UNDO.

        oRoot     = NEW JsonObject().
        oRoot:Add("status", "mcp-endpoint").
      
        IF poRequest:Method = "GET" THEN 
        DO:
            oResponse = NEW WebResponse().
            oResponse:StatusCode  = INTEGER(StatusCodeEnum:OK). // 200 OK
            oResponse:ContentType = "application/json":u.
            oResponse:Entity = oRoot.
            oWriter = NEW WebResponseWriter(oResponse).
            oWriter:Open().
            oWriter:Close().
        END. 
        
        RETURN 0.
        
        FINALLY:
            DELETE OBJECT oResponse NO-ERROR.
            DELETE OBJECT oWriter NO-ERROR. 
            DELETE OBJECT oRoot NO-ERROR.     
        END FINALLY.
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

