USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS web.api.mcp.tools.automagic.build_cfg_tool INHERITS web.api.mcp.tools.base.tool :

    METHOD PUBLIC OVERRIDE JsonObject Execute(id AS integer, poArguments AS JsonObject):

DEFINE VARIABLE cOut    AS CHARACTER NO-UNDO INITIAL "C:\projects\mcp\mcp\web\api\mcp\tools\automagic\read_pasoe_configuration.cls".
DEFINE VARIABLE oResult AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
DEFINE VARIABLE q       AS CHARACTER NO-UNDO INITIAL '"'.

OUTPUT TO VALUE(cOut).
PUT UNFORMATTED "USING Progress.Lang.*." SKIP
                "USING Progress.Json.ObjectModel.*." SKIP
                "BLOCK-LEVEL ON ERROR UNDO, THROW." SKIP
                "CLASS web.api.mcp.tools.automagic.read_pasoe_configuration INHERITS web.api.mcp.tools.base.tool :" SKIP
                "    METHOD PUBLIC OVERRIDE JsonObject Execute(id AS integer, poArguments AS JsonObject):" SKIP.
PUT UNFORMATTED "DEFINE VARIABLE cInst  AS CHARACTER NO-UNDO INITIAL " + q + "oepas1" + q + "." SKIP
                "DEFINE VARIABLE cSect  AS CHARACTER NO-UNDO INITIAL " + q + "all" + q + "." SKIP
                "DEFINE VARIABLE cPasoe AS CHARACTER NO-UNDO." SKIP
                "DEFINE VARIABLE cFP    AS CHARACTER NO-UNDO." SKIP
                "DEFINE VARIABLE cTmp   AS CHARACTER NO-UNDO INITIAL " + q + "C:\temp\pcfg.txt" + q + "." SKIP
                "DEFINE VARIABLE cCont  AS CHARACTER NO-UNDO." SKIP
                "DEFINE VARIABLE hFile  AS LONGCHAR  NO-UNDO." SKIP
                "DEFINE VARIABLE i      AS INTEGER   NO-UNDO." SKIP
                "DEFINE VARIABLE oRes   AS Progress.Json.ObjectModel.JsonObject NO-UNDO." SKIP
                "DEFINE VARIABLE oEnv   AS Progress.Json.ObjectModel.JsonObject NO-UNDO." SKIP
                "DEFINE VARIABLE oFiles AS Progress.Json.ObjectModel.JsonObject NO-UNDO." SKIP
                "DEFINE VARIABLE oDisk  AS Progress.Json.ObjectModel.JsonObject NO-UNDO." SKIP
                "DEFINE VARIABLE oPP    AS Progress.Json.ObjectModel.JsonArray  NO-UNDO." SKIP.
PUT UNFORMATTED "IF poArguments:Has(" + q + "instance" + q + ") THEN cInst = poArguments:GetCharacter(" + q + "instance" + q + ")." SKIP
                "IF poArguments:Has(" + q + "section" + q + ")  THEN cSect = poArguments:GetCharacter(" + q + "section" + q + ")." SKIP
                "IF cInst = ? OR cInst = " + q + q + " THEN cInst = " + q + "oepas1" + q + "." SKIP
                "IF cSect = ? OR cSect = " + q + q + " THEN cSect = " + q + "all" + q + "." SKIP
                "cPasoe = " + q + "C:\progress\OE128_64_WRK\" + q + " + cInst." SKIP.
PUT UNFORMATTED "oRes = NEW Progress.Json.ObjectModel.JsonObject()." SKIP
                "oRes:Add(" + q + "instance" + q + ",  cInst)." SKIP
                "oRes:Add(" + q + "timestamp" + q + ", STRING(NOW))." SKIP
                "oRes:Add(" + q + "pasoe_path" + q + ", cPasoe)." SKIP.
PUT UNFORMATTED "/* Environment */" SKIP
                "IF cSect = " + q + "all" + q + " OR cSect = " + q + "environment" + q + " THEN DO:" SKIP
                "    oEnv = NEW Progress.Json.ObjectModel.JsonObject()." SKIP
                "    oEnv:Add(" + q + "dlc" + q + ",       " + q + "C:\progress\OE128_64" + q + ")." SKIP
                "    oEnv:Add(" + q + "conf_path" + q + ", cPasoe + " + q + "\conf" + q + ")." SKIP
                "    oEnv:Add(" + q + "logs_path" + q + ", cPasoe + " + q + "\logs" + q + ")." SKIP
                "    oEnv:Add(" + q + "webroot" + q + ",   cPasoe + " + q + "\webapps\ROOT" + q + ")." SKIP
                "    oPP = NEW Progress.Json.ObjectModel.JsonArray()." SKIP
                "    DO i = 1 TO NUM-ENTRIES(PROPATH): oPP:Add(ENTRY(i,PROPATH)). END." SKIP
                "    oEnv:Add(" + q + "propath" + q + ", oPP)." SKIP
                "    oRes:Add(" + q + "environment" + q + ", oEnv)." SKIP
                "END." SKIP.
PUT UNFORMATTED "/* Config files */" SKIP
                "IF cSect = " + q + "all" + q + " OR cSect = " + q + "config" + q + " THEN DO:" SKIP
                "    oFiles = NEW Progress.Json.ObjectModel.JsonObject()." SKIP.

