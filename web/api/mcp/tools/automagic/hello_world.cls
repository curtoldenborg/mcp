USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS web.api.mcp.tools.automagic.hello_world INHERITS web.api.mcp.tools.base.tool :

    METHOD PUBLIC OVERRIDE JsonObject Execute(id AS integer, poArguments AS JsonObject):
DEFINE VARIABLE oResult AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
oResult = NEW Progress.Json.ObjectModel.JsonObject().
oResult:Add("message", "Hello World! Tool creation is working.").
oResult:Add("status", "ok").
RETURN CreateMcpResponseJson(id, oResult, false).

    END.

END CLASS.
