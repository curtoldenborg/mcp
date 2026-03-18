 
 

BLOCK-LEVEL ON ERROR UNDO, THROW.

USING web.UpdateModeEnum.
USING Progress.Reflect.*.
USING Progress.Lang.Class.*.

CLASS web.api.graphql.entity.base ABSTRACT:
    DEFINE PROTECTED PROPERTY hdsQuery AS HANDLE NO-UNDO
        GET.
        SET.
            
    DEFINE PRIVATE PROPERTY UpdateMode AS web.UpdateModeEnum NO-UNDO
        GET.
        SET (INPUT mode AS web.UpdateModeEnum):
            UpdateMode = mode.
        END SET.
   
    {web/api/graphql/querydataset.i }
      
    DEFINE TEMP-TABLE RelationField NO-UNDO
        FIELD FromTable     AS CHARACTER 
        FIELD FromFieldName AS CHARACTER 
        FIELD ToFieldName   AS CHARACTER. 
      
    DEFINE TEMP-TABLE FilterMapping NO-UNDO
        FIELD FilterName             AS CHARACTER 
        FIELD FilterMethod           AS LOGICAL
        FIELD FilterDatatype         AS CHARACTER 
        FIELD FilterMappingStatement AS CHARACTER. 
    
    CONSTRUCTOR PROTECTED base(INPUT DATASET FOR dsQuery BIND):
        hdsquery   = DATASET dsQuery:handle.
        UpdateMode = web.UpdateModeEnum:UNDEFINED.
    END CONSTRUCTOR.

    CONSTRUCTOR PROTECTED base():
    END CONSTRUCTOR.


    METHOD PROTECTED CHARACTER getQueryFilter (INPUT iphCurrentTableHandle AS HANDLE):
        DEFINE VARIABLE cfilter       AS CHARACTER NO-UNDO.     
        DEFINE VARIABLE invokemethod  AS CHARACTER NO-UNDO. 
        DEFINE VARIABLE cfilterinvoke AS CHARACTER NO-UNDO.           
        DEFINE VARIABLE coperator     AS CHARACTER. 
       
        def var whatever as char. 
        // rewrite - use stack push / pop 
        FOR EACH queryTable WHERE queryTable.TableHandle = iphCurrentTableHandle NO-LOCK: 
            LOG-WRITE-MESSAGE ("  getQueryFilter for table:" + queryTable.tablename, ""). 
      
            FOR EACH queryFilter WHERE queryFilter.QueryTable_id = queryTable.QueryTable_id: 
                LOG-WRITE-MESSAGE ("   " + queryFilter.FilterType + ":" + queryFilter.FilterFieldName + ":" + queryFilter.FilterFieldValue, "").
                cFilterInvoke = ''.
                InvokeMethod =   queryFilter.FilterFieldName. 
                cFilterInvoke = DYNAMIC-INVOKE(THIS-OBJECT, InvokeMethod, INPUT queryFilter.FilterFieldValue,OUTPUT whatever ) NO-ERROR .
                IF NOT ERROR-STATUS:ERROR THEN 
                DO:
                    cFilter = cFilterInvoke + '|'+ cFilter. 
                END.
                ELSE   
                DO:
                    IF INDEX(queryFilter.FilterFieldValue,'*') NE 0 THEN
                    DO:  
                        queryFilter.FilterFieldValue =  REPLACE(queryFilter.FilterFieldValue,"*","").         
                        cOperator = " begins ".
                    END. 
                    ELSE cOperator = " = ".  
                    cFilter = queryFilter.FilterFieldName + cOperator + quoter(queryFilter.FilterFieldValue) + '|' + cFilter . 
                END.
            END. 
                               
        END.
          
    // tullball 
        DEFINE VARIABLE creturn AS CHARACTER.      
        DEFINE VARIABLE icnt    AS INTEGER. 
        DO icnt = 1 TO NUM-ENTRIES(cfilter,"|"):
            IF ENTRY(icnt,cfilter,"|") NE "" THEN 
                creturn = ENTRY(icnt,cfilter,"|") + ' and ' + cReturn.      
        END.  
        creturn = TRIM(creturn).
        creturn = SUBSTRING(creturn,1,LENGTH(creturn) - 3).
        MESSAGE creturn VIEW-AS ALERT-BOX. 
                
        RETURN creturn .  
    END.   

    METHOD PROTECTED VOID RelationField(INPUT ctable AS CHARACTER, INPUT cField1 AS CHARACTER, INPUT cfield2 AS CHARACTER):
        CREATE relationfield. 
        RelationField.FromFieldName = cField1. 
        RelationField.FromTable = ctable. 
        RelationField.ToFieldName = cfield2. 
    END. 
  
    METHOD PROTECTED VOID FilterOptionMapping(INPUT ctable AS CHARACTER EXTENT, INPUT cDataType AS CHARACTER, INPUT cWhereMapping AS CHARACTER):
    END. 

    METHOD PROTECTED VOID FilterOptionMapping(INPUT cfiltername AS CHARACTER,  INPUT cDataType AS CHARACTER, INPUT cWhereMapping AS CHARACTER):
        CREATE FilterMapping. 
        FilterMapping.FilterName = cfiltername.
        FilterMapping.FilterMethod = FALSE.
        FilterMapping.FilterDatatype = cDatatype.
        FilterMapping.FilterMappingStatement = cWhereMapping.
    END. 

    METHOD PUBLIC CHARACTER getQuery(INPUT hCurrentTableHandle AS HANDLE):
        RETURN getQueryFilter(hCurrentTableHandle).
    END. 

    METHOD PUBLIC Progress.Reflect.PARAMETER EXTENT signature(cMethod as char): 
        DEFINE VARIABLE MethodExt AS METHOD EXTENT NO-UNDO.
        DEFINE VARIABLE Params    AS Progress.Reflect.PARAMETER EXTENT NO-UNDO.
        DEFINE VARIABLE oClass    AS Progress.Lang.Class NO-UNDO.
        DEFINE VARIABLE cReturn   AS CHAR EXTENT NO-UNDO.  
        DEFINE VARIABLE icnt      AS INT NO-UNDO .
        
    //  oClass = Progress.Lang.Class:GetClass("web.api.graphql.entity.orderentity").
        oClass = Progress.Lang.Class:GetClass(entry(1,this-object:tostring(),'_')).
         
        MethodExt = oClass:GetMethods().
        DO iCnt = 1 TO EXTENT(MethodExt):
            IF MethodExt[iCnt]:Name = cMethod THEN LEAVE.         
        END. 
        Params = MethodExt[iCnt]:GetParameters() NO-ERROR.
       
        RETURN Params. 
       // MESSAGE myMethodExt[2] xxparams[2] xxparams[1]VIEW-AS ALERT-BOX.
    END. 


    METHOD INTEGER countrecords (INPUT cTablename AS CHARACTER, cWhereStatement AS CHARACTER  ):

        DEFINE VARIABLE h_querystring AS CHARACTER     NO-UNDO.
        DEFINE VARIABLE h_qry       AS HANDLE   NO-UNDO.
        DEFINE VARIABLE h_buffer    AS HANDLE   NO-UNDO.
        DEFINE VARIABLE numRecords  AS INTEGER NO-UNDO.     
    
        CREATE BUFFER h_buffer FOR TABLE cTablename .
        h_querystring = "PRESELECT EACH " + cTablename + cWhereStatement + " no-lock ".
        CREATE QUERY h_qry.
        h_qry:SET-BUFFERS( h_buffer ).
        h_qry:QUERY-PREPARE( h_querystring ).
        h_qry:QUERY-OPEN().
        numRecords = h_qry:NUM-RESULTS.
    
        RETURN numRecords.
 
        FINALLY:
           DELETE OBJECT h_qry NO-ERROR.
           DELETE OBJECT h_buffer NO-ERROR.
        END.     
    END METHOD.


    METHOD VOID LOG-WRITE-MESSAGE (INPUT pcmessage AS CHARACTER,INPUT pctype AS CHARACTER):
        IF LOG-MANAGER:LOGFILE-NAME NE ? THEN 
            LOG-MANAGER:WRITE-MESSAGE (pcmessage, pcType). 
    END. 
 
END CLASS.


