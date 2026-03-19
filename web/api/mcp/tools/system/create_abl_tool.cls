 

USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS web.api.mcp.tools.system.create_abl_tool INHERITS web.api.mcp.tools.base.tool :  


    
    METHOD PUBLIC OVERRIDE Progress.Json.ObjectModel.JsonObject Execute(id AS integer, poArguments AS Progress.Json.ObjectModel.JsonObject):
    
        DEFINE VARIABLE cToolName  AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cClassFile AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cAblCode   AS longchar  NO-UNDO.
        DEFINE VARIABLE cJsonFile  AS CHARACTER NO-UNDO. 
        DEFINE VARIABLE cJsonDescription AS LONGCHAR NO-UNDO. 
    
        ASSIGN 
            cToolName  = poArguments:GetCharacter("tool_name").
            
            
            
            cClassFile = system.config:projectpath + "web/api/mcp/tools/automagic/" + cToolName + ".cls".
            cJsonFile  = system.config:projectpath + "web/api/mcp/tools/automagic/" + cToolName + ".json".
    
        /* 1. Generer .cls-filen fra template + brukerens kode */
        cAblCode = BuildClassFromTemplate(poArguments,OUTPUT cJsonDescription).
    
        /* 2. Skriv til disk */
        COPY-LOB FROM cAblCode         TO FILE cClassFile.
        COPY-LOB FROM cJsonDescription TO FILE cJsonFile.
    
        /* 3. Kompiler */
        COMPILE VALUE(cClassFile) SAVE.
    
        /* 4. Registrer i tool registry (slik at MCP-serveren eksponerer den) */
   //     RegisterTool(cToolName).
    
        RETURN CreateMcpResponseText(id, "Tool created: " + cToolName, false).
     
        CATCH e AS Progress.Lang.Error:
            LOG-MANAGER:WRITE-MESSAGE("Create ABL. Tool error","ERR").
            
            
            DEFINE VARIABLE iLoop AS INTEGER NO-UNDO.
            DEFINE VARIABLE cFullErr AS CHARACTER NO-UNDO.
        
           /* 1. Build a detailed error string: "Error 75: Record not found | Error 123: ..." */
            DO iLoop = 1 TO e:NumMessages:
                cFullErr = cFullErr 
                         + (IF cFullErr > "" THEN " | " ELSE "") 
                         + "Error " + STRING(e:GetMessageNum(iLoop)) + ": " 
                         + e:GetMessage(iLoop).
            END.
        
            /* 2. Log it specifically for server-side debugging */
            LOG-MANAGER:WRITE-MESSAGE(SUBSTITUTE("Create ABL. Tool Error [&1]: &2", cToolName, cFullErr), "ERR").
            
            RETURN CreateMcpResponseText(id,cFullErr,true).
        END CATCH. 
    END. 
    
    
    METHOD PRIVATE LONGCHAR BuildClassFromTemplate(poArgs AS Progress.Json.ObjectModel.JsonObject, OUTPUT cJsonDescription AS LONGCHAR):

    DEFINE VARIABLE cOut      AS LONGCHAR  NO-UNDO.
    DEFINE VARIABLE cName     AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cDesc     AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cBody     AS CHARACTER NO-UNDO.
    DEFINE VARIABLE oParams   AS Progress.Json.ObjectModel.JsonArray NO-UNDO.
    DEFINE VARIABLE oTables   AS Progress.Json.ObjectModel.JsonArray NO-UNDO.
    DEFINE VARIABLE i         AS INTEGER   NO-UNDO.
    DEFINE VARIABLE cTT       AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cProps    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cRequired AS CHARACTER NO-UNDO.
    DEFINE VARIABLE oP        AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
    DEFINE VARIABLE oT        AS Progress.Json.ObjectModel.JsonObject NO-UNDO.

    ASSIGN
        cName   = poArgs:GetCharacter("tool_name")
        cDesc   = poArgs:GetCharacter("tool_description")
        cBody   = poArgs:GetCharacter("abl_code")
        oParams = poArgs:GetJsonArray("parameters")
        oTables = poArgs:GetJsonArray("temp_tables") NO-ERROR.

    /* Build inputSchema JSON from parameters array */
    DO i = 1 TO oParams:Length:
        oP = oParams:GetJsonObject(i).
        cProps = cProps + '"' + oP:GetCharacter("name") + '": ~{"type": "'
            + oP:GetCharacter("type") + '", "description": "'
            + oP:GetCharacter("description") + '"~},'.
        IF oP:Has("required") AND oP:GetLogical("required") THEN
            cRequired = cRequired + '"' + oP:GetCharacter("name") + '",'.
    END.

    /* Trim trailing commas */
    IF cProps    <> "" THEN cProps    = SUBSTRING(cProps,    1, LENGTH(cProps)    - 1).
    IF cRequired <> "" THEN cRequired = SUBSTRING(cRequired, 1, LENGTH(cRequired) - 1).

    /* Build temp-table definitions */
    IF VALID-OBJECT(oTables) THEN
    DO i = 1 TO oTables:Length:
        oT  = oTables:GetJsonObject(i).
        cTT = cTT + "DEFINE TEMP-TABLE " + oT:GetCharacter("name") + " NO-UNDO~n"
            + oT:GetCharacter("fields") + ".~n~n".
    END.

    /* Assemble .cls */
    cOut =
          "USING Progress.Lang.*.~n"
        + "USING Progress.Json.ObjectModel.*.~n"
        + "BLOCK-LEVEL ON ERROR UNDO, THROW.~n"
        + "CLASS web.api.mcp.tools.automagic." + cName + " INHERITS web.api.mcp.tools.base.tool :~n~n"
        + cTT
        + "    METHOD PUBLIC OVERRIDE JsonObject Execute(id AS integer, poArguments AS JsonObject):~n"
        + cBody + "~n~n"
        + "    END.~n~nEND CLASS.~n".

    /* Assemble .json */
    cJsonDescription =
          '~{~n'
        + '  "name": "' + cName + '",~n'
        + '  "description": "' + cDesc + '",~n'
        + '  "inputSchema": ~{~n'
        + '    "type": "object",~n'
        + '    "properties": ~{' + cProps + '~},~n'
        + '    "required": [' + cRequired + ']~n'
        + '  ~}~n'
        + '~}'.

    RETURN cOut.

END METHOD.
END CLASS.