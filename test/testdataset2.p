/* Table for the properties within the schema */
DEFINE TEMP-TABLE ttProperty NO-UNDO  SERIALIZE-NAME "properties"
    FIELD SchemaRowID AS RECID SERIALIZE-HIDDEN
    FIELD TYPE        AS CHARACTER SERIALIZE-NAME "type" /* Note: JSON objects use keys, see below */
    FIELD Description AS CHARACTER SERIALIZE-NAME "description".
   

DEFINE TEMP-TABLE ttProperties NO-UNDO SERIALIZE-NAME "properties"
    FIELD ato      AS CHARACTER
    FIELD subject AS CHARACTER
    FIELD body    AS CHARACTER
    INDEX idxPrimary IS PRIMARY UNIQUE ato.

DEFINE TEMP-TABLE ttTo NO-UNDO SERIALIZE-NAME "to"
    FIELD PropertiesRowID AS RECID SERIALIZE-HIDDEN
    FIELD pType           AS CHARACTER SERIALIZE-NAME "type"
    FIELD pFormat         AS CHARACTER SERIALIZE-NAME "format"
    FIELD pdescription    AS CHARACTER SERIALIZE-NAME "description"
    .

    CREATE ttto . ptype = "string". 
DEFINE VARIABLE lcJSON AS LONGCHAR NO-UNDO.

DEFINE DATASET dsProperties FOR  ttTo .

CREATE ttProperties. ato = "type".

DATASET dsproperties:WRITE-JSON("LONGCHAR", lcJSON, TRUE).

MESSAGE STRING(lcJSON) VIEW-AS ALERT-BOX.
    
    
/*
DEFINE TEMP-TABLE ttRequired NO-UNDO
    FIELD schemaId AS CHARACTER
    FIELD name     AS CHARACTER     /* field name that is required */
    INDEX ixSchemaName IS UNIQUE schemaId name.
  
 
 
/* 2. Define the Dataset with all relations using ROWID */
DEFINE DATASET dsMcpResponse FOR ttRoot, ttResult ,  ttTool, ttInputSchema, ttProperty 
    PARENT-ID-RELATION rel1 FOR ttRoot, ttResult          PARENT-ID-FIELD RootRowID              
    PARENT-ID-RELATION rel2 FOR ttResult, ttTool          PARENT-ID-FIELD ResultRowID 
    PARENT-ID-RELATION rel3 FOR ttTool, ttInputSchema     PARENT-ID-FIELD ToolRowID 
    PARENT-ID-RELATION rel4 FOR ttInputSchema, ttProperty PARENT-ID-FIELD SchemaRowID .
*/                                                                            
