USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS web.api.mcp.tools.automagic.read_abl_source INHERITS web.api.mcp.tools.base.tool :

    METHOD PUBLIC OVERRIDE JsonObject Execute(id AS integer, poArguments AS JsonObject):

        DEFINE VARIABLE cToolName          AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cBasePath          AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cAutomagicPath     AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cClsPath           AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cJsonPath          AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cLine              AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cClsContent        AS LONGCHAR  NO-UNDO.
        DEFINE VARIABLE cJsonContent       AS LONGCHAR  NO-UNDO.
        DEFINE VARIABLE oResult            AS Progress.Json.ObjectModel.JsonObject NO-UNDO.

        cToolName      = poArguments:GetCharacter("toolName").
        cBasePath      = SEARCH("C:\projects\pasoem8m\m8m\web/api/mcp/tools/" + cToolName + ".cls").
        cAutomagicPath = SEARCH("C:\projects\pasoem8m\m8m\web/api/mcp/tools/automagic/" + cToolName + ".cls").

        IF cBasePath = ? AND cAutomagicPath = ? THEN
            RETURN CreateMcpResponseText(id, "tool:" + QUOTER(cToolName) + " not found!", false).

        cClsPath = IF cBasePath <> ? THEN cBasePath ELSE cAutomagicPath.

        /* Read .cls source */
        cClsContent = "".
        INPUT FROM VALUE(cClsPath).
        REPEAT:
            IMPORT UNFORMATTED cLine.
            cClsContent = cClsContent + cLine + "~n".
        END.
        INPUT CLOSE.

        /* Read .json - only exists for automagic tools */
        cJsonPath = REPLACE(cClsPath, ".cls", ".json").
        IF SEARCH(cJsonPath) <> ? THEN
        DO:
            cJsonContent = "".
            INPUT FROM VALUE(cJsonPath).
            REPEAT:
                IMPORT UNFORMATTED cLine.
                cJsonContent = cJsonContent + cLine + "~n".
            END.
            INPUT CLOSE.
        END.
        ELSE
            cJsonContent = "(no .json file - this is a base tool)".

        oResult = NEW Progress.Json.ObjectModel.JsonObject().
        oResult:Add("cls_path",    cClsPath).
        oResult:Add("cls_source",  STRING(cClsContent)).
        oResult:Add("json_path",   cJsonPath).
        oResult:Add("json_source", STRING(cJsonContent)).

        RETURN CreateMcpResponseJson(id, oResult, false).


    END.

END CLASS.
