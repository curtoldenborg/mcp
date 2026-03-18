USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS web.api.mcp.tools.automagic.test_tool_creation INHERITS web.api.mcp.tools.base.tool :

    METHOD PUBLIC OVERRIDE JsonObject Execute(id AS integer, poArguments AS JsonObject):

        DEFINE VARIABLE oResult AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
        oResult = NEW Progress.Json.ObjectModel.JsonObject().
        oResult:Add("status", "ok").
        oResult:Add("message", "test tool works").
        RETURN CreateMcpResponseJson(id, oResult, false).

    END.

END CLASS.
