USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS web.api.mcp.tools.automagic.start_mcp_notify_server INHERITS web.api.mcp.tools.base.tool :

    METHOD PUBLIC OVERRIDE JsonObject Execute(id AS integer, poArguments AS JsonObject):

DEFINE VARIABLE cServerFile AS CHARACTER NO-UNDO.
DEFINE VARIABLE cPidFile    AS CHARACTER NO-UNDO.
DEFINE VARIABLE cTrigFile   AS CHARACTER NO-UNDO.
DEFINE VARIABLE cBatFile    AS CHARACTER NO-UNDO.
DEFINE VARIABLE cDLC        AS CHARACTER NO-UNDO.
DEFINE VARIABLE cProgRes    AS CHARACTER NO-UNDO.
DEFINE VARIABLE cCode       AS LONGCHAR  NO-UNDO.
DEFINE VARIABLE cBat        AS LONGCHAR  NO-UNDO.
DEFINE VARIABLE oResult     AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
DEFINE VARIABLE cPidContent AS LONGCHAR  NO-UNDO.
DEFINE VARIABLE Q           AS CHARACTER NO-UNDO.
DEFINE VARIABLE N           AS CHARACTER NO-UNDO.
DEFINE VARIABLE iPort       AS INTEGER   NO-UNDO.
DEFINE VARIABLE cPort       AS CHARACTER NO-UNDO.
DEFINE VARIABLE oPsi        AS System.Diagnostics.ProcessStartInfo NO-UNDO.
DEFINE VARIABLE bStarted    AS LOGICAL   NO-UNDO INITIAL FALSE.

ASSIGN Q = CHR(34)  N = CHR(10).

IF poArguments:Has("port") THEN cPort = poArguments:GetCharacter("port").
iPort = INTEGER(cPort) NO-ERROR.
IF ERROR-STATUS:ERROR OR iPort <= 0 THEN iPort = 7890.

ASSIGN
    cServerFile = "C:\\projects\\mcp\\mcp\\mcp_notify_server.p"
    cPidFile    = "C:\\projects\\mcp\\mcp\\notify_server.pid"
    cTrigFile   = "C:\\projects\\mcp\\mcp\\tool-notify.trigger"
    cBatFile    = "C:\\projects\\mcp\\mcp\\launch_notify_server.bat"
    cDLC        = "C:\\progress\\OE128_64"
    cProgRes    = cDLC + "\\bin\\_progres.exe".

FILE-INFO:FILE-NAME = cPidFile.
IF FILE-INFO:FILE-TYPE <> ? THEN DO:
    COPY-LOB FROM FILE cPidFile TO cPidContent NO-ERROR.
    oResult = NEW Progress.Json.ObjectModel.JsonObject().
    oResult:Add("status",  "already_running").
    oResult:Add("started", TRIM(STRING(cPidContent))).
    oResult:Add("port",    iPort).
    RETURN CreateMcpResponseJson(id, oResult, false).
END.

