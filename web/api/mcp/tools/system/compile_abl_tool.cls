USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS web.api.mcp.tools.system.compile_abl_tool INHERITS web.api.mcp.tools.base.tool :

DEFINE TEMP-TABLE ttResult NO-UNDO
FIELD ToolName     AS CHARACTER LABEL "Tool"
FIELD ClassPath   AS CHARACTER LABEL "Class Path"
FIELD Success     AS LOGICAL   LABEL "Success"
FIELD ErrorMessage AS CHARACTER LABEL "Error"
FIELD ErrorRow    AS INTEGER   LABEL "Row"
FIELD ErrorColumn AS INTEGER   LABEL "Column"
.

    METHOD PUBLIC OVERRIDE JsonObject Execute(id AS integer, poArguments AS JsonObject):

        DEFINE VARIABLE oData AS JsonArray NO-UNDO.
        DEFINE VARIABLE cToolName  AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cClassPath AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cError     AS CHARACTER NO-UNDO.
        
        cToolName  = poArguments:GetCharacter("toolName").
      
        LOG-MANAGER:WRITE-MESSAGE("Compiling..." + cToolName ,"INFO").  
      
        cClassPath = web.api.mcp.tools:GetToolClassFileName(cToolname).
             
        IF SEARCH(cClassPath) <> ? THEN 
        DO:
            FILE-INFO:FILE-NAME = cClassPath.
            cClassPath = FILE-INFO:FULL-PATHNAME.
        END.     
        
        CREATE ttResult.
        ASSIGN ttResult.ToolName  = cToolName
               ttResult.ClassPath = cClassPath.
        
        COMPILE VALUE(cClassPath) SAVE  NO-ERROR.
        
        IF COMPILER:ERROR THEN DO:
            ASSIGN ttResult.Success      = FALSE
                   ttResult.ErrorMessage = COMPILER:GET-MESSAGE(1)
                   ttResult.ErrorRow     = COMPILER:ERROR-ROW
                   ttResult.ErrorColumn  = COMPILER:ERROR-COLUMN.
        END.
        ELSE DO:
            ASSIGN ttResult.Success      = TRUE
                   ttResult.ErrorMessage = "Compiled successfully".
        END.
        
        oData = NEW Progress.Json.ObjectModel.JsonArray().
        TEMP-TABLE ttResult:WRITE-JSON("JsonArray", oData, TRUE).
        RETURN CreateMcpResponseJson(id, oData, false).
        
    END.

END CLASS.
