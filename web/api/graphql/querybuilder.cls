


USING Progress.Lang.*.
// using web.api.graphql.StringConstant.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS web.api.graphql.querybuilder: 

    DEFINE         VARIABLE graphqlquery      as char    no-undo. 
    DEFINE         VARIable ilevelcouter      as int     no-undo. 
    DEFINE         VARIABLE graphqlDataset    as handle  no-undo. 
    DEFINE PRIVATE VARIABLE iLevel            AS INTEGER NO-UNDO. 
    DEFINE PRIVATE VARIABLE icnt              AS INTEGER NO-UNDO. 
    DEFINE PRIVATE VARIABLE CurrentTableRowid AS ROWID   NO-UNDO. 
    DEFINE VARIABLE entitypath AS CHARACTER INIT 'web.api.graphql.entity.' NO-UNDO. 
    
    {web/api/graphql/querydataset.i }
 
    CONSTRUCTOR querybuilder(INPUT DATASET FOR dsQuery BIND):
        hQueryDataSet   = DATASET dsQuery:handle.
        hQueryDataSet:SERIALIZE-HIDDEN = TRUE. 
        log-Query().
        BuildQuery().
        
    END CONSTRUCTOR.
    
    CONSTRUCTOR querybuilder():
        
    END CONSTRUCTOR.
  
    METHOD VOID LOG-WRITE-MESSAGE (input pcmessage as char,input pctype AS CHAR):
        IF LOG-MANAGER:LOGFILE-NAME NE ? THEN 
            LOG-MANAGER:WRITE-MESSAGE (pcmessage, pcType). 
    END. 

    METHOD LOGICAL isSupportedFunctionInObjectEntity(cTableNameAlias AS CHAR,OUTPUT Params    AS Progress.Reflect.PARAMETER EXTENT):
       DEF VAR cFunctionList AS CHAR INIT "aggregate" NO-UNDO. 
       DEF VAR cEntity AS CHAR NO-UNDO. 
       def var oEntity AS web.api.graphql.entity.IBusinessEntity no-undo. 
       def var lok as logical no-undo. 
           
       IF INDEX(cTableNameAlias,cFunctionList) ne  0 then 
       DO: 
            cEntity = replace(cTableNameAlias,cFunctionList,'').  
            oEntity = DYNAMIC-NEW entitypath + cEntity + 'entity' () NO-ERROR.
            IF VALID-OBJECT(oEntity) THEN 
                params  = DYNAMIC-INVOKE(oEntity,'Signature',cFunctionList) .
       /*     MESSAGE params[1]:datatype 
                    params[1]:NAME
                    params[1]:mode 
                    VIEW-AS ALERT-BOX. */
                    
       END.
       lok = valid-object (params[1]) no-error. 
       return lok.  
    END. 

    // build dataset for result back 
    // based on methods in entities and tables in database 
    METHOD handle BuildResultDataset ():
        DEFINE VARIABLE hTable AS HANDLE NO-UNDO. 
        DEFINE VARIABLE suffix AS CHAR   INIT "s".
        DEFINE VARIABLE Params    AS Progress.Reflect.PARAMETER EXTENT NO-UNDO.                                                    
        define variable icnt as int no-undo. 
                
        CREATE DATASET hQueryResultDataSet. 
        hQueryResultDataSet:SERIALIZE-HIDDEN = TRUE.
      
        // Create temp-tables for results /dataset - fill inn data
        FOR EACH QueryTable  : 
            CREATE TEMP-TABLE hTable.
            
            IF isSupportedFunctionInObjectEntity(QueryTable.TableNamealias, OUTPUT Params ) THEN           
            do: 
                QueryTable.TableNamealias = "order".
                QueryTable.IsObjectFunction = true.  
                
                DO iCnt = 1 to extent(params):
                  FOR EACH QueryField WHERE QueryField.QueryTable_id = ROWID(queryTable) 
                      AND queryfield.fieldname = params[icnt]:name :
                       hTable:ADD-NEW-FIELD(params[icnt]:name,string(params[icnt]:datatype)).
                //     message params[icnt]:name view-as alert-box. 
                   END.
                end. 
            END. 
            ELSE
            DO:    
               hTable:CREATE-LIKE(QueryTable.TableNamealias).
            END. 
            hTable:TEMP-TABLE-PREPARE(QueryTable.TableName).
            hQueryResultDataSet:ADD-BUFFER(hTable:DEFAULT-BUFFER-HANDLE).
            QueryTable.TableHandle = hTable. 
            LOG-WRITE-MESSAGE ("Created: " + hTable:name,'').
        END.  
    END. 

    
    METHOD handle BuildQuery ():
        DEFINE VARIABLE dynObject   AS web.api.graphql.entity.IBusinessEntity NO-UNDO.
      
        BuildResultDataset(). 
        
        // starts business entity for building query based on .. 
        FOR EACH QueryTable  : 
            dynObject = DYNAMIC-NEW entitypath + QueryTable.tablenameAlias + 'entity' (DATASET-HANDLE hQueryDataSet BY-REFERENCE) .
            QueryTable.QueryWhere  = dynObject:getQuery(QueryTable.TableHandle).
            QueryTable.PrimaryKey  = dynObject:PrimaryKey().
           //  IF QueryTable.QueryWhere NE "" THEN QueryTable.QueryWhere = " where " + QueryTable.QueryWhere. 
            LOG-WRITE-MESSAGE ("Query filter: " + QueryTable.tablenameAlias + " " + QueryTable.QueryWhere,'').
            //delete object dynobject no-error. 
        END.  
        
        fill_dataset().
    END. 
    

    METHOD VOID  fill_dataset (): 

        DEFINE VARIABLE hQuery AS HANDLE NO-UNDO.
        define variable hRelation as handle no-undo .
        
        // phDataSet:ADD-RELATION(phDataSet:GET-BUFFER-HANDLE(1),phDataSet:GET-BUFFER-HANDLE(2),pcFields).
        DEF VAR icnt as int no-undo. 
        def var tmpFillWhereStr as char no-undo. 
        def var bf as handle no-undo. 

         
        FOR EACH QueryTable NO-LOCK : 
            
            icnt = icnt + 1. 
            if icnt ge 2 then 
            do: 
              hRelation = hQueryResultDataSet:ADD-RELATION(
                             hQueryResultDataSet:GET-BUFFER-HANDLE(1),
                             hQueryResultDataSet:GET-BUFFER-HANDLE(2),QueryTable.PrimaryKey + "," + QueryTable.PrimaryKey ).
               hRelation:nested = true. 
            end. 
            
            
            // Only datasource for tables in db not functions like count 
            IF NOT querytable.isObjectFunction THEN 
            DO:    

                CREATE DATA-SOURCE QueryTable.TableDatasourceHandle.
                CREATE BUFFER QueryTable.DatabaseBufferHandle FOR TABLE QueryTable.TableNameAlias.
                QueryTable.TableDatasourceHandle:ADD-SOURCE-BUFFER(QueryTable.DatabaseBufferHandle,
                                QueryTable.PrimaryKey).
             
                // hQueryResultDataSet:GET-BUFFER-HANDLE(1):ATTACH-DATA-SOURCE(QueryTable.TableDatasourceHandle).
                QueryTable.TableHandle:DEFAULT-BUFFER-HANDLE:ATTACH-DATA-SOURCE(QueryTable.TableDatasourceHandle).
                  
                if icnt = 1 then 
                   QueryTable.TableHandle:DEFAULT-BUFFER-HANDLE:DATA-SOURCE:FILL-WHERE-STRING = ' where ' + QueryTable.QueryWhere.
                else if icnt ge 1 and QueryTable.QueryWhere ne '' then 
                   QueryTable.TableHandle:DEFAULT-BUFFER-HANDLE:DATA-SOURCE:FILL-WHERE-STRING =
                   QueryTable.TableHandle:DEFAULT-BUFFER-HANDLE:DATA-SOURCE:FILL-WHERE-STRING + ' and ' + QueryTable.QueryWhere.
            END. 
            ELSE 
            DO:
                QueryTable.TableHandle:default-buffer-handle:SET-CALLBACK ("BEFORE-FILL"   , "BeforeFill"  , THIS-OBJECT).
                
                bf = QueryTable.TableHandle:default-buffer-handle.
                bf:buffer-create().
                
            END. 
            
              /*     
        dsRecruitingStatisticsInternal:GET-BUFFER-HANDLE(1):SET-CALLBACK ("AFTER-ROW-FILL", "AfterRowFill", THIS-OBJECT).
        /*  dsRecruitingStatisticsInternal:GET-BUFFER-HANDLE(1):SET-CALLBACK ("BEFORE-FILL"   , "BeforeFill"  , THIS-OBJECT). */
        dsRecruitingStatisticsInternal:GET-BUFFER-HANDLE(1):SET-CALLBACK ("AFTER-FILL"    , "AfterFill"   , THIS-OBJECT).
            


    METHOD PUBLIC VOID BeforeFill(INPUT DATASET-HANDLE dsRecruitingStatisticsInternal):
        ws3Helper:LOG-MANAGER-DEBUG("BeforeRowfill").
    END.
            */
            
            /*
           tmpFillWhereStr = QueryTable.TableHandle:DEFAULT-BUFFER-HANDLE:DATA-SOURCE:FILL-WHERE-STRING.
            
           IF QueryTable.QueryWhere ne '' AND tmpFillWhereStr ne ''  
           THEN  
              QueryTable.TableHandle:DEFAULT-BUFFER-HANDLE:DATA-SOURCE:FILL-WHERE-STRING = tmpFillWhereStr + ' and ' + QueryTable.QueryWhere.
           ELSE IF QueryTable.QueryWhere ne '' AND tmpFillWhereStr = '' then
              QueryTable.TableHandle:DEFAULT-BUFFER-HANDLE:DATA-SOURCE:FILL-WHERE-STRING = ' where ' + QueryTable.QueryWhere.
               
            message "curt" QueryTable.TableHandle:DEFAULT-BUFFER-HANDLE:DATA-SOURCE:FILL-WHERE-STRING view-as alert-box. 
            */   
