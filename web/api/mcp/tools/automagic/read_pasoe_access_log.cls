USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS web.api.mcp.tools.automagic.read_pasoe_access_log INHERITS web.api.mcp.tools.base.tool :

    METHOD PUBLIC OVERRIDE JsonObject Execute(id AS integer, poArguments AS JsonObject):

        DEFINE VARIABLE cLogDate    AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cLogPath    AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cLine       AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE i200Count   AS INTEGER                              NO-UNDO.
        DEFINE VARIABLE iTotalLines AS INTEGER                              NO-UNDO.
        DEFINE VARIABLE oResult     AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
        DEFINE VARIABLE oLines      AS Progress.Json.ObjectModel.JsonArray  NO-UNDO.
        DEFINE VARIABLE dToday      AS DATE                                 NO-UNDO.
        DEFINE VARIABLE cMonth      AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cDay        AS CHARACTER                            NO-UNDO.

        /* Resolve date - default to today */
        IF poArguments:Has("log_date") THEN
            cLogDate = poArguments:GetCharacter("log_date").

        IF cLogDate = "" OR cLogDate = ? THEN 
        DO:
            dToday = TODAY.
            cMonth = STRING(MONTH(dToday), "99").
            cDay   = STRING(DAY(dToday),   "99").
            ASSIGN 
                cMonth = REPLACE(cMonth, " ", "0")
                cDay   = REPLACE(cDay,   " ", "0").
            cLogDate = STRING(YEAR(dToday)) + "-" + cMonth + "-" + cDay.
        END.

        cLogPath = "C:\progress\OE128_64_WRK\oepas1\logs\localhost-access." + cLogDate + ".log".

        oResult = NEW Progress.Json.ObjectModel.JsonObject().
        oLines  = NEW Progress.Json.ObjectModel.JsonArray().

        INPUT FROM VALUE(cLogPath) NO-ECHO.
        REPEAT:
            IMPORT UNFORMATTED cLine.
            iTotalLines = iTotalLines + 1.
            oLines:Add(cLine).
            IF INDEX(cLine, " 200 ") > 0 THEN
                i200Count = i200Count + 1.
        END.
        INPUT CLOSE.

        oResult:Add("log_file",    cLogPath).
        oResult:Add("log_date",    cLogDate).
        oResult:Add("total_lines", iTotalLines).
        oResult:Add("count_200",   i200Count).
        oResult:Add("lines",       oLines).

        RETURN CreateMcpResponseJson(id, oResult, false).

    END.

END CLASS.
