USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS web.api.mcp.tools.system.obsolete.deploy_html_app INHERITS web.api.mcp.tools.base.tool :

    METHOD PUBLIC OVERRIDE JsonObject Execute(id AS integer, poArguments AS JsonObject):
        DEFINE VARIABLE cPasoeRoot   AS CHARACTER                            NO-UNDO INITIAL 'C:\progress\OE128_64_WRK\oepas1\webapps\ROOT'.
        DEFINE VARIABLE cAppName     AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cHtmlContent AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cFilename    AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cTargetDir   AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cTargetFile  AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cUrlPath     AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE iFile        AS INTEGER                              NO-UNDO.
        DEFINE VARIABLE oResult      AS Progress.Json.ObjectModel.JsonObject NO-UNDO.

        oResult = NEW Progress.Json.ObjectModel.JsonObject().

        cAppName     = poArguments:GetCharacter("app_name").
        cHtmlContent = poArguments:GetCharacter("html_content").

        IF poArguments:Has("filename") AND poArguments:GetType("filename") = Progress.Json.ObjectModel.JsonDataType:STRING THEN
            cFilename = poArguments:GetCharacter("filename").
        ELSE
            cFilename = "index.html".

        /* Build target path */
        cTargetDir  = cPasoeRoot + "\" + cAppName.
        cTargetFile = cTargetDir + "\" + cFilename.

        /* Create subfolder if it doesn't exist */
        OS-CREATE-DIR VALUE(cTargetDir).

        IF OS-ERROR <> 0 THEN 
        DO:
            oResult:Add("status", "error").
            oResult:Add("message", "Failed to create directory: " + cTargetDir + " (OS-ERROR=" + STRING(OS-ERROR) + ")").
            RETURN CreateMcpResponseJson(id, oResult, false).
        END.

        /* Write the HTML file */
        OUTPUT TO VALUE(cTargetFile).
        PUT UNFORMATTED cHtmlContent.
        OUTPUT CLOSE.

        cUrlPath = "/" + cAppName + "/" + cFilename.

        oResult:Add("status",      "ok").
        oResult:Add("target_dir",  cTargetDir).
        oResult:Add("target_file", cTargetFile).
        oResult:Add("url_path",    cUrlPath).
        oResult:Add("message",     "HTML app deployed successfully. Access it at: " + cUrlPath).

        RETURN CreateMcpResponseJson(id, oResult, false).

    END.

END CLASS.
