
        USING Progress.Json.ObjectModel.*.
      
        DEFINE VARIABLE oRoot        AS JsonObject                      NO-UNDO.
        DEFINE VARIABLE oResult      AS JsonObject                      NO-UNDO.
        DEFINE VARIABLE oToolsArray  AS jsonArray NO-UNDO. 
        DEFINE VARIABLE lcJson AS LONGCHAR NO-UNDO.      
       
        DEFINE VARIABLE oTools AS web.api.mcp.tools NO-UNDO. 
        oTools = NEW web.api.mcp.tools().
       
        oRoot     = NEW JsonObject().
        oResult   = NEW JsonObject().
        oToolsArray = oTools:getRegisteredtools(). 
        oResult:Add("tools",oToolsArray).
        oRoot:Add("jsonrpc", "2.0").
        oRoot:Add("id", 1).
        oRoot:Add("result", oResult).
        oRoot:WRITE(lcJson, TRUE, "UTF-8").
        


MESSAGE STRING(lcJSON) VIEW-AS ALERT-BOX.
    
    
