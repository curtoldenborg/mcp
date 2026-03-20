USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS web.api.mcp.tools.system.deploy_web_file INHERITS web.api.mcp.tools.base.tool :

    METHOD PUBLIC OVERRIDE JsonObject Execute(id AS integer, poArguments AS JsonObject):

DEFINE VARIABLE cFilename   AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE cSubfolder  AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE cWebRoot    AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE cFullPath   AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE cB64        AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE mContent    AS MEMPTR                                NO-UNDO.
DEFINE VARIABLE iBytesOut   AS INT64                                 NO-UNDO.
DEFINE VARIABLE oResult     AS Progress.Json.ObjectModel.JsonObject  NO-UNDO.

cFilename = poArguments:GetCharacter("filename").
cB64      = poArguments:GetCharacter("file_content").

IF poArguments:Has("subfolder") THEN
    cSubfolder = poArguments:GetCharacter("subfolder").

cWebRoot = system.config:projectpath + "web\root\".

IF cSubfolder <> "" AND cSubfolder <> ? THEN
    cFullPath = cWebRoot + cSubfolder + "\" + cFilename.
ELSE
    cFullPath = cWebRoot + cFilename.

/* file_content must be base64-encoded UTF-8.
   BASE64-DECODE returns a MEMPTR with raw bytes.
   COPY-LOB NO-CONVERT writes them without any codepage conversion. */
mContent  = BASE64-DECODE(cB64).
iBytesOut = GET-SIZE(mContent).
COPY-LOB FROM mContent TO FILE cFullPath NO-CONVERT.
SET-SIZE(mContent) = 0.

oResult = NEW Progress.Json.ObjectModel.JsonObject().
oResult:Add("success",       TRUE).
oResult:Add("path",          cFullPath).
oResult:Add("filename",      cFilename).
oResult:Add("bytes_written", iBytesOut).

RETURN CreateMcpResponseJson(id, oResult, false).


    END.

END CLASS.
