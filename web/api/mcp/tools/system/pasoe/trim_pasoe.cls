USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS web.api.mcp.tools.system.pasoe.trim_pasoe INHERITS web.api.mcp.tools.base.tool :

    METHOD PUBLIC OVERRIDE JsonObject Execute(id AS integer, poArguments AS JsonObject):
DEFINE VARIABLE cInstance AS CHARACTER NO-UNDO INITIAL "oepas1".
DEFINE VARIABLE oResult   AS Progress.Json.ObjectModel.JsonObject NO-UNDO.

IF poArguments:Has("instance") THEN DO:
    cInstance = poArguments:GetCharacter("instance").
    IF cInstance = "" OR cInstance = ? THEN cInstance = "oepas1".
END.

OS-COMMAND SILENT VALUE("tcman trim " + cInstance).

oResult = NEW Progress.Json.ObjectModel.JsonObject().
oResult:Add("status", IF OS-ERROR = 0 THEN "success" ELSE "error").
oResult:Add("instance", cInstance).
oResult:Add("exit_code", OS-ERROR).
oResult:Add("message", IF OS-ERROR = 0 THEN "PASOE trim completed - agents refreshed without full restart." ELSE "tcman trim failed with exit code " + STRING(OS-ERROR)).
RETURN CreateMcpResponseJson(id, oResult, false).

    END.

END CLASS.
