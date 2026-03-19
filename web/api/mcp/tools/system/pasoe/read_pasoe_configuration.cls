USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS web.api.mcp.tools.system.pasoe.read_pasoe_configuration INHERITS web.api.mcp.tools.base.tool :
    METHOD PUBLIC OVERRIDE JsonObject Execute(id AS integer, poArguments AS JsonObject):
        DEFINE VARIABLE cInst  AS CHARACTER                            NO-UNDO INITIAL "oepas1".
        DEFINE VARIABLE cSect  AS CHARACTER                            NO-UNDO INITIAL "all".
        DEFINE VARIABLE cPasoe AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cFP    AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cTmp   AS CHARACTER                            NO-UNDO INITIAL "C:\temp\pcfg.txt".
        DEFINE VARIABLE cCont  AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE hFile  AS LONGCHAR                             NO-UNDO.
        DEFINE VARIABLE i      AS INTEGER                              NO-UNDO.
        DEFINE VARIABLE oRes   AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
        DEFINE VARIABLE oEnv   AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
        DEFINE VARIABLE oFiles AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
        DEFINE VARIABLE oDisk  AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
        DEFINE VARIABLE oPP    AS Progress.Json.ObjectModel.JsonArray  NO-UNDO.
        IF poArguments:Has("instance") THEN cInst = poArguments:GetCharacter("instance").
        IF poArguments:Has("section")  THEN cSect = poArguments:GetCharacter("section").
        IF cInst = ? OR cInst = "" THEN cInst = "oepas1".
        IF cSect = ? OR cSect = "" THEN cSect = "all".
        cPasoe = "C:\progress\OE128_64_WRK\" + cInst.
        oRes = NEW Progress.Json.ObjectModel.JsonObject().
        oRes:Add("instance",  cInst).
        oRes:Add("timestamp", STRING(NOW)).
        oRes:Add("pasoe_path", cPasoe).
        /* Environment */
        IF cSect = "all" OR cSect = "environment" THEN 
        DO:
            oEnv = NEW Progress.Json.ObjectModel.JsonObject().
            oEnv:Add("dlc",       "C:\progress\OE128_64").
            oEnv:Add("conf_path", cPasoe + "\conf").
            oEnv:Add("logs_path", cPasoe + "\logs").
            oEnv:Add("webroot",   cPasoe + "\webapps\ROOT").
            oPP = NEW Progress.Json.ObjectModel.JsonArray().
            DO i = 1 TO NUM-ENTRIES(PROPATH): oPP:Add(ENTRY(i,PROPATH)). 
            END.
            oEnv:Add("propath", oPP).
            oRes:Add("environment", oEnv).
        END.
        /* Config files */
        IF cSect = "all" OR cSect = "config" THEN 
        DO:
            oFiles = NEW Progress.Json.ObjectModel.JsonObject().
            cFP = cPasoe + "\conf\openedge.properties".
            IF SEARCH(cFP) <> ? THEN 
            DO: 
                hFile = "". 
                INPUT FROM VALUE(cFP). 
                REPEAT: 
                    DEFINE VARIABLE cL AS CHARACTER NO-UNDO. 
                    IMPORT UNFORMATTED cL. 
                    hFile = hFile + cL + CHR(10). 
                END. 
                INPUT CLOSE. 
                cCont = STRING(hFile). 
                IF LENGTH(cCont) > 6000 THEN cCont = SUBSTRING(cCont,1,6000) + "..truncated". oFiles:Add("openedge_properties", cCont). 
            END.
            ELSE oFiles:Add("openedge_properties_error", "not found").
            cFP = cPasoe + "\conf\server.xml".
            IF SEARCH(cFP) <> ? THEN 
            DO: 
                hFile = "". 
                INPUT FROM VALUE(cFP). 
                REPEAT: 
                    DEFINE VARIABLE cL2 AS CHARACTER NO-UNDO. 
                    IMPORT UNFORMATTED cL2. 
                    hFile = hFile + cL2 + CHR(10). 
                END. 
                INPUT CLOSE. 
                cCont = STRING(hFile). 
                IF LENGTH(cCont) > 4000 THEN cCont = SUBSTRING(cCont,1,4000) + "..truncated". oFiles:Add("server_xml", cCont). 
            END.
            ELSE oFiles:Add("server_xml_error", "not found").
            cFP = cPasoe + "\conf\jvm.options".
            IF SEARCH(cFP) <> ? THEN 
            DO: 
                hFile = "". 
                INPUT FROM VALUE(cFP). 
                REPEAT: 
                    DEFINE VARIABLE cL3 AS CHARACTER NO-UNDO. 
                    IMPORT UNFORMATTED cL3. 
                    hFile = hFile + cL3 + CHR(10). 
                END. 
                INPUT CLOSE. oFiles:Add("jvm_options", TRIM(STRING(hFile))). 
            END.
            ELSE oFiles:Add("jvm_options_error", "not found").
            oRes:Add("config_files", oFiles).
        END.
        /* Disk */
        IF cSect = "all" OR cSect = "disk" THEN 
        DO:
            oDisk = NEW Progress.Json.ObjectModel.JsonObject().
            OS-COMMAND SILENT VALUE("cmd /c dir " + CHR(34) + cPasoe + "\conf" + CHR(34) + " /b 1> " + CHR(34) + cTmp + CHR(34) + " 2>&1").
            IF SEARCH(cTmp) <> ? THEN 
            DO: 
                hFile = "". 
                INPUT FROM VALUE(cTmp). 
                REPEAT: 
                    DEFINE VARIABLE cL4 AS CHARACTER NO-UNDO. 
                    IMPORT UNFORMATTED cL4. 
                    hFile = hFile + cL4 + CHR(10). 
                END. 
                INPUT CLOSE. oDisk:Add("conf_files", TRIM(STRING(hFile))). 
                OS-DELETE VALUE(cTmp). 
            END.
            OS-COMMAND SILENT VALUE("cmd /c dir " + CHR(34) + cPasoe + "\logs" + CHR(34) + " /b 1> " + CHR(34) + cTmp + CHR(34) + " 2>&1").
            IF SEARCH(cTmp) <> ? THEN 
            DO: 
                hFile = "". 
                INPUT FROM VALUE(cTmp). 
                REPEAT: 
                    DEFINE VARIABLE cL5 AS CHARACTER NO-UNDO. 
                    IMPORT UNFORMATTED cL5. 
                    hFile = hFile + cL5 + CHR(10). 
                END. 
                INPUT CLOSE. oDisk:Add("log_files", TRIM(STRING(hFile))). 
                OS-DELETE VALUE(cTmp). 
            END.
            oRes:Add("disk", oDisk).
        END.
        RETURN CreateMcpResponseJson(id, oRes, false).
    END.
END CLASS.
