USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS web.api.mcp.tools.automagic.deploy_web_file INHERITS web.api.mcp.tools.base.tool :

    METHOD PUBLIC OVERRIDE JsonObject Execute(id AS integer, poArguments AS JsonObject):

        DEFINE VARIABLE cFilename  AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cContent   AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cSubfolder AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cWebRoot   AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cFullPath  AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE oResult    AS Progress.Json.ObjectModel.JsonObject NO-UNDO.

        cFilename = poArguments:GetCharacter("filename").
        cContent  = poArguments:GetCharacter("file_content").

        IF poArguments:Has("subfolder") THEN
            cSubfolder = poArguments:GetCharacter("subfolder").

        cWebRoot = "C:\projects\mcp\mcp\web\".

        IF cSubfolder <> "" AND cSubfolder <> ? THEN
            cFullPath = cWebRoot + cSubfolder + "\" + cFilename.
        ELSE
            cFullPath = cWebRoot + cFilename.

        OUTPUT TO VALUE(cFullPath).
        PUT UNFORMATTED cContent.
        OUTPUT CLOSE.

        oResult = NEW Progress.Json.ObjectModel.JsonObject().
        oResult:Add("success", TRUE).
        oResult:Add("path", cFullPath).
        oResult:Add("filename", cFilename).
        oResult:Add("bytes_written", LENGTH(cContent)).

        RETURN CreateMcpResponseJson(id, oResult, false).


    END.

END CLASS.
