USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS web.api.mcp.tools.system.git.check_git_paths INHERITS web.api.mcp.tools.base.tool :

    METHOD PUBLIC OVERRIDE JsonObject Execute(id AS integer, poArguments AS JsonObject):

DEFINE VARIABLE cOut    AS CHARACTER NO-UNDO INITIAL "C:\\temp\\git_check.txt".
DEFINE VARIABLE hFile   AS LONGCHAR  NO-UNDO.
DEFINE VARIABLE cOutput AS CHARACTER NO-UNDO.
DEFINE VARIABLE oResult AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
DEFINE VARIABLE cGitExe AS CHARACTER NO-UNDO.

/* Check all known default Git for Windows paths */
OS-COMMAND SILENT VALUE("cmd /c if exist " + CHR(34) + "C:\\Program Files\\Git\\bin\\git.exe" + CHR(34) + " echo FOUND_PF >> " + CHR(34) + cOut + CHR(34) + " 2>&1").
OS-COMMAND SILENT VALUE("cmd /c if exist " + CHR(34) + "C:\\Program Files\\Git\\cmd\\git.exe" + CHR(34) + " echo FOUND_CMD >> " + CHR(34) + cOut + CHR(34) + " 2>&1").
OS-COMMAND SILENT VALUE("cmd /c if exist " + CHR(34) + "C:\\Program Files (x86)\\Git\\bin\\git.exe" + CHR(34) + " echo FOUND_PF86 >> " + CHR(34) + cOut + CHR(34) + " 2>&1").
OS-COMMAND SILENT VALUE("cmd /c if exist C:\\Git\\bin\\git.exe echo FOUND_CGIT >> " + CHR(34) + cOut + CHR(34) + " 2>&1").
OS-COMMAND SILENT VALUE("cmd /c if exist C:\\git\\cmd\\git.exe echo FOUND_CGIT_CMD >> " + CHR(34) + cOut + CHR(34) + " 2>&1").
OS-COMMAND SILENT VALUE("cmd /c " + CHR(34) + "C:\\Program Files\\Git\\bin\\git.exe" + CHR(34) + " --version >> " + CHR(34) + cOut + CHR(34) + " 2>&1").

IF SEARCH(cOut) <> ? THEN DO:
    COPY-LOB FROM FILE cOut TO hFile.
    cOutput = TRIM(STRING(hFile)).
    OS-DELETE VALUE(cOut).
END.
ELSE cOutput = "output file not found".

oResult = NEW Progress.Json.ObjectModel.JsonObject().
oResult:Add("output", cOutput).
RETURN CreateMcpResponseJson(id, oResult, false).


    END.

END CLASS.
