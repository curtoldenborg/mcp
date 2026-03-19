USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS web.api.mcp.tools.system.write_file INHERITS web.api.mcp.tools.base.tool :

    METHOD PUBLIC OVERRIDE JsonObject Execute(id AS integer, poArguments AS JsonObject):

        DEFINE VARIABLE cPath    AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cContent AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE oResult  AS Progress.Json.ObjectModel.JsonObject NO-UNDO.

        cPath    = poArguments:GetCharacter("path").
        cContent = poArguments:GetCharacter("content").

        OUTPUT TO VALUE(cPath).
        PUT UNFORMATTED cContent.
        OUTPUT CLOSE.

        oResult = NEW Progress.Json.ObjectModel.JsonObject().
        oResult:Add("status",   IF OS-ERROR = 0 THEN "success" ELSE "error").
        oResult:Add("path",     cPath).
        oResult:Add("os_error", OS-ERROR).
        RETURN CreateMcpResponseJson(id, oResult, false).

    END.

END CLASS.