cCode =
    "DEFINE TEMP-TABLE ttClient NO-UNDO" + N +
    "  FIELD iId AS INTEGER FIELD hSocket AS HANDLE." + N +
    "DEFINE VARIABLE hSrv     AS HANDLE    NO-UNDO." + N +
    "DEFINE VARIABLE hTimer   AS HANDLE    NO-UNDO." + N +
    "DEFINE VARIABLE iNext    AS INTEGER   NO-UNDO INITIAL 1." + N +
    "DEFINE VARIABLE iLast    AS INT64     NO-UNDO INITIAL -1." + N +
    "DEFINE VARIABLE cTrig    AS CHARACTER NO-UNDO INITIAL " + Q + cTrigFile + Q + "." + N +
    "DEFINE VARIABLE cPid     AS CHARACTER NO-UNDO INITIAL " + Q + cPidFile  + Q + "." + N + N +
    "PROCEDURE NewClient:" + N +
    "  DEFINE INPUT PARAMETER hS AS HANDLE NO-UNDO." + N +
    "  DEFINE INPUT PARAMETER hC AS HANDLE NO-UNDO." + N +
    "  hC:SET-READ-RESPONSE-PROCEDURE(" + Q + "ClientRead" + Q + ",THIS-PROCEDURE)." + N +
    "  hC:SET-DISCONNECT-PROCEDURE("    + Q + "ClientDrop" + Q + ",THIS-PROCEDURE)." + N +
    "  CREATE ttClient. ASSIGN ttClient.iId=iNext ttClient.hSocket=hC. iNext=iNext+1." + N +
    "END PROCEDURE." + N + N +
    "PROCEDURE ClientRead:" + N +
    "  DEFINE INPUT PARAMETER hSk AS HANDLE NO-UNDO." + N +
    "  DEFINE VARIABLE c AS LONGCHAR NO-UNDO. hSk:READ(c,0) NO-ERROR." + N +
    "END PROCEDURE." + N + N +
    "PROCEDURE ClientDrop:" + N +
    "  DEFINE INPUT PARAMETER hSk AS HANDLE NO-UNDO." + N +
    "  FIND FIRST ttClient WHERE ttClient.hSocket=hSk NO-LOCK NO-ERROR." + N +
    "  IF AVAILABLE ttClient THEN DELETE ttClient." + N +
    "END PROCEDURE." + N + N +
    "PROCEDURE Broadcast:" + N +
    "  DEFINE INPUT PARAMETER cMsg AS CHARACTER NO-UNDO." + N +
    "  DEFINE VARIABLE cL AS LONGCHAR NO-UNDO." + N +
    "  DEFINE VARIABLE iL AS INTEGER  NO-UNDO." + N +
    "  cL=cMsg+CHR(10). iL=LENGTH(cL)." + N +
    "  FOR EACH ttClient NO-LOCK:" + N +
    "    IF VALID-HANDLE(ttClient.hSocket) THEN ttClient.hSocket:WRITE(cL,1,iL) NO-ERROR." + N +
    "  END." + N +
    "END PROCEDURE." + N + N +
    "PROCEDURE CheckTrigger:" + N +
    "  DEFINE VARIABLE cCnt AS CHARACTER NO-UNDO." + N +
    "  DEFINE VARIABLE iCnt AS INT64     NO-UNDO." + N +
    "  DEFINE VARIABLE Q2   AS CHARACTER NO-UNDO INITIAL CHR(34)." + N +
    "  DEFINE VARIABLE cNot AS CHARACTER NO-UNDO." + N +
    "  IF SEARCH(cPid)=? THEN DO: LOG-MANAGER:WRITE-MESSAGE(" + Q + "PID gone,stopping" + Q + "," + Q + "MCPN" + Q + "). STOP. END." + N +
    "  FILE-INFO:FILE-NAME=cTrig. IF FILE-INFO:FILE-TYPE=? THEN RETURN." + N +
    "  COPY-LOB FROM FILE cTrig TO cCnt NO-ERROR. IF ERROR-STATUS:ERROR THEN RETURN." + N +
    "  iCnt=INT64(TRIM(cCnt)) NO-ERROR. IF ERROR-STATUS:ERROR THEN RETURN." + N +
    "  IF iCnt>iLast THEN DO." + N +
    "    iLast=iCnt." + N +
    "    cNot=CHR(123)+Q2+" + Q + "jsonrpc" + Q + "+Q2+" + Q + ":" + Q + "+Q2+" + Q + "2.0" + Q + "+Q2+" + Q + "," + Q + "+Q2+" + Q + "method" + Q + "+Q2+" + Q + ":" + Q + "+Q2+" + Q + "notifications/tools/list_changed" + Q + "+Q2+CHR(125)." + N +
    "    RUN Broadcast(INPUT cNot)." + N +
    "  END." + N +
    "END PROCEDURE." + N + N +
    "CREATE SERVER-SOCKET hSrv." + N +
    "hSrv:SET-CONNECT-PROCEDURE(" + Q + "NewClient" + Q + ",THIS-PROCEDURE)." + N +
    "hSrv:ENABLE-CONNECTIONS(" + STRING(iPort) + ",20," + Q + Q + ")." + N +
    "DEFINE VARIABLE cTs AS CHARACTER NO-UNDO. cTs=STRING(NOW)." + N +
    "COPY-LOB FROM cTs TO FILE cPid NO-CONVERT." + N +
    "LOG-MANAGER:WRITE-MESSAGE(" + Q + "MCP notify server port " + STRING(iPort) + Q + "," + Q + "MCPN" + Q + ")." + N +
    "CREATE TIMER hTimer. hTimer:INTERVAL=500." + N +
    "hTimer:SET-CALLBACK(" + Q + "on-timeout" + Q + "," + Q + "CheckTrigger" + Q + ",THIS-PROCEDURE)." + N +
    "hTimer:ENABLE(). WAIT-FOR STOP." + N +
    "IF VALID-HANDLE(hTimer) THEN DELETE OBJECT hTimer." + N +
    "IF VALID-HANDLE(hSrv) THEN DO. hSrv:DISABLE-CONNECTIONS(). DELETE OBJECT hSrv. END." + N.

COPY-LOB FROM cCode TO FILE cServerFile NO-CONVERT.

cBat = "@echo off" + N +
       "start /B /MIN " + Q + Q + " " + Q + cProgRes + Q + " -b -p " + Q + cServerFile + Q + " 1>nul 2>&1" + N.
COPY-LOB FROM cBat TO FILE cBatFile NO-CONVERT.

/* Launch via .NET Process (avoids OS-COMMAND which is blocked in PASOE agent) */
oPsi = NEW System.Diagnostics.ProcessStartInfo() NO-ERROR.
IF NOT ERROR-STATUS:ERROR THEN DO:
    ASSIGN
        oPsi:FileName        = cProgRes
        oPsi:Arguments       = "-b -p " + Q + cServerFile + Q
        oPsi:UseShellExecute = FALSE
        oPsi:CreateNoWindow  = TRUE.
    System.Diagnostics.Process:Start(oPsi) NO-ERROR.
    bStarted = NOT ERROR-STATUS:ERROR.
END.

oResult = NEW Progress.Json.ObjectModel.JsonObject().
oResult:Add("status",       IF bStarted THEN "started" ELSE "files_written").
oResult:Add("port",         iPort).
oResult:Add("server_file",  cServerFile).
oResult:Add("bat_file",     cBatFile).
oResult:Add("pid_file",     cPidFile).
oResult:Add("trigger_file", cTrigFile).
IF NOT bStarted THEN oResult:Add("manual_launch", "Run: " + cBatFile).
RETURN CreateMcpResponseJson(id, oResult, false).


    END.

END CLASS.
