USING Progress.Json.ObjectModel.*.
USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS web.api.mcp.session:

    DEFINE STATIC TEMP-TABLE ttSession NO-UNDO
        FIELD cSessionId     AS CHARACTER
        FIELD lAuthenticated AS LOGICAL   INIT FALSE
        FIELD cUsername      AS CHARACTER
        FIELD cToken         AS CHARACTER
        FIELD dtCreated      AS DATETIME
        FIELD dtLastAccess   AS DATETIME
        INDEX idxSession IS PRIMARY UNIQUE cSessionId.

    CONSTRUCTOR PUBLIC session():
        EMPTY TEMP-TABLE ttSession.
    END CONSTRUCTOR.

    /*--------------------------------------------------------------------------
        Register a new session after initialize call.
        Call this when you generate the Mcp-Session-Id.
    --------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID RegisterSession(INPUT cSessionId AS CHARACTER):

        IF cSessionId = "" OR cSessionId = ? THEN RETURN.

        /* Don't register duplicates */
        FIND ttSession WHERE ttSession.cSessionId = cSessionId NO-ERROR.
        IF AVAILABLE ttSession THEN RETURN.

        CREATE ttSession.
        ASSIGN
            ttSession.cSessionId     = cSessionId
            ttSession.lAuthenticated = FALSE
            ttSession.cUsername      = ""
            ttSession.cToken         = ""
            ttSession.dtCreated      = NOW
            ttSession.dtLastAccess   = NOW.

        LOG-MANAGER:WRITE-MESSAGE("Session registered: " + cSessionId, "LOG").

    END METHOD.

    /*--------------------------------------------------------------------------
        Authenticate a session after successful login_tool call.
    --------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LOGICAL Authenticate(
        INPUT cSessionId AS CHARACTER,
        INPUT cUsername  AS CHARACTER,
        INPUT cToken     AS CHARACTER):

        FIND ttSession WHERE ttSession.cSessionId = cSessionId NO-ERROR.
        IF NOT AVAILABLE ttSession THEN DO:
            LOG-MANAGER:WRITE-MESSAGE("Authenticate: Session not found: " + cSessionId, "WARN").
            RETURN FALSE.
        END.

        ASSIGN
            ttSession.lAuthenticated = TRUE
            ttSession.cUsername      = cUsername
            ttSession.cToken         = cToken
            ttSession.dtLastAccess   = NOW.

        LOG-MANAGER:WRITE-MESSAGE("Session authenticated: " + cSessionId + " user: " + cUsername, "LOG").
        RETURN TRUE.

    END METHOD.

    /*--------------------------------------------------------------------------
        Check if a session is authenticated.
    --------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LOGICAL IsAuthenticated(INPUT cSessionId AS CHARACTER):

        FIND ttSession WHERE ttSession.cSessionId = cSessionId NO-ERROR.
        IF NOT AVAILABLE ttSession THEN DO:
            LOG-MANAGER:WRITE-MESSAGE("IsAuthenticated: Session not found: " + cSessionId, "WARN").
            RETURN FALSE.
        END.

        /* Update last access time */
        ttSession.dtLastAccess = NOW.

        RETURN ttSession.lAuthenticated.

    END METHOD.

    /*--------------------------------------------------------------------------
        Get the username for a session.
    --------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER GetUsername(INPUT cSessionId AS CHARACTER):

        FIND ttSession WHERE ttSession.cSessionId = cSessionId NO-ERROR.
        IF NOT AVAILABLE ttSession THEN RETURN "".

        RETURN ttSession.cUsername.

    END METHOD.

    /*--------------------------------------------------------------------------
        Get the token for a session.
    --------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER GetToken(INPUT cSessionId AS CHARACTER):

        FIND ttSession WHERE ttSession.cSessionId = cSessionId NO-ERROR.
        IF NOT AVAILABLE ttSession THEN RETURN "".

        RETURN ttSession.cToken.

    END METHOD.

    /*--------------------------------------------------------------------------
        Check if a session exists at all (registered but maybe not authenticated).
    --------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LOGICAL SessionExists(INPUT cSessionId AS CHARACTER):

        FIND ttSession WHERE ttSession.cSessionId = cSessionId NO-ERROR.
        RETURN AVAILABLE ttSession.

    END METHOD.

    /*--------------------------------------------------------------------------
        Remove a session (on disconnect or logout).
    --------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID RemoveSession(INPUT cSessionId AS CHARACTER):

        FIND ttSession WHERE ttSession.cSessionId = cSessionId NO-ERROR.
        IF AVAILABLE ttSession THEN DO:
            DELETE ttSession.
            LOG-MANAGER:WRITE-MESSAGE("Session removed: " + cSessionId, "LOG").
        END.

    END METHOD.

    /*--------------------------------------------------------------------------
        Generate a new session ID (UUID format).
    --------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER GenerateSessionId():

        DEFINE VARIABLE cRaw       AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cSessionId AS CHARACTER NO-UNDO.

        cRaw = REPLACE(GUID(GENERATE-UUID), "-", "").
        cSessionId = SUBSTRING(cRaw,  1, 8) + "-" +
                     SUBSTRING(cRaw,  9, 4) + "-" +
                     SUBSTRING(cRaw, 13, 4) + "-" +
                     SUBSTRING(cRaw, 17, 4) + "-" +
                     SUBSTRING(cRaw, 21, 12).

        RETURN cSessionId.

    END METHOD.

    /*--------------------------------------------------------------------------
        Dump all sessions to the log (useful for debugging).
    --------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID LogAllSessions():

        FOR EACH ttSession NO-LOCK:
            LOG-MANAGER:WRITE-MESSAGE(
                "Session: "  + ttSession.cSessionId +
                " | Auth: "  + STRING(ttSession.lAuthenticated) +
                " | User: "  + ttSession.cUsername  +
                " | Created: " + STRING(ttSession.dtCreated),
                "LOG").
        END.

    END METHOD.

END CLASS.