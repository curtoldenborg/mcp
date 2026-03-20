USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS web.api.mcp.tools.system.pasoe.pasoe_dashboard_stats INHERITS web.api.mcp.tools.base.tool :

    METHOD PUBLIC OVERRIDE JsonObject Execute(id AS integer, poArguments AS JsonObject):

DEFINE VARIABLE cLogDate     AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE cAccessPath  AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE cAgentPath   AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE cLine        AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE dToday       AS DATE                                  NO-UNDO.
DEFINE VARIABLE cMonth       AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE cDay         AS CHARACTER                             NO-UNDO.

/* Access log counters */
DEFINE VARIABLE iTotalReq    AS INTEGER   NO-UNDO.
DEFINE VARIABLE i200         AS INTEGER   NO-UNDO.
DEFINE VARIABLE i400         AS INTEGER   NO-UNDO.
DEFINE VARIABLE i500         AS INTEGER   NO-UNDO.
DEFINE VARIABLE iOtherStatus AS INTEGER   NO-UNDO.
DEFINE VARIABLE iTotalBytes  AS INT64     NO-UNDO.
DEFINE VARIABLE iMinute      AS CHARACTER NO-UNDO.
DEFINE VARIABLE iLastMinute  AS CHARACTER NO-UNDO.
DEFINE VARIABLE iReqLastMin  AS INTEGER   NO-UNDO.
DEFINE VARIABLE iReqCurMin   AS INTEGER   NO-UNDO.
DEFINE VARIABLE cHour        AS CHARACTER NO-UNDO.
DEFINE VARIABLE cStatus      AS CHARACTER NO-UNDO.
DEFINE VARIABLE cBytes       AS CHARACTER NO-UNDO.
DEFINE VARIABLE iBytes       AS INT64     NO-UNDO.
DEFINE VARIABLE iStart       AS INTEGER   NO-UNDO.
DEFINE VARIABLE iEnd         AS INTEGER   NO-UNDO.
DEFINE VARIABLE cAfter       AS CHARACTER NO-UNDO.
DEFINE VARIABLE cTimestamp   AS CHARACTER NO-UNDO.
DEFINE VARIABLE cTimeOnly    AS CHARACTER NO-UNDO.
DEFINE VARIABLE cLastReqTime AS CHARACTER NO-UNDO.
DEFINE VARIABLE cFirstTime   AS CHARACTER NO-UNDO.

/* Agent log counters */
DEFINE VARIABLE iAgentTotal  AS INTEGER   NO-UNDO.
DEFINE VARIABLE iAgentErrors AS INTEGER   NO-UNDO.
DEFINE VARIABLE iAgentWarns  AS INTEGER   NO-UNDO.
DEFINE VARIABLE iAgentReq    AS INTEGER   NO-UNDO.
DEFINE VARIABLE iAgentAppl   AS INTEGER   NO-UNDO.
DEFINE VARIABLE cAgentLevel  AS CHARACTER NO-UNDO.
DEFINE VARIABLE cLastError   AS CHARACTER NO-UNDO.
DEFINE VARIABLE cLastErrorTs AS CHARACTER NO-UNDO.

/* Hourly buckets 0-23 */
DEFINE VARIABLE iHourBucket  AS INTEGER   NO-UNDO EXTENT 24.
DEFINE VARIABLE iH           AS INTEGER   NO-UNDO.

/* Per-minute sparkline: last 60 minutes */
DEFINE VARIABLE iMinBucket   AS CHARACTER EXTENT 60 NO-UNDO.
DEFINE VARIABLE iMinCount    AS INTEGER   EXTENT 60 NO-UNDO.
DEFINE VARIABLE iMinIdx      AS INTEGER   NO-UNDO.
DEFINE VARIABLE cMinKey      AS CHARACTER NO-UNDO.
DEFINE VARIABLE iM           AS INTEGER   NO-UNDO.
DEFINE VARIABLE iFound       AS INTEGER   NO-UNDO.

DEFINE VARIABLE oResult      AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
DEFINE VARIABLE oHourly      AS Progress.Json.ObjectModel.JsonArray  NO-UNDO.
DEFINE VARIABLE oSpark       AS Progress.Json.ObjectModel.JsonArray  NO-UNDO.
DEFINE VARIABLE oSparkLabels AS Progress.Json.ObjectModel.JsonArray  NO-UNDO.

/* Resolve date */
dToday = TODAY.
cMonth = STRING(MONTH(dToday), "99").
cDay   = STRING(DAY(dToday),   "99").
ASSIGN
    cMonth = REPLACE(cMonth, " ", "0")
    cDay   = REPLACE(cDay,   " ", "0").
cLogDate = STRING(YEAR(dToday)) + "-" + cMonth + "-" + cDay.

cAccessPath = "C:\progress\OE128_64_WRK\oepas1\logs\localhost-access." + cLogDate + ".log".
cAgentPath  = "C:\progress\OE128_64_WRK\oepas1\logs\oepas1.agent."     + cLogDate + ".log".

