DEFINE VARIABLE s AS CHARACTER NO-UNDO. 
S = '
~{
  user~(id: $userId) ~{
    id
    name
    email
    posts(filter: ~{ category: "electronics" ~}, sort: ~{ price: ASC ~}) ~{
      id
      title
      content
      comments ~{
        id
        text
        author(filter: ~{ 
    location: "New York",
    eventDate: ~{ lt: "2025-06-01" ~}
  ~})~{
          id
          name
        ~}
      ~}
    ~}
  ~}
~}' .




DEFINE TEMP-TABLE QueryTable NO-UNDO
    FIELD TableName            AS CHARACTER
    FIELD Level                AS INTEGER
    FIELD QueryTable_id_parent AS ROWID. 

DEFINE TEMP-TABLE QueryFilter NO-UNDO 
    FIELD FilterFieldName  AS CHARACTER 
    FIELD FilterFieldValue AS CHARACTER 
    FIELD FilterType       AS CHARACTER 
    FIELD QueryTable_id    AS ROWID. 

DEFINE TEMP-TABLE QueryField NO-UNDO 
    FIELD FieldName     AS CHARACTER 
    FIELD FieldValue    AS CHARACTER 
    FIELD QueryTable_id AS ROWID. 
  
DEFINE VARIABLE iLevel            AS INTEGER NO-UNDO. 
DEFINE VARIABLE icnt              AS INTEGER NO-UNDO. 
DEFINE VARIABLE CurrentTableRowid AS ROWID. 


FUNCTION addQueryTable RETURNS ROWID (parentRowid AS ROWID,TableName AS CHARACTER,iLevel AS INTEGER) : 
    CREATE QueryTable.               
    QueryTable.tablename = tableName.
    QueryTable.QueryTable_id_parent = parentRowid.
    QueryTable.level = iLevel. 
    RETURN ROWID(QueryTable).
END. 

FUNCTION addQueryField RETURNS ROWID (parentRowid AS ROWID,FieldName AS CHARACTER) : 
    CREATE QueryField.               
    QueryField.fieldname = fieldname.
    QueryField.QueryTable_id = parentrowid. 
    RETURN ROWID(QueryField).
END. 

FUNCTION addQueryFilter RETURNS ROWID (parentRowid AS ROWID,filtername AS CHARACTER,ctype AS CHARACTER, filtervalue AS CHARACTER) : 
    LOG-MANAGER:WRITE-MESSAGE ("addQueryFilter:" + filtername + "#" + filtervalue, "Q-FILTER"). 
    CREATE QueryFilter.       
    QueryFilter.FilterFieldValue = filtervalue.
    QueryFilter.filterFieldName  = filtername.
    QueryFilter.filterType  = ctype.
    QueryFilter.QueryTable_id    = parentrowid.   
    RETURN ROWID(QueryField).
END. 



LOG-MANAGER:LOGFILE-NAME = "C:\temp\log2.txt".   


