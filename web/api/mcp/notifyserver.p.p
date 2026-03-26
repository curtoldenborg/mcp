/* 1. Configuration - Change these to match your server setup */
DEFINE VARIABLE iPort     AS INTEGER   NO-UNDO INITIAL 7999.
DEFINE VARIABLE cTrigFile AS CHARACTER NO-UNDO INITIAL "trigger.txt".
DEFINE VARIABLE cPidFile  AS CHARACTER NO-UNDO INITIAL "server.pid".

LOG-MANAGER:LOGFILE-NAME = "notifyserver.log". 

/* 2. Global Definitions */
DEFINE TEMP-TABLE ttClient NO-UNDO
    FIELD iId     AS INTEGER
    FIELD hSocket AS HANDLE.
                                                                
DEFINE VARIABLE hSrv      AS HANDLE    NO-UNDO.
DEFINE VARIABLE iNext     AS INTEGER   NO-UNDO INITIAL 1.
DEFINE VARIABLE iLast     AS INT64     NO-UNDO INITIAL -1.

/* 3. Main Server Startup */
CREATE SERVER-SOCKET hSrv.
hSrv:SET-CONNECT-PROCEDURE("NewClient", THIS-PROCEDURE).

/* ENABLE-CONNECTIONS is a void method. Use NO-ERROR to trap failures. */
hSrv:ENABLE-CONNECTIONS("-S " + STRING(iPort)) NO-ERROR.

IF ERROR-STATUS:ERROR THEN DO:
    MESSAGE "Could not start server on port " + STRING(iPort) + 
            ". Check if the port is already in use." VIEW-AS ALERT-BOX.
    DELETE OBJECT hSrv.
    QUIT.
END.

/* Create the PID content with Port and Time */
DEFINE VARIABLE cPidContent AS LONGCHAR NO-UNDO.
cPidContent = SUBSTITUTE("Port: &1 | Started: &2", STRING(iPort), STRING(NOW)).

/* Save to file */
COPY-LOB FROM cPidContent TO FILE cPidFile NO-CONVERT.
LOG-MANAGER:WRITE-MESSAGE("MCP notify server started. " + STRING(cPidContent), "MCPN").



/* Main Server Loop */
REPEAT:
    /* 1. Manually trigger the file check */
    RUN CheckTrigger.

    /* 2. Process any pending socket connections or data (IMPORTANT) */
    PROCESS EVENTS.
   
    /* 3. Wait for 0.5 seconds before checking again */
//    PAUSE 0.5 BEFORE-HIDE .


    PAUSE 0.5  .

    /* Optional: Provide a way to break the loop, e.g., if PID file is gone */
    IF SEARCH(cPidFile) = ? THEN DO:
        LOG-MANAGER:WRITE-MESSAGE("PID file missing, shutting down.", "MCPN").
        LEAVE. 
    END.
END.

/* 4. Cleanup on Exit */
IF VALID-HANDLE(hSrv) THEN DO:
    hSrv:DISABLE-CONNECTIONS().
    DELETE OBJECT hSrv.
END.

IF SEARCH(cPidFile) NE ? THEN 
DO: 
    OS-DELETE VALUE(cPidFile).
    LOG-MANAGER:WRITE-MESSAGE("Shutdown completed,PID file removed!", "INFO").
END. 

/* --- Internal Procedures --- */

PROCEDURE NewClient:
   // DEFINE INPUT PARAMETER hS AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER hC AS HANDLE NO-UNDO.
    
    LOG-MANAGER:WRITE-MESSAGE("NewClient", "MCPN").
     
    hC:SET-READ-RESPONSE-PROCEDURE("ClientRead", THIS-PROCEDURE).
//    hC:SET-DISCONNECT-PROCEDURE("ClientDrop", THIS-PROCEDURE).
    
    CREATE ttClient.
    ASSIGN 
        ttClient.iId     = iNext
        ttClient.hSocket = hC
        iNext            = iNext + 1.
END PROCEDURE.

PROCEDURE ClientRead:
  //  DEFINE INPUT PARAMETER hSk AS HANDLE NO-UNDO.
    DEFINE VARIABLE c AS LONGCHAR NO-UNDO.
    MESSAGE "self" VIEW-AS ALERT-BOX. 
    /* Read and discard data to keep the buffer clean */
    //hSk:READ(c, 0) NO-ERROR. 
END PROCEDURE.
       
PROCEDURE ClientDrop:
    /*
    // DEFINE INPUT PARAMETER hSk AS HANDLE NO-UNDO.
    FIND FIRST ttClient WHERE ttClient.hSocket = hSk NO-LOCK NO-ERROR.
    IF AVAILABLE ttClient THEN DELETE ttClient.
     */
 END PROCEDURE.


PROCEDURE Broadcast:
    DEFINE INPUT PARAMETER cMsg AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cL AS MEMPTR NO-UNDO.
    
    DEF VAR iLength AS INT NO-UNDO. 
    iLength = LENGTH(cmsg). 
    PUT-STRING(cl,1,iLength) = cmsg. 
    //cL = cMsg + CHR(10). /* Add newline for client parsing */
    
    
    FOR EACH ttClient NO-LOCK:
        IF VALID-HANDLE(ttClient.hSocket) THEN 
            ttClient.hSocket:WRITE(cL, 1, iLength) NO-ERROR.
    END.
    
END PROCEDURE.

PROCEDURE CheckTrigger:
    DEFINE VARIABLE cCnt AS LONGCHAR NO-UNDO.
    DEFINE VARIABLE iCnt AS INT64     NO-UNDO.
    DEFINE VARIABLE cNot AS CHARACTER NO-UNDO.

    /* Self-destruct if the PID file is deleted */
    IF SEARCH(cPidFile) = ? THEN DO:
        LOG-MANAGER:WRITE-MESSAGE("PID file missing, stopping server.", "MCPN").
        STOP.
    END.

    FILE-INFO:FILE-NAME = cTrigFile.
    IF FILE-INFO:FILE-TYPE = ? THEN RETURN.

    COPY-LOB FROM FILE cTrigFile TO cCnt NO-ERROR.
    IF ERROR-STATUS:ERROR THEN RETURN.

    iCnt = INT64(TRIM(cCnt)) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN RETURN.

    /* Check if the trigger number has increased */
    IF iCnt > iLast THEN DO:
        iLast = iCnt.
        /* Fixed JSON string with proper ABL escapes */
      //  cNot = "{~"jsonrpc~":~"2.0~",~"method~":~"notifications/tools/list_changed~"}".
        RUN Broadcast(INPUT cNot).
    END.
END PROCEDURE.
