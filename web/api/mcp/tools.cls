 
/*------------------------------------------------------------------------
   File        : tools
   Author(s)   : colde
 ----------------------------------------------------------------------*/

USING Progress.Json.ObjectModel.*.
USING Progress.Lang.*.


BLOCK-LEVEL ON ERROR UNDO, THROW.


CLASS web.api.mcp.tools: 

    DEFINE STATIC TEMP-TABLE ttTool NO-UNDO SERIALIZE-NAME "tools"
        FIELD objectName  AS CHARACTER  
        FIELD objectStr   AS CHARACTER . 

    DEFINE PUBLIC VARIABLE ActiveToolsClasses AS CHAR EXTENT 17 NO-UNDO. 

    CONSTRUCTOR PUBLIC tools ( ):
       // Set active tools - for register tool in static temp-table
        ASSIGN 
            ActiveToolsClasses[1]  = "web.api.mcp.tools.read_progress_db" 
            ActiveToolsClasses[2]  = "web.api.mcp.tools.sales_pr_month"
            ActiveToolsClasses[3]  = "web.api.mcp.tools.send_office365_email"
            ActiveToolsClasses[4]  = "web.api.mcp.tools.powerpoint_for_pug"
            ActiveToolsClasses[5]  = "web.api.mcp.tools.turn_on_off_coffemachine".
            ActiveToolsClasses[6]  = "web.api.mcp.tools.schedule_task".
            ActiveToolsClasses[7]  = "web.api.mcp.tools.get_current_time".
            ActiveToolsClasses[8]  = "web.api.mcp.tools.get_customer_orders_summary".
            ActiveToolsClasses[9]  = "web.api.mcp.tools.get_progress_database_table_definition".
            ActiveToolsClasses[10] = "web.api.mcp.tools.get_progress_database_schema".
            ActiveToolsClasses[11] = "web.api.mcp.tools.query_progress_db_sql".
            ActiveToolsClasses[12] = "web.api.mcp.tools.create_abl_tool".
            ActiveToolsClasses[13] = "web.api.mcp.tools.read_abl_source".
            ActiveToolsClasses[14] = "web.api.mcp.tools.compile_abl_tool".
            ActiveToolsClasses[15] = "web.api.mcp.tools.execute_tool".
            ActiveToolsClasses[16] = "web.api.mcp.tools.get_customer_data".
            ActiveToolsClasses[17] = "web.api.mcp.tools.manage_scheduled_tasks".
               
        InitializeTools().
    END CONSTRUCTOR.

    METHOD PRIVATE VOID InitializeTools (). 
        var int iNumTools = extent(ActiveToolsClasses).
        var int iToolsCounter = 0 . 
        var web.api.mcp.tools.base.tool oTool. 
        
        EMPTY TEMP-TABLE ttTool. 
         
        do iToolsCounter = 1 to iNumTools : 
            IF ActiveToolsClasses[iToolsCounter] = "" THEN NEXT. 
            ActiveToolsClasses[iToolsCounter].
            oTool = DYNAMIC-NEW ActiveToolsClasses[iToolsCounter]().
            DELETE OBJECT oTool NO-ERROR. 
        end.  
    END. 

    METHOD PUBLIC STATIC VOID RegisterTool(ClassName AS CHAR, ToolDefinition AS LONGCHAR):
        DEF BUFFER bttTool FOR ttTool. 
        
        FIND FIRST bttTool WHERE bttTool.objectName = ClassName NO-ERROR.
        IF NOT AVAILABLE bttTool THEN CREATE bttTool . 
        
        bttTool.objectStr = toolDefinition. 
        bttTool.objectName = classname. 

        IF LOG-MANAGER:LOGFILE-NAME NE ? THEN 
               LOG-MANAGER:WRITE-MESSAGE('Registered Tool:' + bttTool.objectName,"LOG").
        
     /*   
        DEFINE VARIABLE oJsonObject   AS JsonObject  NO-UNDO.
        DEFINE VARIABLE oParser AS Progress.Json.ObjectModel.ObjectModelParser   NO-UNDO.
     //   MESSAGE objectName objectStr VIEW-AS ALERT-BOX. 
        oParser = NEW Progress.Json.ObjectModel.ObjectModelParser().
        oJsonObject   = CAST(oParser:Parse(bttTool.objectStr), JsonObject).
     //   message "ok:" objectStr view-as alert-box. 
     */
     
    END. 

    METHOD PUBLIC JsonArray getRegisteredTools():
       
        DEF BUFFER bttTool FOR ttTool. 
        DEFINE VARIABLE oParser AS Progress.Json.ObjectModel.ObjectModelParser   NO-UNDO.
        DEFINE VARIABLE oRoot   AS JsonArray  NO-UNDO.
        DEFINE VARIABLE oJsonObject   AS JsonObject  NO-UNDO.
        
        oRoot   = NEW JsonArray().
        
        FOR EACH bttTool: 
            IF LOG-MANAGER:LOGFILE-NAME NE ? THEN 
               LOG-MANAGER:WRITE-MESSAGE('ActiveTool:' + bttTool.objectName,"LOG").

