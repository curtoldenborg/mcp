USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS web.api.mcp.tools.automagic.fix_create_abl_tool INHERITS web.api.mcp.tools.base.tool :

    METHOD PUBLIC OVERRIDE JsonObject Execute(id AS integer, poArguments AS JsonObject):

DEFINE VARIABLE cPath    AS CHARACTER NO-UNDO.
DEFINE VARIABLE cSrc     AS LONGCHAR  NO-UNDO.
DEFINE VARIABLE cFixed   AS LONGCHAR  NO-UNDO.
DEFINE VARIABLE lDryRun  AS LOGICAL   NO-UNDO.
DEFINE VARIABLE oResult  AS Progress.Json.ObjectModel.JsonObject NO-UNDO.

IF poArguments:Has("dry_run") THEN lDryRun = poArguments:GetLogical("dry_run").

cPath = "C:\projects\mcp\mcp\web\api\mcp\tools\system\create_abl_tool.cls".

COPY-LOB FROM FILE cPath TO cSrc.

/* Patch 1: cBody AS CHARACTER  ->  cBody AS LONGCHAR */
cFixed = REPLACE(STRING(cSrc),
    "DEFINE VARIABLE cBody     AS CHARACTER NO-UNDO.",
    "DEFINE VARIABLE cBody     AS LONGCHAR  NO-UNDO.  /* PATCHED */").

/* Patch 2: cTT AS CHARACTER  ->  cTT AS LONGCHAR */
cFixed = REPLACE(STRING(cFixed),
    "DEFINE VARIABLE cTT       AS CHARACTER NO-UNDO.",
    "DEFINE VARIABLE cTT       AS LONGCHAR  NO-UNDO.  /* PATCHED */").

/* Patch 3: cProps AS CHARACTER  ->  cProps AS LONGCHAR */
cFixed = REPLACE(STRING(cFixed),
    "DEFINE VARIABLE cProps    AS CHARACTER NO-UNDO.",
    "DEFINE VARIABLE cProps    AS LONGCHAR  NO-UNDO.  /* PATCHED */").

/* Patch 4: GetCharacter("abl_code")  ->  GetLongchar("abl_code") */
cFixed = REPLACE(STRING(cFixed),
    'cBody   = poArgs:GetCharacter("abl_code")',
    'cBody   = poArgs:GetLongchar("abl_code")   /* PATCHED */').

oResult = NEW Progress.Json.ObjectModel.JsonObject().

IF lDryRun THEN DO:
    oResult:Add("status",  "dry_run").
    oResult:Add("preview", SUBSTRING(STRING(cFixed), 1, 500)).
    RETURN CreateMcpResponseJson(id, oResult, false).
END.

COPY-LOB FROM cFixed TO FILE cPath.

oResult:Add("status",  "patched").
oResult:Add("message", "create_abl_tool.cls updated. Now run compile_abl_tool with toolName=create_abl_tool").
oResult:Add("path",    cPath).
RETURN CreateMcpResponseJson(id, oResult, false).


    END.

END CLASS.
