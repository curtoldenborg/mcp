USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS web.api.mcp.tools.system.pasoe.restart_pasoe INHERITS web.api.mcp.tools.base.tool :

    METHOD PUBLIC OVERRIDE JsonObject Execute(id AS integer, poArguments AS JsonObject):

        DEFINE VARIABLE oResult   AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
        DEFINE VARIABLE cCmd      AS CHARACTER                             NO-UNDO.
        DEFINE VARIABLE cInstance AS CHARACTER                             NO-UNDO.

        IF poArguments:Has("instance") THEN
            cInstance = poArguments:GetCharacter("instance").

        IF cInstance = "" OR cInstance = ? THEN
            cInstance = "oepas1".

        oResult = NEW Progress.Json.ObjectModel.JsonObject().
        oResult:Add("instance", cInstance).

        cCmd = "C:\progress\OE128_64_WRK\"+ cInstance + "\bin\tcman.bat stop " + cInstance.
        OS-COMMAND SILENT VALUE(cCmd).

        IF OS-ERROR = 0 THEN
        DO:
            cCmd = "C:\progress\OE128_64_WRK\" + cInstance + "\bin\tcman.bat start " + cInstance.
            OS-COMMAND SILENT VALUE(cCmd).

            IF OS-ERROR = 0 THEN
            DO:
                oResult:Add("status",  "ok").
                oResult:Add("message", "PASOE instance " + cInstance + " restarted successfully").
            END.
            ELSE
            DO:
                oResult:Add("status",  "error").
                oResult:Add("message", "Stop succeeded but start failed with OS-ERROR " + STRING(OS-ERROR)).
            END.
        END.
        ELSE
        DO:
            oResult:Add("status",  "error").
            oResult:Add("message", "Stop failed with OS-ERROR " + STRING(OS-ERROR)).
        END.

        RETURN CreateMcpResponseJson(id, oResult, false).
    END.

END CLASS.