/* === PASS 1: Access log === */
INPUT FROM VALUE(cAccessPath) NO-ECHO.
REPEAT:
    IMPORT UNFORMATTED cLine.
    iTotalReq = iTotalReq + 1.

    /* Extract timestamp */
    iStart = INDEX(cLine, "[").
    iEnd   = INDEX(cLine, "]").
    IF iStart > 0 AND iEnd > iStart THEN
    DO:
        cTimestamp = SUBSTRING(cLine, iStart + 1, iEnd - iStart - 1).
        /* cTimestamp = 2026-03-20T14:10:29.483+01:00 */
        iStart = INDEX(cTimestamp, "T").
        IF iStart > 0 THEN
            cTimeOnly = SUBSTRING(cTimestamp, iStart + 1, 5). /* HH:MM */
        ELSE
            cTimeOnly = "".
        cHour   = SUBSTRING(cTimeOnly, 1, 2).
        cMinKey = cTimeOnly. /* HH:MM */
    END.

    IF cFirstTime = "" OR cFirstTime = ? THEN cFirstTime = cTimeOnly.
    cLastReqTime = cTimeOnly.

    /* Hourly bucket */
    iH = INTEGER(cHour) NO-ERROR.
    IF NOT ERROR-STATUS:ERROR AND iH >= 0 AND iH <= 23 THEN
        iHourBucket[iH + 1] = iHourBucket[iH + 1] + 1.

    /* Per-minute sparkline: store last 60 unique minutes */
    IF cMinKey <> "" AND cMinKey <> ? THEN
    DO:
        iFound = 0.
        DO iM = 1 TO iMinIdx:
            IF iMinBucket[iM] = cMinKey THEN
            DO:
                iMinCount[iM] = iMinCount[iM] + 1.
                iFound = 1.
                LEAVE.
            END.
        END.
        IF iFound = 0 AND iMinIdx < 60 THEN
        DO:
            iMinIdx = iMinIdx + 1.
            iMinBucket[iMinIdx] = cMinKey.
            iMinCount[iMinIdx]  = 1.
        END.
    END.

    /* Status code */
    iEnd   = R-INDEX(cLine, CHR(34)).
    IF iEnd > 0 THEN
    DO:
        cAfter  = TRIM(SUBSTRING(cLine, iEnd + 1)).
        cStatus = ENTRY(1, cAfter, " ").
        IF NUM-ENTRIES(cAfter, " ") >= 2 THEN
            cBytes = ENTRY(2, cAfter, " ").
        ELSE
            cBytes = "0".
    END.

    IF cStatus BEGINS "2" THEN i200 = i200 + 1.
    ELSE IF cStatus BEGINS "4" THEN i400 = i400 + 1.
    ELSE IF cStatus BEGINS "5" THEN i500 = i500 + 1.
    ELSE iOtherStatus = iOtherStatus + 1.

    iBytes = INT64(cBytes) NO-ERROR.
    IF NOT ERROR-STATUS:ERROR AND iBytes > 0 THEN
        iTotalBytes = iTotalBytes + iBytes.

END.
INPUT CLOSE.

/* === PASS 2: Agent log === */
INPUT FROM VALUE(cAgentPath) NO-ECHO.
REPEAT:
    IMPORT UNFORMATTED cLine.
    iAgentTotal = iAgentTotal + 1.
    IF INDEX(cLine, " ERROR ") > 0 OR INDEX(cLine, " ERR ") > 0 THEN
    DO:
        iAgentErrors = iAgentErrors + 1.
        cLastError   = SUBSTRING(cLine, 1, 120).
        iStart = INDEX(cLine, "T").
        IF iStart > 0 THEN cLastErrorTs = SUBSTRING(cLine, iStart + 1, 8).
    END.
    IF INDEX(cLine, " WARN ") > 0 THEN iAgentWarns = iAgentWarns + 1.
    IF INDEX(cLine, " REQ ")  > 0 THEN iAgentReq   = iAgentReq  + 1.
    IF INDEX(cLine, " APPL ") > 0 THEN iAgentAppl  = iAgentAppl + 1.
END.
INPUT CLOSE.

/* === Build JSON === */
oResult      = NEW Progress.Json.ObjectModel.JsonObject().
oHourly      = NEW Progress.Json.ObjectModel.JsonArray().
oSpark       = NEW Progress.Json.ObjectModel.JsonArray().
oSparkLabels = NEW Progress.Json.ObjectModel.JsonArray().

DO iH = 1 TO 24:
    oHourly:Add(iHourBucket[iH]).
END.

DO iM = 1 TO iMinIdx:
    oSpark:Add(iMinCount[iM]).
    oSparkLabels:Add(iMinBucket[iM]).
END.

oResult:Add("log_date",       cLogDate).
oResult:Add("total_requests", iTotalReq).
oResult:Add("status_2xx",     i200).
oResult:Add("status_4xx",     i400).
oResult:Add("status_5xx",     i500).
oResult:Add("total_bytes",    iTotalBytes).
oResult:Add("first_req_time", cFirstTime).
oResult:Add("last_req_time",  cLastReqTime).
oResult:Add("hourly_counts",  oHourly).
oResult:Add("spark_counts",   oSpark).
oResult:Add("spark_labels",   oSparkLabels).
oResult:Add("agent_total",    iAgentTotal).
oResult:Add("agent_errors",   iAgentErrors).
oResult:Add("agent_warnings", iAgentWarns).
oResult:Add("agent_req",      iAgentReq).
oResult:Add("agent_appl",     iAgentAppl).
oResult:Add("last_error_msg", cLastError).
oResult:Add("last_error_ts",  cLastErrorTs).

RETURN CreateMcpResponseJson(id, oResult, false).


    END.

END CLASS.