/* Helper macro via separate lines */
PUT UNFORMATTED "    cFP = cPasoe + " + q + "\conf\openedge.properties" + q + "." SKIP
                "    IF SEARCH(cFP) <> ? THEN DO: hFile = " + q + q + ". INPUT FROM VALUE(cFP). REPEAT: DEFINE VARIABLE cL AS CHARACTER NO-UNDO. IMPORT UNFORMATTED cL. hFile = hFile + cL + CHR(10). END. INPUT CLOSE. cCont = STRING(hFile). IF LENGTH(cCont) > 6000 THEN cCont = SUBSTRING(cCont,1,6000) + " + q + "..truncated" + q + ". oFiles:Add(" + q + "openedge_properties" + q + ", cCont). END." SKIP
                "    ELSE oFiles:Add(" + q + "openedge_properties_error" + q + ", " + q + "not found" + q + ")." SKIP.
PUT UNFORMATTED "    cFP = cPasoe + " + q + "\conf\server.xml" + q + "." SKIP
                "    IF SEARCH(cFP) <> ? THEN DO: hFile = " + q + q + ". INPUT FROM VALUE(cFP). REPEAT: DEFINE VARIABLE cL2 AS CHARACTER NO-UNDO. IMPORT UNFORMATTED cL2. hFile = hFile + cL2 + CHR(10). END. INPUT CLOSE. cCont = STRING(hFile). IF LENGTH(cCont) > 4000 THEN cCont = SUBSTRING(cCont,1,4000) + " + q + "..truncated" + q + ". oFiles:Add(" + q + "server_xml" + q + ", cCont). END." SKIP
                "    ELSE oFiles:Add(" + q + "server_xml_error" + q + ", " + q + "not found" + q + ")." SKIP.
PUT UNFORMATTED "    cFP = cPasoe + " + q + "\conf\jvm.options" + q + "." SKIP
                "    IF SEARCH(cFP) <> ? THEN DO: hFile = " + q + q + ". INPUT FROM VALUE(cFP). REPEAT: DEFINE VARIABLE cL3 AS CHARACTER NO-UNDO. IMPORT UNFORMATTED cL3. hFile = hFile + cL3 + CHR(10). END. INPUT CLOSE. oFiles:Add(" + q + "jvm_options" + q + ", TRIM(STRING(hFile))). END." SKIP
                "    ELSE oFiles:Add(" + q + "jvm_options_error" + q + ", " + q + "not found" + q + ")." SKIP.
PUT UNFORMATTED "    oRes:Add(" + q + "config_files" + q + ", oFiles)." SKIP
                "END." SKIP.
PUT UNFORMATTED "/* Disk */" SKIP
                "IF cSect = " + q + "all" + q + " OR cSect = " + q + "disk" + q + " THEN DO:" SKIP
                "    oDisk = NEW Progress.Json.ObjectModel.JsonObject()." SKIP
                "    OS-COMMAND SILENT VALUE(" + q + "cmd /c dir " + q + " + CHR(34) + cPasoe + " + q + "\conf" + q + " + CHR(34) + " + q + " /b 1> " + q + " + CHR(34) + cTmp + CHR(34) + " + q + " 2>&1" + q + ")." SKIP
                "    IF SEARCH(cTmp) <> ? THEN DO: hFile = " + q + q + ". INPUT FROM VALUE(cTmp). REPEAT: DEFINE VARIABLE cL4 AS CHARACTER NO-UNDO. IMPORT UNFORMATTED cL4. hFile = hFile + cL4 + CHR(10). END. INPUT CLOSE. oDisk:Add(" + q + "conf_files" + q + ", TRIM(STRING(hFile))). OS-DELETE VALUE(cTmp). END." SKIP
                "    OS-COMMAND SILENT VALUE(" + q + "cmd /c dir " + q + " + CHR(34) + cPasoe + " + q + "\logs" + q + " + CHR(34) + " + q + " /b 1> " + q + " + CHR(34) + cTmp + CHR(34) + " + q + " 2>&1" + q + ")." SKIP
                "    IF SEARCH(cTmp) <> ? THEN DO: hFile = " + q + q + ". INPUT FROM VALUE(cTmp). REPEAT: DEFINE VARIABLE cL5 AS CHARACTER NO-UNDO. IMPORT UNFORMATTED cL5. hFile = hFile + cL5 + CHR(10). END. INPUT CLOSE. oDisk:Add(" + q + "log_files" + q + ", TRIM(STRING(hFile))). OS-DELETE VALUE(cTmp). END." SKIP
                "    oRes:Add(" + q + "disk" + q + ", oDisk)." SKIP
                "END." SKIP.
PUT UNFORMATTED "RETURN CreateMcpResponseJson(id, oRes, false)." SKIP
                "    END." SKIP
                "END CLASS." SKIP.
OUTPUT CLOSE.

oResult = NEW Progress.Json.ObjectModel.JsonObject().
oResult:Add("status", IF OS-ERROR = 0 THEN "success" ELSE "error").
oResult:Add("path", cOut).
RETURN CreateMcpResponseJson(id, oResult, false).


    END.

END CLASS.
