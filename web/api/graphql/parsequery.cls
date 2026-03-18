


USING Progress.Lang.*.
using web.api.graphql.StringConstant.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS web.api.graphql.parsequery: 

    DEFINE         VARIABLE graphqlquery      as char    no-undo. 
    DEFINE         VARIable ilevelcouter      as int     no-undo. 
    DEFINE         VARIABLE graphqlDataset    as handle  no-undo. 
    DEFINE PRIVATE VARIABLE iLevel            AS INTEGER NO-UNDO. 
    DEFINE PRIVATE VARIABLE icnt              AS INTEGER NO-UNDO. 
    DEFINE PRIVATE VARIABLE CurrentTableRowid AS ROWID   NO-UNDO. 
 
    {web/api/graphql/querydataset.i }
 
    CONSTRUCTOR PUBLIC parsequery ():
        SUPER ().
        DATASET dsQuery:SERIALIZE-HIDDEN = TRUE. 
        hQueryDataSet = DATASET dsQuery:handle. 
    END CONSTRUCTOR.
 
    /*
query {
  posts_aggregate {
    aggregate {
      count
    }
  }
}*/ 

    METHOD VOID LOG-WRITE-MESSAGE (input pcmessage as char,input pctype AS CHAR):
        IF LOG-MANAGER:LOGFILE-NAME NE ? THEN 
           LOG-MANAGER:WRITE-MESSAGE (pcmessage, pcType). 
    END. 


    
    METHOD handle BuildQuery ():
    /*
       METHOD PUBLIC web.IBusinessEntity getBusinessEntity (classobject AS CHARACTER ): 
      
        DEFINE VARIABLE dynObject     AS web.IBusinessEntity NO-UNDO.
        DEFINE VARIABLE DynamicObject AS CHARACTER   INIT 'web.DynamicEntity' NO-UNDO. 
        
        dynObject = DYNAMIC-NEW classobject () .
        IF VALID-OBJECT(DynObject) THEN    
            LOG-MANAGER:WRITE-MESSAGE("BusinessEntity Started: " + quoter(classobject),"JSDO" ).
        ELSE 
        DO:
            LOG-MANAGER:WRITE-MESSAGE("web.DynamicEntity Started:Table:" + quoter(classobject) ,"JSDO" ).
            dynObject = DYNAMIC-NEW DynamicObject (classobject) .
        END. 


       FOR EACH queryTable NO-LOCK: 
            LOG-WRITE-MESSAGE ("Table:" + queryTable.tablename, ""). 
            FOR EACH queryFilter WHERE queryFilter.QueryTable_id = ROWID(queryTable): 
           
//                MESSAGE ("   " + queryFilter.FilterType + ":" + queryFilter.FilterFieldName + ":" + queryFilter.FilterFieldValue, ""). 
            END.         
       END.
       */    
   END. 


    METHOD VOID ParseGraphQL (input pcQuery as char):

        DEFINE VARIABLE cCleaned    AS LONGCHAR  NO-UNDO.
        DEFINE VARIABLE iPos        AS INTEGER   NO-UNDO.
        DEFINE VARIABLE cCurrent    AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cBuffer     AS CHARACTER NO-UNDO.
        DEFINE VARIABLE iBraceDepth AS INTEGER   NO-UNDO.
        DEFINE VARIABLE lInString   AS LOGICAL   NO-UNDO.
        DEFINE VARIABLE lInField    AS LOGICAL   NO-UNDO.

       // LOG-MANAGER:LOGFILE-NAME = "C:\temp\log2.txt".   
    
        /* Clean query (basic normalization) */
        cCleaned = REPLACE(pcQuery, '~n', ' ').
        cCleaned = REPLACE(cCleaned, '\', '').
        cCleaned = REPLACE(cCleaned, '  ', ' ').
        cCleaned = REPLACE(cCleaned, '  ', ' ').
        cCleaned = REPLACE(cCleaned, '  ', ' ').
        cCleaned = TRIM(cCleaned).

        THIS-OBJECT:graphqlquery = cCleaned. 
        

        /* Parse operation header 
        RUN ParseOperationHeader (
          INPUT  cCleaned,
          OUTPUT iPos
        ).
        */
   
        /* Recursive field parsing */
        ParseFieldsRecursive (
            INPUT  0,        /* parentId */
            INPUT  0,        /* depth */
            INPUT  cCleaned,
            INPUT  iPos + 1, /* start position */
            OUTPUT iPos
            ).

       // extent(blocks) = num-entries(graphqlquery,StringConstant:CURLY_OPEN).
 
       //  LOG-MANAGER:CLOSE-LOG().

    END METHOD.

    METHOD PRIVATE ROWID addQueryTable  (parentRowid AS ROWID,TableName AS CHARACTER,iLevel AS INTEGER) :
         
        IF tablename = "node"   or 
           tablename = "edges"  or 
           tablename = "query"  or 
           tablename = "schema" or 
           tablename = "pageinfo" then RETURN CurrentTableRowid. 
       
       
        // if it's a database table - object 
        // remove any schema.order .. 
        tablename = replace(tablename,'schema.','').
     
        CREATE QueryTable.               
       
        QueryTable.tablename = tableName.
        // if prural - remove 's' if not keep tablename 
        if substring(QueryTable.tablename,length(QueryTable.tablename),1) = 's' then 
          QueryTable.tablenameAlias = substring(QueryTable.tablename,1,length(QueryTable.tablename) - 1).
        else 
          QueryTable.tablenameAlias = QueryTable.tablename.
       
        QueryTable.QueryTable_id_parent = parentRowid.
        QueryTable.level = iLevel. 
        QueryTable.QueryTable_id = rowid(QueryTable). 
        
        RETURN ROWID(QueryTable).
    END. 



    METHOD PRIVATE ROWID addQueryField(parentRowid AS ROWID,FieldName AS CHARACTER) : 
        CREATE QueryField.               
        QueryField.fieldname = fieldname.
        QueryField.QueryTable_id = parentrowid. 
        RETURN ROWID(QueryField).
    END. 

    METHOD PRIVATE ROWID addQueryFilter (parentRowid AS ROWID,filtername AS CHARACTER,ctype AS CHARACTER, filtervalue AS CHARACTER) : 
        LOG-WRITE-MESSAGE ("addQueryFilter:" + filtername + "#" + filtervalue, "Q-FILTER"). 
        CREATE QueryFilter.       
        QueryFilter.FilterFieldValue = LEFT-TRIM(TRIM(filtervalue)).
        QueryFilter.filterFieldName  = LEFT-TRIM(TRIM(filtername)).
        QueryFilter.filterType       = ctype.
        QueryFilter.QueryTable_id    = parentrowid.   
        RETURN ROWID(QueryField).
    END. 


    METHOD PRIVATE  VOID ParseFieldsRecursive(
        INPUT piParentId AS INTEGER  ,
        INPUT piDepth    AS INTEGER  ,    
        INPUT pcInput    AS LONGCHAR ,
        INPUT piStart    AS INTEGER ,
        OUTPUT  piEnd   AS INTEGER):  

        /* Recursive field parser */
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
               
                // Process Arguments - everything within ( xxxx )  
                WHEN '(' THEN 
                    DO:
                        IF NOT lInString THEN 
                        DO:
                            IF cBuffer <> "" THEN 
                            DO:
                                LOG-WRITE-MESSAGE ("CreateTable:" +  cBuffer + " " + STRING(piDepth),"Table"). 
                                CurrentTableRowid = addQueryTable(CurrentTableRowid,cBuffer,piDepth). 
                            END. 
                            cBuffer = "".
     
                            iArgStart = i.
                            /* Parse arguments when closing ')' is found */
                            DO i = i + 1 TO LENGTH(pcInput):
                                IF SUBSTRING(pcInput, i, 1) = ')' AND NOT lInString THEN 
                                DO:
                                    cArgument = SUBSTRING(pcInput,iArgStart + 1,i - iArgStart - 1).
                                    ProcessArguments(INPUT CurrentTableRowid, INPUT cArgument,INPUT piParentId).
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
                                LOG-WRITE-MESSAGE ("CreateTable:" +  cBuffer + " " + STRING(piDepth),"Table"). 
                                CurrentTableRowid = addQueryTable(CurrentTableRowid,cBuffer,piDepth). 
                            END. 
                            cBuffer = "".
                            /* Recursive call for nested fields */
                            ParseFieldsRecursive(
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
                                LOG-WRITE-MESSAGE ("CreateField:" +  cBuffer + " " + STRING(piDepth),"Field"). 
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
                                LOG-WRITE-MESSAGE ("CreateField:" +  cBuffer + " " + STRING(piDepth),"Field"). 
                                addQueryField(CurrentTableRowid,cBuffer). 
                            END. 
                            cBuffer = "".
                        END.
                    END.
      // field sep
                    
                // start Directives  
                WHEN '@' THEN 
                    DO:
                        IF NOT lInString THEN 
                        DO:  
                            LOG-WRITE-MESSAGE ("Directive:" +  cBuffer + " " + STRING(piDepth),"DIR"). 
                        
                            /*
                            IF SUBSTRING(pcInput, i + 1, 1) = '~{' AND cBuffer <> "" THEN 
                            DO:
                                cBuffer = TRIM(cBuffer). 
                                LOG-WRITE-MESSAGE ("Directive:" +  cBuffer + " " + STRING(piDepth),"Directive"). 
                                CurrentTableRowid = addQueryTable(CurrentTableRowid,cBuffer,piDepth). 
                                cBuffer = "". 
                            END. 
       
                            IF cBuffer <> "" THEN 
                            DO:
                                LOG-WRITE-MESSAGE ("CreateField:" +  cBuffer + " " + STRING(piDepth),"Field"). 
                                addQueryField(CurrentTableRowid,cBuffer). 
                            END. 
                            cBuffer = "".
                             */
                        END.
                    END.

                // start Variables  
                WHEN '$' THEN 
                    DO:
                        IF NOT lInString THEN 
                        DO:  
                            LOG-WRITE-MESSAGE ("Variable:" +  cBuffer + " " + STRING(piDepth),"VAR"). 
                        
                            /*
                            IF SUBSTRING(pcInput, i + 1, 1) = '~{' AND cBuffer <> "" THEN 
                            DO:
                                cBuffer = TRIM(cBuffer). 
                                LOG-WRITE-MESSAGE ("Directive:" +  cBuffer + " " + STRING(piDepth),"Directive"). 
                                CurrentTableRowid = addQueryTable(CurrentTableRowid,cBuffer,piDepth). 
                                cBuffer = "". 
                            END. 
       
                            IF cBuffer <> "" THEN 
                            DO:
                                LOG-WRITE-MESSAGE ("CreateField:" +  cBuffer + " " + STRING(piDepth),"Field"). 
                                addQueryField(CurrentTableRowid,cBuffer). 
                            END. 
                            cBuffer = "".
                             */
                        END.
                    END.
                
                // Check for space and next character = '~{' --> Table --> Field create
                WHEN ' ' THEN 
                    DO:
                        IF NOT lInString THEN 
                        DO:
                            IF SUBSTRING(pcInput, i + 1, 1) = '~{' AND cBuffer <> "" THEN 
                            DO:
                                cBuffer = TRIM(cBuffer). 
                                LOG-WRITE-MESSAGE ("CreateTable:" +  cBuffer + " " + STRING(piDepth),"Table"). 
                                CurrentTableRowid = addQueryTable(CurrentTableRowid,cBuffer,piDepth). 
                                cBuffer = "". 
                            END. 
       
                            IF cBuffer <> "" THEN 
                            DO:
                                LOG-WRITE-MESSAGE ("CreateField:" +  cBuffer + " " + STRING(piDepth),"Field"). 
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
    END.

    METHOD PRIVATE LOGICAL isOperator (cStatement AS CHARACTER) : 
        RETURN LOOKUP(cStatement,"GE,LT,EQ") NE 0.
    END. 

    METHOD PRIVATE VOID ProcessArguments (INPUT parentrowid AS ROWID, INPUT  pcArgs  AS CHARACTER,INPUT piFieldId AS INTEGER):
    
        DEFINE VARIABLE i        AS INTEGER   NO-UNDO.
        DEFINE VARIABLE cArgPair AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cName    AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cValue   AS CHARACTER NO-UNDO.
  
        LOG-WRITE-MESSAGE("ProcessArguments:" + STRING(pcArgs),"DEBUG").
  
        DEFINE VARIABLE cBuffer          AS CHARACTER. 
        DEFINE VARIABLE cchar            AS CHARACTER.
        DEFINE VARIABLE Argumenttype     AS CHARACTER NO-UNDO.
        DEFINE VARIABLE lAssignedValue   AS LOGICAL   INIT TRUE NO-UNDO. 
        DEFINE VARIABLE ctmp             AS CHARACTER NO-UNDO. 
        DEFINE VARIABLE lInString        AS LOGICAL NO-UNDO. 
        DEFINE VARIABLE ArgumentTypeList AS CHAR INIT "sort,filter,where" NO-UNDO.  
   
        DO i = 1 TO LENGTH(pcArgs):
            cChar = SUBSTRING(pcArgs, i, 1).
            CASE cChar:
                WHEN '"' THEN  lInString = NOT lInString.
                
                // Check for ':' and set Argument type sort,filter,where 
                WHEN ':' THEN IF NOT lInString THEN  // end of field 
                    DO:  
                        IF NOT isOperator(LEFT-TRIM(TRIM(cbuffer))) THEN 
                        DO:
                            cname = LEFT-TRIM(TRIM(cbuffer)). 
                            cBuffer = "".
              
                            IF LOOKUP(cname,"sort,filter,where") NE 0  THEN
                            DO:
                                ArgumentType = cname.       
                            END.
                            ELSE lAssignedValue = FALSE. 
                        END. 
                    END.
                    
                WHEN '~{' THEN IF NOT lInString THEN 
                    DO:
                        cbuffer = "".
                    END.
                WHEN '~}' THEN IF NOT lInString THEN
                    IF NOT lAssignedValue THEN 
                    DO:
                        addQueryFilter(parentRowId,cname,ArgumentType,cbuffer).
                        LOG-WRITE-MESSAGE("1 field:" + STRING(cname) + ":" + left-trim(TRIM(cbuffer)) + " " + ArgumentType  ,"DEBUG").
                        lAssignedValue = TRUE.               
                        cbuffer = "".
                    END.
                WHEN ',' THEN IF NOT lInString THEN
                    IF NOT lAssignedValue THEN 
                    DO:
                        addQueryFilter(parentRowId,cname,ArgumentType,cbuffer).
                        LOG-WRITE-MESSAGE("2 field:" + STRING(cname) + ":" + left-trim(TRIM(cbuffer)) + " " + ArgumentType ,"DEBUG").
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
            LOG-WRITE-MESSAGE("3 field:" + STRING(cname) + ":" + left-trim(TRIM(cbuffer)) + " " + ArgumentType ,"DEBUG").
        END.
    END.

    METHOD VOID log-Query():
    
        FOR EACH queryTable NO-LOCK: 
            LOG-WRITE-MESSAGE ("Table:" + queryTable.tablename, ""). 
            FOR EACH queryFilter WHERE queryFilter.QueryTable_id = ROWID(queryTable): 
                LOG-WRITE-MESSAGE ("   " + queryFilter.FilterType + ":" + queryFilter.FilterFieldName + ":" + queryFilter.FilterFieldValue, ""). 
            END.                    
            FOR EACH QueryField WHERE QueryField.QueryTable_id = ROWID(queryTable):
                LOG-WRITE-MESSAGE ("      Field:" + queryTable.tablename + ":" + queryfield.fieldname, ""). 
            END. 
        END.
    END. 
    
    method void  ParseDirectives (pcLine AS CHAR, piParentID  AS RECID):

  DEFINE VARIABLE iDirective AS INTEGER NO-UNDO.
  DEFINE VARIABLE cDirective AS CHAR    NO-UNDO.
  DEFINE VARIABLE cDirName   AS CHAR    NO-UNDO.
  DEFINE VARIABLE cArgs      AS CHAR    NO-UNDO.

  DO iDirective = 1 TO NUM-ENTRIES(pcLine, "@"):
    cDirective = TRIM(ENTRY(iDirective, pcLine, "@")).
    IF cDirective = "" THEN NEXT.
    
    cDirName = ENTRY(1, cDirective, "(").
    cArgs = TRIM(REPLACE(SUBSTRING(cDirective, INDEX(cDirective, "(") + 1), ")", "")).
    
    CREATE ttDirective.
    ASSIGN
      ttDirective.ParentID     = piParentID
      ttDirective.DirectiveName = cDirName
      ttDirective.DirectiveID   = RECID(ttDirective).
    
    RUN ParseArguments(
      INPUT  cArgs,
      INPUT  "Directive",
      INPUT  RECID(ttDirective)
    ).
  END.
  
END .

END. 


/*
DEFINE VARIABLE hComplexQuery AS LONGCHAR NO-UNDO.

hComplexQuery = 
  "query GetUser($id: ID!, $withPosts: Boolean = false) {~n" +
  "  user(id: $id) {~n" +
  "    ...userFields~n" +
  "    posts @include(if: $withPosts) {~n" +
  "      id~n" +
  "      title @skip(if: $noTitles)~n" +
  "      ... on Post {~n" +
  "        comments {~n" +
  "          text~n" +
  "        }~n" +
  "      }~n" +
  "    }~n" +
  "  }~n" +
  "}~n" +
  "~n" +
  "fragment userFields on User {~n" +
  "  name~n" +
  "  email~n" +
  "}".

RUN ParseGraphQL (
  INPUT  hComplexQuery,
  OUTPUT TABLE ttOperation,
  OUTPUT TABLE ttSelection,
  OUTPUT TABLE ttArgument,
  OUTPUT TABLE ttDirective,
  OUTPUT TABLE ttFragment,
  OUTPUT TABLE ttVariable
).


/* Handle fragment definitions like "fragment Name on Type {...}" */
PROCEDURE ParseFragmentDefinition PRIVATE:
  DEFINE INPUT PARAMETER pcLine AS CHAR NO-UNDO.
  
  ASSIGN
    cFragmentName = ENTRY(2, pcLine, " ")
    cOnType       = ENTRY(4, pcLine, " ")
    lInFragmentDef = TRUE.
    
  CREATE ttFragment.
  ASSIGN
    ttFragment.FragmentName = cFragmentName
    ttFragment.OnType       = cOnType.
END PROCEDURE.

/* Handle inline fragments like "... on Post { title }" */
PROCEDURE ParseInlineFragment PRIVATE:
  DEFINE INPUT PARAMETER pcLine       AS CHAR  NO-UNDO.
  DEFINE INPUT PARAMETER piParentID   AS RECID NO-UNDO.
  DEFINE INPUT PARAMETER piDepth      AS INT   NO-UNDO.

  DEFINE VARIABLE cTypeCondition AS CHAR NO-UNDO.
  
  cTypeCondition = SUBSTRING(pcLine, 7, INDEX(pcLine, "{") - 7).
  
  CREATE ttSelection.
  ASSIGN
    ttSelection.ParentID      = piParentID
    ttSelection.TypeCondition = TRIM(cTypeCondition)
    ttSelection.IsFragment    = TRUE
    ttSelection.IsInline      = TRUE
    ttSelection.Depth         = piDepth
    ttSelection.SelectionID   = RECID(ttSelection).
END PROCEDURE.

/* Handle directives like "@include(if: $condition)" */
PROCEDURE ParseDirectives PRIVATE:
  DEFINE INPUT PARAMETER pcLine      AS CHAR  NO-UNDO.
  DEFINE INPUT PARAMETER piParentID  AS RECID NO-UNDO.

  DEFINE VARIABLE iDirective AS INTEGER NO-UNDO.
  DEFINE VARIABLE cDirective AS CHAR    NO-UNDO.
  DEFINE VARIABLE cDirName   AS CHAR    NO-UNDO.
  DEFINE VARIABLE cArgs      AS CHAR    NO-UNDO.

  DO iDirective = 1 TO NUM-ENTRIES(pcLine, "@"):
    cDirective = TRIM(ENTRY(iDirective, pcLine, "@")).
    IF cDirective = "" THEN NEXT.
    
    cDirName = ENTRY(1, cDirective, "(").
    cArgs = TRIM(REPLACE(SUBSTRING(cDirective, INDEX(cDirective, "(") + 1), ")", "")).
    
    CREATE ttDirective.
    ASSIGN
      ttDirective.ParentID     = piParentID
      ttDirective.DirectiveName = cDirName
      ttDirective.DirectiveID   = RECID(ttDirective).
    
    RUN ParseArguments(
      INPUT  cArgs,
      INPUT  "Directive",
      INPUT  RECID(ttDirective)
    ).
  END.
END PROCEDURE.

/* Enhanced argument parsing with variable detection */
PROCEDURE ParseArguments PRIVATE:
  DEFINE INPUT PARAMETER pcArgString AS CHAR  NO-UNDO.
  DEFINE INPUT PARAMETER pcOwnerType AS CHAR  NO-UNDO.
  DEFINE INPUT PARAMETER piOwnerID   AS RECID NO-UNDO.

  DEFINE VARIABLE iArg      AS INTEGER NO-UNDO.
  DEFINE VARIABLE cArgPair  AS CHAR    NO-UNDO.
  DEFINE VARIABLE cArgName  AS CHAR    NO-UNDO.
  DEFINE VARIABLE cArgValue AS CHAR    NO-UNDO.

  DO iArg = 1 TO NUM-ENTRIES(pcArgString, ","):
    cArgPair = TRIM(ENTRY(iArg, pcArgString, ",")).
    IF NUM-ENTRIES(cArgPair, ":") >= 2 THEN DO:
      ASSIGN
        cArgName  = TRIM(ENTRY(1, cArgPair, ":"))
        cArgValue = TRIM(ENTRY(2, cArgPair, ":")).
      
      CREATE ttArgument.
      ASSIGN
        ttArgument.OwnerType  = pcOwnerType
        ttArgument.OwnerID    = piOwnerID
        ttArgument.ArgName    = cArgName
        ttArgument.ArgValue   = cArgValue
        ttArgument.IsVariable = (cArgValue BEGINS "$").
    END.
  END.
END PROCEDURE.



PROCEDURE ParseGraphQL:
  /* Existing parameters remain the same */
  
  DEFINE VARIABLE lInFragmentDef AS LOGICAL NO-UNDO INIT FALSE.
  DEFINE VARIABLE cFragmentName  AS CHAR    NO-UNDO.
  DEFINE VARIABLE cOnType        AS CHAR    NO-UNDO.

  /* Main parsing loop enhanced */
  DO iLine = iLine TO iNumLines:
    cLine = TRIM(REPLACE(ENTRY(iLine, pcQuery, CHR(10)), CHR(13), "")).
    
    CASE TRUE:
      /* Handle Fragment Definitions */
      WHEN cLine BEGINS "fragment " THEN DO:
        RUN ParseFragmentDefinition(cLine).
        NEXT.
      END.

      /* Handle Variables */
      WHEN cLine BEGINS "$" THEN DO:
        RUN ParseVariableDefinition(cLine).
        NEXT.
      END.

      /* Handle Inline Fragments */
      WHEN cLine BEGINS "... on " THEN DO:
        RUN ParseInlineFragment(cLine, cCurrentParent, iDepth).
        NEXT.
      END.

      /* Handle Directives */
      WHEN cLine MATCHES "*@*" THEN DO:
        RUN ParseDirectives(cLine, cCurrentParent).
        NEXT.
      END.

      /* Enhanced Field/Alias Handling */
      WHEN cLine MATCHES "*:*" THEN DO:
        RUN ParseFieldWithAlias(cLine, cCurrentParent, iDepth).
        NEXT.
      END.

      /* Existing brace handling remains */
    END CASE.
  END.
END PROCEDURE.


/* Add fields for complex structures */
DEFINE TEMP-TABLE ttSelection NO-UNDO
  FIELD ParentID      AS RECID
  FIELD FieldName     AS CHAR
  FIELD AliasName     AS CHAR
  FIELD TypeCondition AS CHAR    /* For inline fragments */
  FIELD HasFragments  AS LOG
  FIELD IsFragment    AS LOG
  FIELD IsInline      AS LOG
  FIELD DirectiveID   AS RECID
  FIELD Depth         AS INT
  FIELD SelectionID   AS RECID.

DEFINE TEMP-TABLE ttDirective NO-UNDO
  FIELD ParentID     AS RECID    /* Can be operation or selection */
  FIELD DirectiveName AS CHAR
  FIELD Arguments     AS CHAR    /* Serialized arguments */
  FIELD DirectiveID   AS RECID.

DEFINE TEMP-TABLE ttFragment NO-UNDO
  FIELD FragmentName AS CHAR
  FIELD OnType       AS CHAR
  FIELD SelectionID  AS RECID.

DEFINE TEMP-TABLE ttVariable NO-UNDO
  FIELD VariableName AS CHAR
  FIELD VariableType AS CHAR
  FIELD DefaultValue AS CHAR.

DEFINE TEMP-TABLE ttArgument NO-UNDO
  FIELD OwnerType    AS CHAR     /* "Selection" or "Directive" */
  FIELD OwnerID      AS RECID
  FIELD ArgName      AS CHAR
  FIELD ArgValue     AS CHAR
  FIELD IsVariable   AS LOG.


*/



