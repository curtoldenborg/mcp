USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS web.api.mcp.tools.execute_tool INHERITS web.api.mcp.tools.base.tool :

    
    METHOD PUBLIC OVERRIDE JsonObject Execute(id AS integer, poArguments AS JsonObject):

        DEFINE VARIABLE cToolName  AS CHARACTER                              NO-UNDO.
        DEFINE VARIABLE cArgs      AS CHARACTER                              NO-UNDO.
        DEFINE VARIABLE cClassName AS CHARACTER                              NO-UNDO.
        DEFINE VARIABLE oTool      AS web.api.mcp.tools.base.tool            NO-UNDO.
        DEFINE VARIABLE oArguments AS Progress.Json.ObjectModel.JsonObject   NO-UNDO.
        DEFINE VARIABLE oParser    AS Progress.Json.ObjectModel.ObjectModelParser NO-UNDO.
        DEFINE VARIABLE oResult    AS Progress.Json.ObjectModel.JsonObject   NO-UNDO.
        
        cToolName  = poArguments:GetCharacter("toolName").
        cArgs      = poArguments:GetCharacter("arguments") NO-ERROR.
        cClassName = "web.api.mcp.tools.automagic." + cToolName.
        
        IF cArgs = "" OR cArgs = ? THEN cArgs = "~{~}".
        
        oParser    = NEW Progress.Json.ObjectModel.ObjectModelParser().
        oArguments = CAST(oParser:Parse(cArgs), Progress.Json.ObjectModel.JsonObject).
        oTool      = CAST(Progress.Lang.Class:GetClass(cClassName):New(), web.api.mcp.tools.base.tool).
        oResult    = oTool:Execute(id, oArguments).
        
        RETURN oResult.
    END.

END CLASS.