message "ok" view-as alert-box. 

         //   LOG-WRITE-MESSAGE ("query: " + QueryTable.TableHandle:DEFAULT-BUFFER-HANDLE:DATA-SOURCE:FILL-WHERE-STRING ,'' ). 
            /*       
            // Crate Query  
            // IF NOT VALID-HANDLE(hQuery) THEN CREATE QUERY hQuery.
            CREATE QUERY hQuery.
            hQuery:ADD-BUFFER(QueryTable.DatabaseBufferHandle).
           
           // LOG-WRITE-MESSAGE ("query: " + "FOR EACH customer where " + cQuery,"").
            hQuery:QUERY-PREPARE("FOR EACH " + QueryTable.TableNameAlias + QueryTable.QueryWhere).
            QueryTable.TableDatasourceHandle:QUERY = hQuery.
            */
        END.
       
        hQueryResultDataSet:FILL().
        DELETE OBJECT hQuery no-error.

   /*
    
    // Cleanup
    DEF VAR iEntry as int. 
    def var hBuffer as handle. 
    DO iEntry = 1 TO hQueryResultDataSet:NUM-BUFFERS:
        hBuffer = hQueryResultDataSet:GET-BUFFER-HANDLE(iEntry).
    
       LOG-WRITE-MESSAGE ("Data-Source: " +
            hBuffer:DATA-SOURCE:GET-SOURCE-BUFFER:NAME + 
            "WHERE-STRING:" + hBuffer:DATA-SOURCE:FILL-WHERE-STRING, ""). 
    
        MESSAGE "Data-Source: "
            hBuffer:DATA-SOURCE:GET-SOURCE-BUFFER:NAME SKIP
            "WHERE-STRING:" hBuffer:DATA-SOURCE:FILL-WHERE-STRING
            VIEW-AS ALERT-BOX.
                
        DELETE OBJECT hBuffer:DATA-SOURCE.
    END.
   */
    
    END. 

    METHOD PUBLIC VOID BeforeFill(INPUT DATASET-HANDLE dsHandle):
             message "fadsfasdok" view-as alert-box. 
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

