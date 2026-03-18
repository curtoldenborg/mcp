USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS web.api.mcp.tools.automagic.read_pasoe_error_log INHERITS web.api.mcp.tools.base.tool :

    METHOD PUBLIC OVERRIDE JsonObject Execute(id AS integer, poArguments AS JsonObject):

        DEFINE VARIABLE cLogDate    AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cLogPath    AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cLogPathSafe AS CHARACTER                           NO-UNDO.
        DEFINE VARIABLE cLine       AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cAllLines   AS LONGCHAR                             NO-UNDO.
        DEFINE VARIABLE iTotal      AS INTEGER                              NO-UNDO.
        DEFINE VARIABLE iErrors     AS INTEGER                              NO-UNDO.
        DEFINE VARIABLE iWarnings   AS INTEGER                              NO-UNDO.
        DEFINE VARIABLE oResult     AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
        DEFINE VARIABLE dToday      AS DATE                                 NO-UNDO.
        DEFINE VARIABLE cMonth      AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cDay        AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE mPtr        AS MEMPTR                               NO-UNDO.
        DEFINE VARIABLE cBase64     AS CHARACTER                            NO-UNDO.

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

        cLogPath     = "C:" + CHR(92) + "progress" + CHR(92) + "OE128_64_WRK" + CHR(92) + "oepas1" + CHR(92) + "logs" + CHR(92) + "oepas1.agent." + cLogDate + ".log".
        cLogPathSafe = REPLACE(cLogPath, CHR(92), "/").

        oResult   = NEW Progress.Json.ObjectModel.JsonObject().
        cAllLines = "".

        INPUT FROM VALUE(cLogPath) NO-ECHO.
        REPEAT:
            IMPORT UNFORMATTED cLine.
            iTotal = iTotal + 1.
            IF INDEX(cLine, "ERROR") > 0 OR INDEX(cLine, "WARN") > 0 THEN
            DO:
                cAllLines = cAllLines + cLine + "~n".
                IF INDEX(cLine, "ERROR") > 0 THEN iErrors   = iErrors + 1.
                IF INDEX(cLine, "WARN")  > 0 THEN iWarnings = iWarnings + 1.
            END.
        END.
        INPUT CLOSE.

        COPY-LOB FROM cAllLines TO mPtr.
        cBase64 = BASE64-ENCODE(mPtr).
        SET-SIZE(mPtr) = 0.

        oResult:Add("log_file",      cLogPathSafe).
        oResult:Add("log_date",      cLogDate).
        oResult:Add("total_lines",   iTotal).
        oResult:Add("error_count",   iErrors).
        oResult:Add("warning_count", iWarnings).
        oResult:Add("entries_b64",   cBase64).

        RETURN CreateMcpResponseJson(id, oResult, false).


    END.

END CLASS.
