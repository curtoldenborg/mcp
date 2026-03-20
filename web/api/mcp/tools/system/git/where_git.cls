USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS web.api.mcp.tools.system.git.where_git INHERITS web.api.mcp.tools.base.tool :

    METHOD PUBLIC OVERRIDE JsonObject Execute(id AS integer, poArguments AS JsonObject):

DEFINE VARIABLE cOut    AS CHARACTER NO-UNDO INITIAL "C:\\temp\\where_git.txt".
DEFINE VARIABLE hFile   AS LONGCHAR  NO-UNDO.
DEFINE VARIABLE cOutput AS CHARACTER NO-UNDO.
DEFINE VARIABLE oResult AS Progress.Json.ObjectModel.JsonObject NO-UNDO.

OS-COMMAND SILENT VALUE("cmd /c where git 1> " + CHR(34) + cOut + CHR(34) + " 2>&1").

IF SEARCH(cOut) <> ? THEN DO:
    COPY-LOB FROM FILE cOut TO hFile.
    cOutput = TRIM(STRING(hFile)).
    OS-DELETE VALUE(cOut).
END.
ELSE cOutput = "output file not found".

oResult = NEW Progress.Json.ObjectModel.JsonObject().
oResult:Add("git_location", cOutput).
RETURN CreateMcpResponseJson(id, oResult, false).


    END.

END CLASS.