/* Recursive field parser */
PROCEDURE ParseFieldsRecursive:
    DEFINE INPUT  PARAMETER piParentId AS INTEGER  NO-UNDO.
    DEFINE INPUT  PARAMETER piDepth    AS INTEGER  NO-UNDO.
    DEFINE INPUT  PARAMETER pcInput    AS LONGCHAR NO-UNDO.
    DEFINE INPUT  PARAMETER piStart    AS INTEGER  NO-UNDO.
    DEFINE OUTPUT PARAMETER piEnd      AS INTEGER  NO-UNDO.

    DEFINE VARIABLE i         AS INTEGER   NO-UNDO.
    DEFINE VARIABLE cChar     AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cBuffer   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lInString AS LOGICAL   NO-UNDO.
    DEFINE VARIABLE iArgStart AS INTEGER   NO-UNDO.
    DEFINE VARIABLE cArgument AS CHARACTER NO-UNDO. 
   
          
    DO i = piStart TO LENGTH(pcInput):
        cChar = SUBSTRING(pcInput, i, 1).
    
        CASE cChar:
            WHEN '"' THEN 
                lInString = NOT lInString.
            WHEN '(' THEN 
                DO:
                    IF NOT lInString THEN 
                    DO:
                        IF cBuffer <> "" THEN 
                        DO:
                            LOG-MANAGER:WRITE-MESSAGE ("CreateTable:" +  cBuffer + " " + STRING(piDepth),"Table"). 
                            CurrentTableRowid = addQueryTable(CurrentTableRowid,cBuffer,piDepth). 
                        END. 
                        cBuffer = "".
     
                        iArgStart = i.
                        /* Parse arguments when closing ')' is found */
                        DO i = i + 1 TO LENGTH(pcInput):
                            IF SUBSTRING(pcInput, i, 1) = ')' AND NOT lInString THEN 
                            DO:
                                cArgument = SUBSTRING(pcInput,iArgStart + 1,i - iArgStart - 1).
                                RUN ProcessArguments(INPUT CurrentTableRowid, INPUT cArgument,INPUT piParentId).
                                cBuffer = "".
                                LEAVE.
                            END.
                        END.
                    END.
                END.
      
            WHEN '~{' THEN 
                DO:
         
                    IF NOT lInString THEN 
                    DO:
                        /* Create field from buffer */
                        IF cBuffer <> "" THEN 
                        DO:  
                            cBuffer = TRIM(cBuffer). 
                            LOG-MANAGER:WRITE-MESSAGE ("CreateTable:" +  cBuffer + " " + STRING(piDepth),"Table"). 
                            CurrentTableRowid = addQueryTable(CurrentTableRowid,cBuffer,piDepth). 
                        END. 
                        cBuffer = "".
                        /* Recursive call for nested fields */
                        RUN ParseFieldsRecursive(
                            INPUT  piParentId,
                            INPUT  piDepth + 1,
                            INPUT  pcInput,
                            INPUT  i + 1,
                            OUTPUT piEnd
                            ).
                        i = piEnd. /* Jump to end of nested block */
                    END.
                END.
      
            WHEN '~}' THEN 
                DO:
                    IF NOT lInString THEN 
                    DO:
                        IF cBuffer <> "" THEN 
                        DO:
                            LOG-MANAGER:WRITE-MESSAGE ("CreateField:" +  cBuffer + " " + STRING(piDepth),"Field"). 
                            addQueryField(CurrentTableRowid,cBuffer). 
                        END. 
                        piEnd = i.
                        RETURN.
                    END.
                END.
      
            WHEN ',' THEN 
                DO:
                    IF NOT lInString THEN 
                    DO:
                        IF cBuffer <> "" THEN 
                        DO:
                            LOG-MANAGER:WRITE-MESSAGE ("CreateField:" +  cBuffer + " " + STRING(piDepth),"Field"). 
                            addQueryField(CurrentTableRowid,cBuffer). 
                        END. 
                        cBuffer = "".
                    END.
                END.
      // field sep
            WHEN ' ' THEN 
                DO:
                    IF NOT lInString THEN 
                    DO:
                        IF SUBSTRING(pcInput, i + 1, 1) = '~{' AND cBuffer <> "" THEN 
                        DO:
                            cBuffer = TRIM(cBuffer). 
                            LOG-MANAGER:WRITE-MESSAGE ("CreateTable:" +  cBuffer + " " + STRING(piDepth),"Table"). 
                            CurrentTableRowid = addQueryTable(CurrentTableRowid,cBuffer,piDepth). 
                            cBuffer = "". 
                        END. 
       
                        IF cBuffer <> "" THEN 
                        DO:
                            LOG-MANAGER:WRITE-MESSAGE ("CreateField:" +  cBuffer + " " + STRING(piDepth),"Field"). 
                            addQueryField(CurrentTableRowid,cBuffer). 
                        END. 
                        cBuffer = "".
                    END.
                END.

            OTHERWISE 
            DO:
                cBuffer = cBuffer + cChar.
        
            END.
        END CASE.
    END.
END PROCEDURE.


FUNCTION isOperator RETURNS LOGICAL (cStatement AS CHARACTER) : 
    RETURN LOOKUP(cStatement,"GE,LT,EQ") NE 0.
END. 


