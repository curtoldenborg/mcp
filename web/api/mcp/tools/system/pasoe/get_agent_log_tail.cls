USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS web.api.mcp.tools.system.pasoe.get_agent_log_tail INHERITS web.api.mcp.tools.base.tool :

    METHOD PUBLIC OVERRIDE JsonObject Execute(id AS integer, poArguments AS JsonObject):

DEFINE VARIABLE cLogDate    AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE cLogPath    AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE cLine       AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE iMaxLines   AS INTEGER                               NO-UNDO.
DEFINE VARIABLE iTotalLines AS INTEGER                               NO-UNDO.
DEFINE VARIABLE dToday      AS DATE                                  NO-UNDO.
DEFINE VARIABLE cMonth      AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE cDay        AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE oResult     AS Progress.Json.ObjectModel.JsonObject  NO-UNDO.
DEFINE VARIABLE oLines      AS Progress.Json.ObjectModel.JsonArray   NO-UNDO.
DEFINE VARIABLE cBuf        AS CHARACTER EXTENT 200                  NO-UNDO.
DEFINE VARIABLE iIdx        AS INTEGER                               NO-UNDO.
DEFINE VARIABLE i           AS INTEGER                               NO-UNDO.
DEFINE VARIABLE iPos        AS INTEGER                               NO-UNDO.

iMaxLines = 100.
IF poArguments:Has("lines") THEN
DO:
    iMaxLines = poArguments:GetInteger("lines").
    IF iMaxLines = ? OR iMaxLines <= 0 OR iMaxLines > 200 THEN iMaxLines = 100.
END.

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

cLogPath = "C:\progress\OE128_64_WRK\oepas1\logs\oepas1.agent." + cLogDate + ".log".

INPUT FROM VALUE(cLogPath) NO-ECHO.
REPEAT:
    IMPORT UNFORMATTED cLine.
    iTotalLines = iTotalLines + 1.
    iIdx = iTotalLines MOD iMaxLines.
    IF iIdx = 0 THEN iIdx = iMaxLines.
    cBuf[iIdx] = cLine.
END.
INPUT CLOSE.

oResult = NEW Progress.Json.ObjectModel.JsonObject().
oLines  = NEW Progress.Json.ObjectModel.JsonArray().

IF iTotalLines <= iMaxLines THEN
DO:
    DO i = 1 TO iTotalLines:
        oLines:Add(cBuf[i]).
    END.
END.
ELSE
DO:
    iPos = iTotalLines MOD iMaxLines.
    IF iPos = 0 THEN iPos = iMaxLines.
    DO i = iPos + 1 TO iMaxLines:
        oLines:Add(cBuf[i]).
    END.
    DO i = 1 TO iPos:
        oLines:Add(cBuf[i]).
    END.
END.

oResult:Add("log_date",    cLogDate).
oResult:Add("total_lines", iTotalLines).
oResult:Add("returned",    oLines:Length).
oResult:Add("lines",       oLines).

RETURN CreateMcpResponseJson(id, oResult, false).


    END.

END CLASS.