END. 

/*
 METHOD VOID  fill_dataset (
            INPUT pcSources AS CHARACTER,
            INPUT pcSourceKeys AS CHARACTER,
            INPUT pcFields AS CHARACTER,
            INPUT pcKeyValue AS CHARACTER,
            OUTPUT DATASET-HANDLE phDataSet): 

        DEFINE VARIABLE iEntry      AS INTEGER NO-UNDO.
        DEFINE VARIABLE hDataSource AS HANDLE  NO-UNDO.
        DEFINE VARIABLE hBuffer     AS HANDLE  NO-UNDO.
        DEFINE VARIABLE hQuery      AS HANDLE  NO-UNDO.
        DEFINE VARIABLE hTable      AS HANDLE  NO-UNDO.

        CREATE DATASET phDataSet.
        
        /*
        DO iEntry = 1 TO NUM-ENTRIES(pcSources):
            CREATE TEMP-TABLE hTable.
            hTable:CREATE-LIKE(ENTRY(iEntry, pcSources)).
            hTable:TEMP-TABLE-PREPARE("tt" + ENTRY(iEntry, pcSources)).
            phDataSet:ADD-BUFFER(hTable:DEFAULT-BUFFER-HANDLE).
        END.
        */
        
        phDataSet:ADD-RELATION(phDataSet:GET-BUFFER-HANDLE(1),phDataSet:GET-BUFFER-HANDLE(2),pcFields).

        DO iEntry = 1 TO NUM-ENTRIES(pcSources):
            CREATE DATA-SOURCE hDataSource.
            CREATE BUFFER hBuffer FOR TABLE ENTRY(iEntry, pcSources).
            hDataSource:ADD-SOURCE-BUFFER(hBuffer, ENTRY(iEntry,pcSourceKeys)).
            phDataSet:GET-BUFFER-HANDLE(iEntry):ATTACH-DATA-SOURCE(hDataSource).

            IF iEntry = 1 THEN 
            DO:
                CREATE QUERY hQuery.
                hQuery:ADD-BUFFER(hBuffer).
                hQuery:QUERY-PREPARE("FOR EACH " + ENTRY(1, pcSources) +
                    " WHERE " + ENTRY(1, pcSourceKeys) + pcKeyValue).
                hDataSource:QUERY = hQuery.
            END.
        END.
    
        phDataSet:FILL().
        DELETE OBJECT hQuery.

        // Cleanup
        DO iEntry = 1 TO phDataSet:NUM-BUFFERS:
            hBuffer = phDataSet:GET-BUFFER-HANDLE(iEntry).
    
           LOG-WRITE-MESSAGE ("Data-Source: " +
                hBuffer:DATA-SOURCE:GET-SOURCE-BUFFER:NAME + 
                "WHERE-STRING:" + hBuffer:DATA-SOURCE:FILL-WHERE-STRING, ""). 
    
            MESSAGE "Data-Source: "
                hBuffer:DATA-SOURCE:GET-SOURCE-BUFFER:NAME SKIP
                "WHERE-STRING:" hBuffer:DATA-SOURCE:FILL-WHERE-STRING
                VIEW-AS ALERT-BOX.
                
            DELETE OBJECT hBuffer:DATA-SOURCE.
        END.
    END. 
*/