//             message bttTool.objectName bttTool.objectStr view-as alert-box.
            
           oParser = NEW Progress.Json.ObjectModel.ObjectModelParser().
           oJsonObject   = CAST(oParser:Parse(bttTool.objectStr), JsonObject).
           oRoot:Add(oJsonObject).         
           DELETE OBJECT oParser NO-ERROR. 
        END.
        RETURN oRoot.   
    END. 

 
    /* Method to list and instantiate all tool classes in the package */
    METHOD PUBLIC VOID InstantiateAllTools():
        
        DEFINE BUFFER ttFoundTool FOR ttTool. 
        
        DEFINE VARIABLE cPackage   AS CHARACTER                   NO-UNDO INITIAL "web.api.mcp.tools".
        DEFINE VARIABLE cPath      AS CHARACTER                   NO-UNDO.
        DEFINE VARIABLE cFileName  AS CHARACTER                   NO-UNDO.
        DEFINE VARIABLE cClassName AS CHARACTER                   NO-UNDO.
        DEFINE VARIABLE cToolName  AS CHARACTER                   NO-UNDO.
        DEFINE VARIABLE oTool      AS web.api.mcp.tools.Base.Tool NO-UNDO.
     
        /* 1. Resolve the package name to a physical directory via PROPATH */
        cPath = SEARCH(REPLACE(cPackage, ".", "/")).
        IF cPath = ? OR cPath = "" THEN  UNDO, THROW NEW Progress.Lang.AppError("Tools directory not found: " + cPackage).
    
        /* 2. Iterate through the OS directory */
        INPUT FROM OS-DIR(cPath).
        REPEAT:
            IMPORT cFileName.
            /* Filter for source and compiled classes */
            IF cFileName MATCHES "*.cls" OR cFileName MATCHES "*.r" THEN 
            DO:
                cToolName = ENTRY(1, cFileName, ".").
                /* Skip the BaseTool definition and already processed tools */
                IF cToolName = "BaseTool" THEN NEXT.
                IF NOT CAN-FIND(ttFoundTool WHERE ttFoundTool.objectName = cToolName) THEN 
                DO:
                    CREATE ttFoundTool.
                    ttFoundTool.objectName = cToolName.
                    cClassName = cPackage + "." + cToolName.
                    /* 3. Wrap in CATCH to prevent one bad class from breaking the loop */
                    DO ON ERROR UNDO, NEXT:
                        oTool = DYNAMIC-NEW cClassName().
                        /* Execute your logic here, e.g., collect metadata */
                        MESSAGE "Successfully loaded: " cClassName VIEW-AS ALERT-BOX.
                        CATCH e AS Progress.Lang.Error:
                            MESSAGE "Error loading " cClassName ": " e:GetMessage(1) VIEW-AS ALERT-BOX.
                        END CATCH.
                        FINALLY:
                            IF VALID-OBJECT(oTool) THEN DELETE OBJECT oTool.
                        END FINALLY.
                    END. /* DO ON ERROR */
                END. /* NOT CAN-FIND */
            END. /* MATCHES */
        END. /* REPEAT */
        INPUT CLOSE.
    END METHOD.




END CLASS.