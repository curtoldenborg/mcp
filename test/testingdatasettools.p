
/* 1. Define Temp-Tables from top to bottom */

DEFINE TEMP-TABLE ttRoot NO-UNDO  SERIALIZE-NAME "root" /* This is the top-level container */
    FIELD jsonrpc   AS CHARACTER INITIAL "2.0"
    FIELD id        AS INTEGER   INITIAL 1.

DEFINE TEMP-TABLE ttResult NO-UNDO SERIALIZE-NAME "result"
    FIELD RootRowID AS RECID SERIALIZE-HIDDEN.

DEFINE TEMP-TABLE ttTool NO-UNDO   SERIALIZE-NAME "tools"
    FIELD ResultRowID AS RECID SERIALIZE-HIDDEN
    FIELD Name        AS CHARACTER SERIALIZE-NAME "name"
    FIELD Description AS CHARACTER SERIALIZE-NAME "description".

DEFINE TEMP-TABLE ttInputSchema NO-UNDO SERIALIZE-NAME "inputSchema"
    FIELD ToolRowID   AS RECID SERIALIZE-HIDDEN
    FIELD SchemaType  AS CHARACTER SERIALIZE-NAME "type" INIT "object".

/* Table for the properties within the schema */
DEFINE TEMP-TABLE ttProperty NO-UNDO  SERIALIZE-NAME "properties"
    FIELD SchemaRowID AS RECID SERIALIZE-HIDDEN
    FIELD PropName    AS CHARACTER SERIALIZE-NAME "name" /* Note: JSON objects use keys, see below */
    FIELD Description AS CHARACTER SERIALIZE-NAME "description".
                                                         
/* 2. Define the Dataset with all relations using ROWID */
DEFINE DATASET dsMcpResponse FOR ttRoot, ttResult ,  ttTool, ttInputSchema, ttProperty 
    PARENT-ID-RELATION rel1 FOR ttRoot, ttResult          PARENT-ID-FIELD RootRowID              
    PARENT-ID-RELATION rel2 FOR ttResult, ttTool          PARENT-ID-FIELD ResultRowID 
    PARENT-ID-RELATION rel3 FOR ttTool, ttInputSchema     PARENT-ID-FIELD ToolRowID 
    PARENT-ID-RELATION rel4 FOR ttInputSchema, ttProperty PARENT-ID-FIELD SchemaRowID .
                                                                            
 .
   
        
        
    /*    
    DEFINE DATASET dsMcpResponse FOR ttRoot, ttResult, ttTool, ttInputSchema, ttProperty

    DATA-RELATION rel2 FOR ttResult, ttTool 
        RELATION-FIELDS (RootRowID, ResultRowID) NESTED FOREIGN-KEY-HIDDEN
    DATA-RELATION rel3 FOR ttTool, ttInputSchema 
        RELATION-FIELDS (ResultRowID, ToolRowID) NESTED FOREIGN-KEY-HIDDEN
    DATA-RELATION rel4 FOR ttInputSchema, ttProperty 
        RELATION-FIELDS (ToolRowID, SchemaRowID) NESTED FOREIGN-KEY-HIDDEN.
           */
/* 3. Populate the data */

CREATE ttRoot.
CREATE ttResult. 
    ttResult.RootRowID = STRING(ROWID(ttRoot)).

CREATE ttTool.
ASSIGN ttTool.ResultRowID = STRING(ROWID(ttResult))
       ttTool.Name        = "read_progress_db"
       ttTool.Description = "Queries the OpenEdge database...".

CREATE ttInputSchema.
ASSIGN ttInputSchema.ToolRowID  = STRING(ROWID(ttTool))
       ttInputSchema.SchemaType = "object".

CREATE ttProperty.
ASSIGN ttProperty.SchemaRowID = STRING(ROWID(ttInputSchema))
       ttProperty.PropName    = "tableName"
       ttProperty.PropType    = "string"
       ttProperty.Description = "The table name (e.g., Customer)".

/* 4. Generate the JSON */

DEFINE VARIABLE oJson AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
oJson = NEW Progress.Json.ObjectModel.JsonObject().
oJson:ReadDataset(DATASET dsMcpResponse:HANDLE).

/* IMPORTANT: ReadDataset includes the 'root' name. 
   To get the exact JSON-RPC format, we pull the object OUT of the 'root' */
oJson = oJson:GetJsonObject("root"). 
