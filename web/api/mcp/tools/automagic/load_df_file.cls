USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS web.api.mcp.tools.automagic.load_df_file INHERITS web.api.mcp.tools.base.tool :

    METHOD PUBLIC OVERRIDE JsonObject Execute(id AS integer, poArguments AS JsonObject):

        DEFINE VARIABLE cDfFile   AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cDbConn   AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cCmd      AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cLogFile  AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cLine     AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cLog      AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE oResult   AS Progress.Json.ObjectModel.JsonObject NO-UNDO.

        cDfFile  = poArguments:GetCharacter("df_file").
        cDbConn  = IF poArguments:Has("db_conn") THEN poArguments:GetCharacter("db_conn") ELSE "".
        cLogFile = "C:" + CHR(92) + "temp" + CHR(92) + "loddl_output.log".

        oResult = NEW Progress.Json.ObjectModel.JsonObject().
        oResult:Add("df_file", cDfFile).

        /* proload <db> <dffile> */
        cCmd = "C:" + CHR(92) + "progress" + CHR(92) + "OE128_64" + CHR(92) + "bin" + CHR(92)
             + "proload " + cDbConn + " " + QUOTER(cDfFile)
             + " > " + cLogFile + " 2>&1".

        OS-COMMAND SILENT VALUE(cCmd).

        /* Read log output */
        IF SEARCH(cLogFile) <> ? THEN
        DO:
            INPUT FROM VALUE(cLogFile).
            REPEAT:
                IMPORT UNFORMATTED cLine.
                cLog = cLog + cLine + "~n".
            END.
            INPUT CLOSE.
        END.

        IF OS-ERROR = 0 THEN
        DO:
            oResult:Add("status",  "ok").
            oResult:Add("message", "Loaded: " + cDfFile).
            oResult:Add("log",     cLog).
        END.
        ELSE
        DO:
            oResult:Add("status",    "error").
            oResult:Add("os_error",  OS-ERROR).
            oResult:Add("message",   "proload failed with OS-ERROR " + STRING(OS-ERROR)).
            oResult:Add("log",       cLog).
        END.

        RETURN CreateMcpResponseJson(id, oResult, false).

        CATCH e AS Progress.Lang.Error:
            oResult:Add("status",  "error").
            oResult:Add("message", e:GetMessage(1)).
            RETURN CreateMcpResponseJson(id, oResult, false).
        END CATCH.


    END.

END CLASS.
