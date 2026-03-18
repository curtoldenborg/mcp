

DEFINE TEMP-TABLE ttSelection NO-UNDO
    FIELD ParentID      AS RECID
    FIELD FieldName     AS CHARACTER
    FIELD AliasName     AS CHARACTER
    FIELD TypeCondition AS CHARACTER    /* For inline fragments */
    FIELD HasFragments  AS LOG
    FIELD IsFragment    AS LOG
    FIELD IsInline      AS LOG
    FIELD DirectiveID   AS RECID
    FIELD Depth         AS INTEGER
    FIELD SelectionID   AS RECID.

DEFINE TEMP-TABLE ttDirective NO-UNDO
    FIELD ParentID      AS RECID    /* Can be operation or selection */
    FIELD DirectiveName AS CHARACTER
    FIELD Arguments     AS CHARACTER    /* Serialized arguments */
    FIELD DirectiveID   AS RECID.

DEFINE TEMP-TABLE ttFragment NO-UNDO
    FIELD FragmentName AS CHARACTER
    FIELD OnType       AS CHARACTER
    FIELD SelectionID  AS RECID.

DEFINE TEMP-TABLE ttVariable NO-UNDO
    FIELD VariableName AS CHARACTER
    FIELD VariableType AS CHARACTER
    FIELD DefaultValue AS CHARACTER.

DEFINE TEMP-TABLE ttArgument NO-UNDO
    FIELD OwnerType  AS CHARACTER     /* "Selection" or "Directive" */
    FIELD OwnerID    AS RECID
    FIELD ArgName    AS CHARACTER
    FIELD ArgValue   AS CHARACTER
    FIELD IsVariable AS LOG.


DEFINE TEMP-TABLE QueryTable NO-UNDO
    FIELD TableName             AS CHARACTER
    FIELD tablenameAlias        AS CHARACTER
    FIELD Level                 AS INTEGER
    FIELD TableHandle           AS HANDLE 
    FIELD PrimaryKey            AS CHARACTER 
    FIELD QueryWhere            AS CHARACTER 
    FIELD isObjectFunction      AS LOGICAL 
    FIELD TableDatasourceHandle AS HANDLE
    FIELD DatabaseBufferHandle  AS HANDLE
    FIELD QueryTable_id_parent  AS ROWID     serialize-hidden
    FIELD QueryTable_id         AS ROWID     serialize-hidden. 
    
DEFINE TEMP-TABLE QueryFilter NO-UNDO 
    FIELD FilterFieldName  AS CHARACTER 
    FIELD FilterFieldValue AS CHARACTER 
    FIELD FilterType       AS CHARACTER 
    FIELD QueryTable_id    AS ROWID     serialize-hidden. 
    
DEFINE TEMP-TABLE QueryField NO-UNDO 
    FIELD FieldName     AS CHARACTER 
    FIELD FieldValue    AS CHARACTER 
    FIELD QueryTable_id AS ROWID     serialize-hidden . 
  
DEFINE PUBLIC VARIABLE hQueryDataset       AS HANDLE NO-UNDO. 
DEFINE PUBLIC VARIABLE hQueryResultDataSet AS HANDLE NO-UNDO. 
    
DEFINE DATASET dsQuery FOR QueryTable, QueryFilter, QueryField
    DATA-RELATION relationQueryFilter FOR QueryTable, QueryFilter
    RELATION-FIELDS (QueryTable_id, QueryTable_id) NESTED
    DATA-RELATION relationQueryField FOR QueryTable, QueryField
    RELATION-FIELDS (QueryTable_id, QueryTable_id) NESTED
    .
 
 
 