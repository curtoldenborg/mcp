
        USING Progress.Json.ObjectModel.*.
      
        DEFINE VARIABLE oWriter    AS OpenEdge.Web.WebResponseWriter  NO-UNDO.
        DEFINE VARIABLE oRoot      AS JsonObject                      NO-UNDO.
        DEFINE VARIABLE oResult    AS JsonObject                      NO-UNDO.
        DEFINE VARIABLE oServInfo  AS JsonObject                      NO-UNDO.
        DEFINE VARIABLE oRequest   AS JsonObject                      NO-UNDO.
        DEFINE VARIABLE oToolsArray     AS jsonArray NO-UNDO. 
        DEFINE VARIABLE lcJson AS LONGCHAR NO-UNDO.      
       
        DEFINE VARIABLE oTools AS web.api.mcp.tools NO-UNDO. 
        oTools = NEW web.api.mcp.tools().
       
        oRoot     = NEW JsonObject().
        oResult   = NEW JsonObject().
        oToolsArray = oTools:getRegisteredtools(). 
        oResult:Add("tools",oToolsArray).
     
      //  oResult:GetJsonObject("tools"):Add("toolsa", NEW JsonObject()).
        
         // oResult:GetJsonObject("tools"):Add(oToolsArray).
        
       // MESSAGE string(oTools:getRegisteredtools()) VIEW-AS ALERT-BOX. 
        
        oRoot:Add("jsonrpc", "2.0").
        oRoot:Add("id", 1).
        oRoot:Add("result", oResult).
  
        oRoot:WRITE(lcJson, TRUE, "UTF-8").
        


MESSAGE STRING(lcJSON) VIEW-AS ALERT-BOX.
    
    
