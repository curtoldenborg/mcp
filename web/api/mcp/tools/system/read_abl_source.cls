USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS web.api.mcp.tools.system.read_abl_source INHERITS web.api.mcp.tools.base.tool :

    METHOD PUBLIC OVERRIDE JsonObject Execute(id AS integer, poArguments AS JsonObject):

        DEFINE VARIABLE cToolName          AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cClsPath           AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cJsonPath          AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cLine              AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cClsContent        AS LONGCHAR  NO-UNDO.
        DEFINE VARIABLE cJsonContent       AS LONGCHAR  NO-UNDO.
        DEFINE VARIABLE oResult            AS Progress.Json.ObjectModel.JsonObject NO-UNDO.

        cToolName          = poArguments:GetCharacter("toolName").
        cClsPath          = web.api.mcp.tools:GetToolClassFileName(cToolname).
        
        IF cClsPath = ? THEN
            RETURN CreateMcpResponseText(id, "tool:" + QUOTER(cToolName) + " not found!", false).

        IF SEARCH(cClsPath) <> ? THEN 
        DO:
            FILE-INFO:FILE-NAME = cClsPath.
            cClsPath = FILE-INFO:FULL-PATHNAME.
        END. 
        
        /* Read .cls source */
        cClsContent = "".
        INPUT FROM VALUE(cClsPath).
        REPEAT:
            IMPORT UNFORMATTED cLine.
            cClsContent = cClsContent + cLine + "~n".
        END.
        INPUT CLOSE.

        /* Read .json file if it exists */
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
            cJsonContent = "(no .json file found)".

        oResult = NEW Progress.Json.ObjectModel.JsonObject().
        oResult:Add("cls_path",    cClsPath).
        oResult:Add("cls_source",  STRING(cClsContent)).
        oResult:Add("json_path",   cJsonPath).
        oResult:Add("json_source", STRING(cJsonContent)).

        RETURN CreateMcpResponseJson(id, oResult, false).


    END.

END CLASS.