PROCEDURE ProcessArguments:
    DEFINE INPUT PARAMETER parentrowid AS ROWID NO-UNDO. 
    DEFINE INPUT PARAMETER pcArgs    AS CHARACTER    NO-UNDO.
    DEFINE INPUT PARAMETER piFieldId AS INTEGER NO-UNDO.

    DEFINE VARIABLE i        AS INTEGER   NO-UNDO.
    DEFINE VARIABLE cArgPair AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cName    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cValue   AS CHARACTER NO-UNDO.
  
    LOG-MANAGER:WRITE-MESSAGE("ProcessArguments:" + STRING(pcArgs),"DEBUG").
  
  
    DEFINE VARIABLE cBuffer        AS CHARACTER. 
    DEFINE VARIABLE cchar          AS CHARACTER.
    DEFINE VARIABLE Argumenttype   AS CHARACTER INIT "filter" NO-UNDO.
    DEFINE VARIABLE lAssignedValue AS LOGICAL   INIT TRUE NO-UNDO. 
    DEFINE VARIABLE ctmp           AS CHARACTER NO-UNDO. 
  
    DO i = 1 TO LENGTH(pcArgs):
        cChar = SUBSTRING(pcArgs, i, 1).
        CASE cChar:
            WHEN ':' THEN  // end of field 
                DO:  
                    IF NOT isOperator(LEFT-TRIM(TRIM(cbuffer))) THEN 
                    DO:
                        cname = LEFT-TRIM(TRIM(cbuffer)). 
                        cBuffer = "".
              
                        IF LOOKUP(cname,"sort,filter") NE 0  THEN
                        DO:
                            ArgumentType = cname.       
                        END.
                        ELSE lAssignedValue = FALSE. 
                    END. 
                END.
            WHEN '~{' THEN 
                DO:
                    cbuffer = "".
                END.
            WHEN '~}' THEN 
                IF NOT lAssignedValue THEN 
                DO:
                    addQueryFilter(parentRowId,cname,ArgumentType,cbuffer).
                    LOG-MANAGER:WRITE-MESSAGE("1 field:" + STRING(cname) + ":" + left-trim(TRIM(cbuffer)) + " " + ArgumentType  ,"DEBUG").
                    lAssignedValue = TRUE.               
                    cbuffer = "".
                END.
            WHEN ',' THEN 
                IF NOT lAssignedValue THEN 
                DO:
                    addQueryFilter(parentRowId,cname,ArgumentType,cbuffer).
                    LOG-MANAGER:WRITE-MESSAGE("2 field:" + STRING(cname) + ":" + left-trim(TRIM(cbuffer)) + " " + ArgumentType ,"DEBUG").
                    lAssignedValue = TRUE. 
                    cbuffer = "".
                END.
            OTHERWISE 
            DO:
                cBuffer = cBuffer + cChar.
            END.
        END CASE.
    END.
  
    IF NOT lAssignedValue THEN
    DO:
        addQueryFilter(parentRowId,cname,ArgumentType,cbuffer).
        LOG-MANAGER:WRITE-MESSAGE("3 field:" + STRING(cname) + ":" + left-trim(TRIM(cbuffer)) + " " + ArgumentType ,"DEBUG").
    END.
    
END PROCEDURE.

PROCEDURE log-Query:

    FOR EACH queryTable NO-LOCK: 
        LOG-MANAGER:WRITE-MESSAGE ("Table:" + queryTable.tablename, ""). 
        FOR EACH queryFilter WHERE queryFilter.QueryTable_id = ROWID(queryTable): 
            LOG-MANAGER:WRITE-MESSAGE ("   " + queryFilter.FilterType + ":" + queryFilter.FilterFieldName + ":" + queryFilter.FilterFieldValue, ""). 
        END.                    
        FOR EACH QueryField WHERE QueryField.QueryTable_id = ROWID(queryTable):
            LOG-MANAGER:WRITE-MESSAGE ("      Field:" + queryTable.tablename + ":" + queryfield.fieldname, ""). 
        END. 
    END.
END. 


PROCEDURE ParseGraphQL:
    DEFINE INPUT PARAMETER pcQuery AS LONGCHAR NO-UNDO.

    DEFINE VARIABLE cCleaned    AS LONGCHAR  NO-UNDO.
    DEFINE VARIABLE iPos        AS INTEGER   NO-UNDO.
    DEFINE VARIABLE cCurrent    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cBuffer     AS CHARACTER NO-UNDO.
    DEFINE VARIABLE iBraceDepth AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lInString   AS LOGICAL   NO-UNDO.
    DEFINE VARIABLE lInField    AS LOGICAL   NO-UNDO.

    /* Clean query (basic normalization) */
    cCleaned = REPLACE(pcQuery, '~n', ' ').
    cCleaned = REPLACE(cCleaned, '  ', ' ').
    cCleaned = REPLACE(cCleaned, '  ', ' ').
    cCleaned = REPLACE(cCleaned, '  ', ' ').
    cCleaned = TRIM(cCleaned).

    /* Parse operation header 
    RUN ParseOperationHeader (
      INPUT  cCleaned,
      OUTPUT iPos
    ).
    */
   
    /* Recursive field parsing */
    RUN ParseFieldsRecursive (
        INPUT  0,        /* parentId */
        INPUT  0,        /* depth */
        INPUT  cCleaned,
        INPUT  iPos + 1, /* start position */
        OUTPUT iPos
        ).

END PROCEDURE.

RUN ParseGraphQL(s). 


LOG-MANAGER:CLOSE-LOG().
