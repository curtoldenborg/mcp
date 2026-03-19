 

USING Progress.Json.ObjectModel.*.
USING Progress.Lang.*.
USING System.IO.*.
USING System.Array.*.    

BLOCK-LEVEL ON ERROR UNDO, THROW.


CLASS web.api.mcp.tools: 
    
    DEFINE PUBLIC STATIC PROPERTY ToolsAreInstantiated AS LOGICAL GET. PRIVATE SET.
    DEFINE PUBLIC STATIC PROPERTY ToolsActiveReload    AS LOGICAL INIT FALSE GET. PRIVATE SET.

    DEFINE STATIC TEMP-TABLE ttTool NO-UNDO SERIALIZE-NAME "tools"
        FIELD objectClassName     AS CHARACTER  
        FIELD objectToolName      AS CHARACTER
        FIELD objectStr           AS CHARACTER 
        FIELD objectClassFileName AS CHARACTER 
        . 

    CONSTRUCTOR PUBLIC tools ( ):
          EMPTY TEMP-TABLE ttTool. 
          InstantiateAllTools().
          
    END CONSTRUCTOR.
  
    METHOD PUBLIC STATIC VOID RegisterTool(ClassName AS CHAR, ToolDefinition AS LONGCHAR):
        DEF BUFFER bttTool FOR ttTool. 
        
        FIND FIRST bttTool WHERE bttTool.objectClassName = ClassName NO-ERROR.
        IF NOT AVAILABLE bttTool THEN CREATE bttTool . 
        
        bttTool.objectStr           = toolDefinition. 
        bttTool.objectClassName     = classname. 
        bttTool.objectToolName      = ENTRY(NUM-ENTRIES(classname, "."), classname, ".").
        bttTool.objectClassFileName = REPLACE(classname,".","\") + ".cls".

        IF LOG-MANAGER:LOGFILE-NAME NE ? AND NEW bttTool THEN
           LOG-MANAGER:WRITE-MESSAGE('Registered Tool:' + bttTool.objectToolName,"LOG").
    END. 

    METHOD PUBLIC STATIC CHAR GetToolClassName(ToolName AS CHAR):
         DEF BUFFER bttTool FOR ttTool.
         FIND FIRST bttTool WHERE bttTool.objectToolName = ToolName NO-ERROR.
         IF AVAIL bttTool THEN RETURN bttTool.objectClassName .
         RETURN "-- Something wrong here --".
    END. 

    METHOD PUBLIC STATIC CHAR GetToolClassFileName(ToolName AS CHAR):
         DEF BUFFER bttTool FOR ttTool.
         FIND FIRST bttTool WHERE bttTool.objectToolName = ToolName NO-ERROR.
         IF AVAIL bttTool THEN RETURN bttTool.objectClassFileName .
         RETURN ?.
    END. 


    METHOD PUBLIC JsonArray getRegisteredTools():
        DEF BUFFER bttTool FOR ttTool. 
        DEFINE VARIABLE oParser AS Progress.Json.ObjectModel.ObjectModelParser   NO-UNDO.
        DEFINE VARIABLE oRoot   AS JsonArray  NO-UNDO.
        DEFINE VARIABLE oJsonObject   AS JsonObject  NO-UNDO.
        
        oRoot   = NEW JsonArray().
        
        FOR EACH bttTool: 
            IF LOG-MANAGER:LOGFILE-NAME NE ? THEN 
               LOG-MANAGER:WRITE-MESSAGE('ActiveTool:' + bttTool.objectToolName,"LOG").

//         message bttTool.objectName bttTool.objectStr view-as alert-box.
            
           oParser = NEW Progress.Json.ObjectModel.ObjectModelParser().
           oJsonObject   = CAST(oParser:Parse(bttTool.objectStr), JsonObject).
           oRoot:Add(oJsonObject).         
           DELETE OBJECT oParser NO-ERROR. 
        END.
        RETURN oRoot.   
    END. 
 
    
    /* Method to list and instantiate all tool classes in the package */
    METHOD PUBLIC VOID InstantiateAllTools():
         web.api.mcp.tools:InstantiateToolsInDirectory('web\api\mcp\tools\system') . 
         web.api.mcp.tools:InstantiateToolsInDirectory('web\api\mcp\tools\system\database') .
         web.api.mcp.tools:InstantiateToolsInDirectory('web\api\mcp\tools\system\pasoe') .
         web.api.mcp.tools:InstantiateToolsInDirectory('web\api\mcp\tools\automagic').
         web.api.mcp.tools:InstantiateToolsInDirectory('web\api\mcp\tools').
         ToolsAreInstantiated = TRUE.
    END. 
    
    
    METHOD PUBLIC STATIC CHARACTER EXTENT InstantiateToolsInDirectory(cDirectory AS CHAR):
        DEFINE VARIABLE cFiles      AS "System.String[]" NO-UNDO.
        DEFINE VARIABLE cFileList   AS CHARACTER         EXTENT NO-UNDO.
        DEFINE VARIABLE iLoop       AS INTEGER           NO-UNDO.
        var web.api.mcp.tools.base.tool oTool. 
        
        /* 1. Get the .NET String Array */
        cFiles = Directory:GetFiles(system.config:projectpath + cDirectory, "*.cls").
        
        /* 2. Check if we found anything */
        IF VALID-OBJECT(cFiles) AND cFiles:Length > 0 THEN 
        DO:
            /* 3. Initialize the ABL Extent to the correct size */
            EXTENT(cFileList) = cFiles:Length.
            
            /* 4. Map .NET array to ABL array */
            DO iLoop = 0 TO cFiles:Length - 1:
                /* ABL Extents are 1-based, .NET Arrays are 0-based */
                cFileList[iLoop + 1] = STRING(cFiles:GetValue(iLoop)).

                cFileList[iLoop + 1] = REPLACE(cFileList[iLoop + 1], system.config:projectpath, "").
                
                /* 2. Remove leading slash if it exists */
                IF LEFT-TRIM(cFileList[iLoop + 1], "/\") <> cFileList[iLoop + 1] THEN
                    cFileList[iLoop + 1] = SUBSTRING(cFileList[iLoop + 1], 2).
    
                /* 3. Remove the .cls extension */
                IF cFileList[iLoop + 1] MATCHES "*.cls" THEN
                   cFileList[iLoop + 1] = SUBSTRING(cFileList[iLoop + 1], 1, LENGTH(cFileList[iLoop + 1]) - 4).
                
                /* 4. Optional: Convert slashes to dots for ABL class notation */
                cFileList[iLoop + 1] = REPLACE(REPLACE(cFileList[iLoop + 1], "/", "."), "\", ".").
      
       //         MESSAGE  STRING(cFileList[iLoop + 1]) VIEW-AS ALERT-BOX.
                
                // if some tools does not compile - skip it and log 
                // could be in development ... 
                oTool = DYNAMIC-NEW cFileList[iLoop + 1]() NO-ERROR.
                IF ERROR-STATUS:ERROR AND LOG-MANAGER:LOGFILE-NAME NE ? THEN
                       LOG-MANAGER:WRITE-MESSAGE('Tool does not compile:' + cFileList[iLoop + 1],"ERROR").
                     
                
                DELETE OBJECT oTool NO-ERROR. 
            END.
        END.
    
        /* 5. Return the ABL Array */
        RETURN cFileList.
    END METHOD.
    
   
END CLASS.