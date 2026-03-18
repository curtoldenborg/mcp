
/*------------------------------------------------------------------------
    File        : BusinessEntity
    Purpose     : Class for dataaccess with dataset fill - using OE standards
    Syntax      : 
    Description : 
    Author(s)   : Curt
    Created     : 
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING web.*. 

CLASS web.BusinessEntity INHERITS web.BusinessEntityOE: 

    DEFINE PUBLIC VARIABLE DataSet          AS HANDLE    NO-UNDO. 
    DEFINE PUBLIC VARIABLE DataSource       AS HANDLE    NO-UNDO. 
    DEFINE PUBLIC VARIABLE DataSourceBuffer AS HANDLE    NO-UNDO. 
 
    DEFINE PUBLIC VARIABLE hTempTable       AS HANDLE    NO-UNDO. 
    DEFINE PUBLIC VARIABLE hTargetBuffer    AS HANDLE    NO-UNDO. 
  
    DEFINE PUBLIC VARIABLE FieldListMapping AS CHARACTER EXTENT NO-UNDO. 
    DEFINE PUBLIC VARIABLE RepositionToid   AS CHARACTER INIT "" NO-UNDO. 
    DEFINE PUBLIC VARIABLE iMaxRows         AS INTEGER   INIT 200 NO-UNDO. 
    DEFINE PUBLIC VARIABLE iSkipRows        AS INTEGER   INIT 1 NO-UNDO.  
    DEFINE PUBLIC VARIABLE RecordCounter    AS INTEGER   NO-UNDO.
  
    DEFINE PROPERTY ValidDataSource AS LOGICAL NO-UNDO 
        GET:  
            RETURN valid-handle(THIS-OBJECT:DataSource) OR valid-handle(ProDataSource[1]). 
        END. 
        SET.
  
        
    CONSTRUCTOR PROTECTED BusinessEntity(INPUT hDS AS HANDLE):
        SUPER ( hDS). 
    END CONSTRUCTOR.
    
  
    CONSTRUCTOR PROTECTED BusinessEntity(): 
        SUPER ().
    END CONSTRUCTOR.


    // Missing mapping list 
    METHOD OVERRIDE PROTECTED  VOID AttachDataSources():
            
        ValidateDataSources().
        
        DEFINE VARIABLE hCurBuffer AS HANDLE NO-UNDO.
        DEFINE VARIABLE iIndex AS INTEGER NO-UNDO.
           
        REPEAT iIndex = 1 TO ProDataSet:NUM-BUFFERS:
            // Only need to worry about tables that have data-source attached..
            IF VALID-HANDLE(ProDataSource[iIndex]) THEN DO:
                hCurBuffer = ProDataSet:GET-BUFFER-HANDLE(iIndex).
                IF EXTENT(FieldListMapping) NE ? THEN 
                    hCurBuffer:ATTACH-DATA-SOURCE(ProDataSource[iIndex],FieldListMapping[iIndex]).
                ELSE hCurBuffer:ATTACH-DATA-SOURCE(ProDataSource[iIndex],?).
            END.
               
        END.
                                    
    END METHOD.


   // simple method for adding extents to skiplist character
    METHOD PROTECTED HANDLE skiplist( INPUT tablename AS CHARACTER):
       
        DEF VAR tmphSkipList AS CHAR EXTENT NO-UNDO. 
        DEF VAR icnt         AS INT    NO-UNDO. 
 
        IF EXTENT(THIS-OBJECT:SkipList) = ?  THEN
        DO:
            EXTENT(THIS-OBJECT:SkipList) = 1. 
            THIS-OBJECT:SkipList[1] = tablename. 
        END.
        ELSE 
        DO: 
            tmphSkiplist = THIS-OBJECT:SkipList. 
            EXTENT(THIS-OBJECT:SkipList) = ? . 
            EXTENT(THIS-OBJECT:SkipList) = (EXTENT(tmphSkipList) + 1). 
            DO icnt  = 1 TO EXTENT(tmphSkipList):
                THIS-OBJECT:SkipList[icnt] = tmphSkipList[icnt].
            END.
            THIS-OBJECT:SkipList[EXTENT(THIS-OBJECT:SkipList)] = tablename.  
        END.
        RETURN THIS-OBJECT:ProDataSet:GET-BUFFER-HANDLE(tablename).
    END. 


    // simple method for adding extents to prodatasource handle 
    METHOD PROTECTED HANDLE prodataSource( INPUT hDataSource AS handle):
       
        DEF VAR tmphSkipList AS handle EXTENT NO-UNDO. 
        DEF VAR icnt         AS INT    NO-UNDO. 
 
        IF EXTENT(THIS-OBJECT:prodataSource) = ?  THEN
        DO:
            EXTENT(THIS-OBJECT:prodataSource) = 1. 
            THIS-OBJECT:prodataSource[1] = hDataSource. 
        END.
        ELSE 
        DO: 
            tmphSkiplist = THIS-OBJECT:prodataSource. 
            EXTENT(THIS-OBJECT:prodataSource) = ? . 
            EXTENT(THIS-OBJECT:prodataSource) = (EXTENT(tmphSkipList) + 1). 
            DO icnt  = 1 TO EXTENT(tmphSkipList):
                THIS-OBJECT:prodataSource[icnt] = tmphSkipList[icnt].
            END.
            THIS-OBJECT:prodataSource[EXTENT(THIS-OBJECT:prodataSource)] = hDataSource.  
        END.
    END. 

    // simple method for adding extents to FieldListMapping  
    METHOD PROTECTED HANDLE FieldListMapping( INPUT cFieldList AS char):
       
        DEF VAR tmphSkipList AS char EXTENT NO-UNDO. 
        DEF VAR icnt         AS INT    NO-UNDO. 
 
        IF EXTENT(THIS-OBJECT:FieldListMapping) = ?  THEN
        DO:
            EXTENT(THIS-OBJECT:FieldListMapping) = 1. 
            THIS-OBJECT:FieldListMapping[1] = cFieldList. 
        END.
        ELSE 
        DO: 
            tmphSkiplist = THIS-OBJECT:FieldListMapping. 
            EXTENT(THIS-OBJECT:FieldListMapping) = ? . 
            EXTENT(THIS-OBJECT:FieldListMapping) = (EXTENT(tmphSkipList) + 1). 
            DO icnt  = 1 TO EXTENT(tmphSkipList):
                THIS-OBJECT:FieldListMapping[icnt] = tmphSkipList[icnt].
            END.
            THIS-OBJECT:FieldListMapping[EXTENT(THIS-OBJECT:FieldListMapping)] = cFieldList.  
        END.
    END. 

    // simple method for adding extents Prodatasource / must match num-buffers 
    METHOD PRIVATE HANDLE fixExtentProdataSource():
        DEFINE VARIABLE iIndex AS INTEGER NO-UNDO.
           
        IF EXTENT(THIS-OBJECT:prodataSource) LT ProDataSet:NUM-BUFFERS THEN 
        REPEAT iIndex = (EXTENT(THIS-OBJECT:prodataSource) + 1 ) TO ProDataSet:NUM-BUFFERS:
            THIS-OBJECT:prodataSource(?). 
        END.
    END. 

    // simple method for adding extents Prodatasource / must match num-buffers 
    METHOD PRIVATE HANDLE fixExtentFieldListMapping():
        DEFINE VARIABLE iIndex AS INTEGER NO-UNDO.
           
        IF EXTENT(THIS-OBJECT:FieldListMapping) LT ProDataSet:NUM-BUFFERS THEN 
        REPEAT iIndex = (EXTENT(THIS-OBJECT:FieldListMapping) + 1 ) TO ProDataSet:NUM-BUFFERS:
            THIS-OBJECT:FieldListMapping(?). 
        END.
    END. 


    // Add fields to table and prefix temp-table / dataset  - used by jsdo data-access
    METHOD PUBLIC HANDLE getDynamicDataset( INPUT tablename AS CHARACTER, createDatasource AS LOG):

        DEFINE VARIABLE TemptablePrefix AS CHAR INIT "tt" NO-UNDO. 
        DEFINE VARIABLE datasetPrefix   AS CHAR INIT "ds" NO-UNDO. 
        
        LOG-MANAGER:WRITE-MESSAGE("Dataset Create ( " + quoter(tablename) + ")","REQUEST" ).
         
        CREATE BUFFER THIS-OBJECT:DataSourceBuffer FOR TABLE tablename NO-ERROR.
        IF ERROR-STATUS:ERROR THEN 
        DO:
            LOG-MANAGER:WRITE-MESSAGE('No table with name:' +  tablename + ' in database!',"ERROR" ).
            RETURN ? . 
        END. 
        
        CREATE TEMP-TABLE hTempTable.
        hTempTable:CREATE-LIKE(THIS-OBJECT:DataSourceBuffer).
       
        hTempTable:ADD-NEW-FIELD("id","char",0,"X(3)","id").
        hTempTable:ADD-NEW-FIELD("seq","int").
        hTempTable:ADD-NEW-FIELD("seqrr","int").
      
        hTempTable:TEMP-TABLE-PREPARE(TemptablePrefix + tablename).
        hTargetBuffer = hTempTable:DEFAULT-BUFFER-HANDLE.
        
        CREATE DATASET THIS-OBJECT:DataSet.
        THIS-OBJECT:DataSet:NAME = datasetPrefix + tablename.
        THIS-OBJECT:DataSet:SET-BUFFERS(hTargetBuffer).    
        
        LOG-MANAGER:WRITE-MESSAGE("Dataset done: ( " + quoter(DataSet:NAME) + ")","REQUEST" ).
         
        IF createDatasource THEN 
        DO: 
            CREATE DATA-SOURCE THIS-OBJECT:DataSource.  
            THIS-OBJECT:DataSource:ADD-SOURCE-BUFFER (DataSourceBuffer,?).
        END. 
        RETURN THIS-OBJECT:dataset.
        
    END METHOD.
    
    // Reposition in datasource - shoud be refact 
    METHOD PUBLIC HANDLE setQueryRePosition(RepositionToRowid AS CHARACTER, 
        RepositionToRow as integer, 
        RowBatchSize as integer):
        
        LOG-MANAGER:WRITE-MESSAGE("setQueryRePosition:ToRowid( " + quoter(RepositionToRowid) + ") RepositionToRow:" + 
            quoter(RepositionToRow) + " BatchSize:" + 
            quoter(RowBatchSize) ,"BE" ).
         
        ASSIGN 
            RepositionToid = RepositionToRowid
            iSkipRows      = RepositionToRow
            iMaxRows       = RowBatchSize.
            
        /* if it's a static dataset */ 
        IF THIS-OBJECT:DataSource = ? THEN 
            THIS-OBJECT:DataSource = THIS-OBJECT:ProDataSource[1].
    
        IF THIS-OBJECT:hTargetBuffer = ? THEN 
            THIS-OBJECT:hTargetBuffer = THIS-OBJECT:ProDataSet:GET-BUFFER-HANDLE(1).
    
        IF RepositionToid > "" THEN  THIS-OBJECT:DataSource:RESTART-ROWID(1) = TO-ROWID ((RepositionToid)).
        ELSE IF iSkipRows <> ? AND iSkipRows > 0 THEN THIS-OBJECT:DataSource:RESTART-ROW = iSkipRows.
                       
        IF iMaxRows <> ? AND iMaxRows > 0 THEN 
        DO:
            hTargetBuffer:BATCH-SIZE = iMaxRows.
        END.
        ELSE 
        DO:
            IF RepositionToid > "" THEN  
                hTargetBuffer:BATCH-SIZE = 1.
            ELSE                                 
                hTargetBuffer:BATCH-SIZE = 0.
        END. 
    END. 
   
     
    METHOD PUBLIC HANDLE EnablePaging (RepositionToid as character, iSkipRows as integer, iMaxRows as integer):
         
        /* if it's a static dataset */ 
        IF THIS-OBJECT:DataSource = ? THEN 
            THIS-OBJECT:DataSource = THIS-OBJECT:ProDataSource[1].
    
        IF THIS-OBJECT:hTargetBuffer = ? THEN 
            THIS-OBJECT:hTargetBuffer = THIS-OBJECT:ProDataSet:GET-BUFFER-HANDLE(1).
    
        LOG-MANAGER:WRITE-MESSAGE("EnablePaging:DataSource (" + quoter(THIS-OBJECT:DataSource:NAME) +
            ") Target:("  + quoter(THIS-OBJECT:hTargetBuffer:NAME) + ")","BE" ).
       
        setQueryRePosition(RepositionToid, iSkipRows, iMaxRows).
        
        hTargetBuffer:SET-CALLBACK (EventTypeEnum:AfterFill,EventTypeEnum:AfterFill). 
        hTargetBuffer:SET-CALLBACK (EventTypeEnum:BeforeFill,EventTypeEnum:BeforeFill). 
        hTargetBuffer:SET-CALLBACK (EventTypeEnum:BeforeRowFill,EventTypeEnum:BeforeRowFill). 
        hTargetBuffer:SET-CALLBACK (EventTypeEnum:AfterRowFill,EventTypeEnum:AfterRowFill).
        hTargetBuffer:SET-CALLBACK (EventTypeEnum:RowDelete,EventTypeEnum:RowDelete).
        hTargetBuffer:SET-CALLBACK (EventTypeEnum:RowUpdate,EventTypeEnum:RowUpdate).
        hTargetBuffer:SET-CALLBACK (EventTypeEnum:FindFailed,EventTypeEnum:FindFailed).
        hTargetBuffer:SET-CALLBACK (EventTypeEnum:Synchronize,EventTypeEnum:Synchronize).
        
        
    END.
    
    // paging with class prop set 
    METHOD PUBLIC HANDLE EnablePaging ():
        enablePaging(RepositionToid,iSkipRows,iMaxRows).
    END.  
  
    // readdata method - logic missing in standard OE class lib - enables navigation repos 
    METHOD PUBLIC VOID ReadData (
        ip_top AS INTEGER, 
        ip_skip AS INTEGER,
        ip_ablfilter AS CHARACTER, 
        ip_id AS CHARACTER, 
        ip_orderby AS CHARACTER ):

        IF THIS-OBJECT:DataSource = ? THEN 
            THIS-OBJECT:DataSource = THIS-OBJECT:ProDataSource[1].
    
        IF THIS-OBJECT:hTargetBuffer = ? THEN 
            THIS-OBJECT:hTargetBuffer = THIS-OBJECT:ProDataSet:GET-BUFFER-HANDLE(1).
    
        LOG-MANAGER:WRITE-MESSAGE("ReadDataQuery:DataSource (" + quoter(THIS-OBJECT:DataSource:NAME) +
            ") Target:("  + quoter(THIS-OBJECT:hTargetBuffer:NAME) + ")","BE" ).

        DEFINE VARIABLE cWhere    AS CHARACTER NO-UNDO.
        DEFINE VARIABLE ablFilter AS CHARACTER NO-UNDO.
        DEFINE VARIABLE id        AS CHARACTER INITIAL ? NO-UNDO.
        DEFINE VARIABLE cOrderBy  AS CHARACTER INITIAL "" NO-UNDO.
     
        ASSIGN 
            id        = ip_id
            iMaxRows  = ip_top  
            iSkipRows = ip_skip 
            ablFilter = ip_ablfilter 
            cOrderBy  = ip_orderby
            cWhere    = "WHERE " + ablFilter .
        
        IF cOrderBy > "" THEN 
        DO:
            cOrderBy = REPLACE(cOrderBy, ",", " by ").
            cOrderBy = "by " + cOrderBy + " ".
            cOrderBy = REPLACE(cOrderBy, "by id desc", "").
            cOrderBy = REPLACE(cOrderBy, "by id ", "").
            cOrderBy = REPLACE(cOrderBy, "by seq desc", "").
            cOrderBy = REPLACE(cOrderBy, "by seq ", "").
        END.

        IF cOrderBy = ? THEN cOrderBy = "".
        cWhere = IF cWhere > "" THEN (cWhere + " " + cOrderBy) ELSE ("WHERE " + cOrderBy).

        EnablePaging(ip_id,ip_skip,ip_top).
        LOG-MANAGER:WRITE-MESSAGE("Query where:( " + quoter(cWhere) + ")","JSDO" ).
        fixExtentProdataSource(). 
        fixExtentFieldListMapping().
        SUPER:ReadData(cWhere).
    END. 
  
    METHOD OVERRIDE  VOID ReadData (filter as char): 
        fixExtentProdataSource().
        fixExtentFieldListMapping().
        EnablePaging().
        SUPER:ReadData(filter).
    END. 
      
    METHOD OVERRIDE  VOID ReadData (): 
        fixExtentProdataSource().
        fixExtentFieldListMapping().
        EnablePaging().
        SUPER:ReadData('').
    END. 
      
    // standard avfter-row-fill for adding id,seq seqrr field values to result set 
    METHOD PUBLIC VOID AFTER-ROW-FILL(INPUT DATASET-HANDLE dsDataSet):
        
        DEFINE VARIABLE hDataSource       AS HANDLE NO-UNDO.
        DEFINE VARIABLE hDataSourceBuffer AS HANDLE NO-UNDO. 
        DEFINE VARIABLE hTargetBuffer     AS HANDLE NO-UNDO. 
        DEFINE VARIABLE hId               AS HANDLE NO-UNDO. 
        DEFINE VARIABLE hSeq              AS HANDLE NO-UNDO. 
        DEFINE VARIABLE hSeqrr            AS HANDLE NO-UNDO. 
    
        ASSIGN 
            hTargetBuffer     = dsDataSet:GET-BUFFER-HANDLE(1)
            hDataSource       = hTargetBuffer:DATA-SOURCE
            hDataSourceBuffer = DataSource:GET-SOURCE-BUFFER(1).
      
        hId           = hTargetBuffer:BUFFER-FIELD('id') NO-ERROR.
        hSeq          = hTargetBuffer:BUFFER-FIELD('seq') NO-ERROR.
        hSeqrr        = hTargetBuffer:BUFFER-FIELD('seqrr') NO-ERROR.
        RecordCounter = RecordCounter + 1 .
    
        IF VALID-HANDLE(hid)    THEN  hTargetBuffer::id    = STRING(hDataSourceBuffer:ROWID) .
        IF VALID-HANDLE(hSeq)   THEN  hTargetBuffer::seq   = RecordCounter.
        IF VALID-HANDLE(hseqrr) THEN  hTargetBuffer::seqrr = hDataSource:QUERY:CURRENT-RESULT-ROW.
 
        LOG-MANAGER:WRITE-MESSAGE("seq:(" + 
            (IF VALID-HANDLE(hSeq) THEN string(hTargetBuffer::seq,"9999") ELSE string(RecordCounter,"9999") )  + ":" + 
            (IF VALID-HANDLE(hseqrr) THEN string(hTargetBuffer::seqrr,"9999") ELSE "" ) +
            ") id(" + quoter(STRING(hDataSourceBuffer:ROWID)) + ")","REQUEST" ).
            
  
    END.
    
    METHOD PUBLIC VOID BEFORE-Fill(INPUT DATASET-HANDLE dsDataSet):
    END. 

    METHOD PUBLIC VOID BEFORE-ROW-FILL(INPUT DATASET-HANDLE dsDataSet):
    END. 
    
    METHOD PUBLIC VOID AFTER-Fill(INPUT DATASET-HANDLE dsDataSet):
    END. 

    METHOD PUBLIC VOID ROW-DELETE(INPUT DATASET-HANDLE dsDataSet):
    END.
    
    METHOD PUBLIC VOID ROW-UPDATE(INPUT DATASET-HANDLE dsDataSet):
    END.
    
    METHOD PUBLIC VOID FIND-FAILED(INPUT DATASET-HANDLE dsDataSet):
    END.
    
    METHOD PUBLIC VOID SYNCHRONIZE(INPUT DATASET-HANDLE dsDataSet):
    END.

END CLASS.




/*
    METHOD PUBLIC VOID ReadDataQuery (
        ip_top AS INTEGER, 
        ip_skip AS INTEGER,
        ip_ablfilter AS CHARACTER, 
        ip_id AS CHARACTER, 
        ip_orderby AS CHARACTER
        /*, OUTPUT DATASET-HANDLE hDataSet */ ):


        IF THIS-OBJECT:DataSource = ? THEN 
           THIS-OBJECT:DataSource = THIS-OBJECT:ProDataSource[1].
    
        IF THIS-OBJECT:hTargetBuffer = ? THEN 
           THIS-OBJECT:hTargetBuffer = THIS-OBJECT:ProDataSet:GET-BUFFER-HANDLE(1).
    
        LOG-MANAGER:WRITE-MESSAGE("ReadDataQuery:DataSource (" + quoter(THIS-OBJECT:DataSource:NAME) +
            ") Target:("  + quoter(THIS-OBJECT:hTargetBuffer:NAME) + ")","BE" ).

        DEFINE VARIABLE cWhere         AS CHARACTER NO-UNDO.
        DEFINE VARIABLE hQuery         AS HANDLE    NO-UNDO.
        DEFINE VARIABLE ablFilter      AS CHARACTER NO-UNDO.
        DEFINE VARIABLE id             AS CHARACTER INITIAL ? NO-UNDO.
        DEFINE VARIABLE cOrderBy       AS CHARACTER INITIAL "" NO-UNDO.
     
        ASSIGN 
            id        = ip_id
            iMaxRows  = ip_top  
            iSkipRows = ip_skip 
            ablFilter = ip_ablfilter 
            cOrderBy  = ip_orderby
            cWhere    = "WHERE " + ablFilter .
        
        IF cOrderBy > "" THEN 
        DO:
            cOrderBy = REPLACE(cOrderBy, ",", " by ").
            cOrderBy = "by " + cOrderBy + " ".
            cOrderBy = REPLACE(cOrderBy, "by id desc", "").
            cOrderBy = REPLACE(cOrderBy, "by id ", "").
            cOrderBy = REPLACE(cOrderBy, "by seq desc", "").
            cOrderBy = REPLACE(cOrderBy, "by seq ", "").
        END.

        IF cOrderBy = ? THEN cOrderBy = "".
        cWhere = IF cWhere > "" THEN (cWhere + " " + cOrderBy) ELSE ("WHERE " + cOrderBy).

        EnablePaging(ip_id,ip_skip,ip_top).
        
        THIS-OBJECT:hTargetBuffer:ATTACH-DATA-SOURCE(THIS-OBJECT:DataSource). 
        
        LOG-MANAGER:WRITE-MESSAGE("Query where:( " + quoter(cWhere) + ")","JSDO" ).
        THIS-OBJECT:DataSource:FILL-WHERE-STRING = cWhere.
 
       // THIS-OBJECT:DataSource:query-prepare(THIS-OBJECT:DataSource:FILL-WHERE-STRING). 
         
        DataSet:FILL().
         
      //  SUPER:ReadData('').
      
      
    END. 



    METHOD PUBLIC VOID Read (
        ip_top AS INTEGER, 
        ip_skip AS INTEGER,
        ip_ablfilter AS CHARACTER, 
        ip_id AS CHARACTER, 
        ip_orderby AS CHARACTER, 
        OUTPUT DATASET-HANDLE hDataSet):




        DEFINE VARIABLE tablename AS CHARACTER init "Avdeling" NO-UNDO.         

        LOG-MANAGER:WRITE-MESSAGE("Read Obselete:( " + quoter(tablename) + ")","BE" ).
    
        
       // DEFINE VARIABLE tablename      AS CHARACTER NO-UNDO.         
       
        DEFINE VARIABLE cWhere         AS CHARACTER NO-UNDO.
        DEFINE VARIABLE hQuery         AS HANDLE    NO-UNDO.
        DEFINE VARIABLE lUseReposition AS LOGICAL   NO-UNDO.
        DEFINE VARIABLE iCount         AS INTEGER   NO-UNDO.
        DEFINE VARIABLE ablFilter      AS CHARACTER NO-UNDO.
        DEFINE VARIABLE id             AS CHARACTER INITIAL ? NO-UNDO.
        DEFINE VARIABLE iMaxRows       AS INTEGER   INITIAL ? NO-UNDO.
        DEFINE VARIABLE iSkipRows      AS INTEGER   INITIAL ? NO-UNDO.
        DEFINE VARIABLE cOrderBy       AS CHARACTER INITIAL "" NO-UNDO.
        DEFINE VARIABLE iSeq           AS INTEGER   NO-UNDO. 

        DEFINE VARIABLE baseName       AS CHARACTER NO-UNDO.    
        baseName = CAPS(SUBSTRING(tableName, 1, 1)) + SUBSTRING(tableName, 2).

        ASSIGN 
            iMaxRows  = ip_top  
            iSkipRows = ip_skip 
            ablFilter = ip_ablfilter 
            id        = ip_id
            cOrderBy  = ip_orderby
            cWhere    = "WHERE " + ablFilter .
        
        hDataSet = getDynamicDataset (tablename, TRUE ).
        
        LOG-MANAGER:WRITE-MESSAGE("DataSource Buffer:( " + quoter(DataSourceBuffer:NAME) + ")","JSDO" ).
    
        IF cOrderBy > "" THEN 
        DO:
            cOrderBy = REPLACE(cOrderBy, ",", " by ").
            cOrderBy = "by " + cOrderBy + " ".
            cOrderBy = REPLACE(cOrderBy, "by id desc", "").
            cOrderBy = REPLACE(cOrderBy, "by id ", "").
            cOrderBy = REPLACE(cOrderBy, "by seq desc", "").
            cOrderBy = REPLACE(cOrderBy, "by seq ", "").
        END.

        LOG-MANAGER:WRITE-MESSAGE("OrderBy:( " + quoter(cOrderBy) + ")","JSDO" ).

        lUseReposition = iSkipRows <> ?.

        IF iMaxRows <> ? AND iMaxRows > 0 THEN 
        DO:
            hTargetBuffer:BATCH-SIZE = iMaxRows.
        END.
        ELSE 
        DO:
            IF id > "" THEN
                hTargetBuffer:BATCH-SIZE = 1.
            ELSE                                 
                hTargetBuffer:BATCH-SIZE = 0.
        END.                        

        hTargetBuffer:ATTACH-DATA-SOURCE(DataSource).

        IF cOrderBy = ? THEN cOrderBy = "".
        cWhere = IF cWhere > "" THEN (cWhere + " " + cOrderBy) 
        ELSE ("WHERE " + cOrderBy).

      
        LOG-MANAGER:WRITE-MESSAGE("Query where:( " + quoter(cWhere) + ")","JSDO" ).
        DataSource:FILL-WHERE-STRING = cWhere.



/*

        IF lUseReposition THEN 
        DO:
            LOG-MANAGER:WRITE-MESSAGE("Reposition:( " + quoter(lUseReposition) + ")","JSDO" ).
            
            hQuery = DataSource:QUERY.
            hQuery:QUERY-OPEN.

            IF id > "" AND id <> "?" THEN 
                hQuery:REPOSITION-TO-ROWID(TO-ROWID(id)).

            ELSE IF iSkipRows <> ? AND iSkipRows > 0 THEN 
                DO:
                    hQuery:REPOSITION-TO-ROW(iSkipRows).
                    IF NOT DataSourceBuffer:AVAILABLE THEN
                        hQuery:GET-NEXT() NO-ERROR.
                END.

            iCount = 0.
            REPEAT WHILE NOT hQuery:QUERY-OFF-END AND iCount < iMaxRows:
                hQuery:GET-NEXT () NO-ERROR.
                IF DataSourceBuffer:AVAILABLE THEN 
                DO:
                    hTargetBuffer:BUFFER-CREATE.
                    hTargetBuffer:BUFFER-COPY( DataSourceBuffer)  .
                    ASSIGN  
                        hTargetBuffer::id  = STRING((DataSourceBuffer:ROWID))
                        iSeq               = iSeq + 1
                        hTargetBuffer::seq = iSeq.
                    LOG-MANAGER:WRITE-MESSAGE("seq:(" + string(hTargetBuffer::seq,"9999") + ") id(" + quoter(hTargetBuffer::id) + ")","JSDO" ).
                END.
                iCount = iCount + 1.
            END.
        END.
        ELSE 
        DO:
            RecordCounter = 0 . 
            IF id > "" THEN  DataSource:RESTART-ROWID(1) = TO-ROWID ((id)).
            hTargetBuffer:SET-CALLBACK ("AFTER-ROW-FILL", "After-Row-Fill").
            hDataSet:FILL().
        END.


        FINALLY:
            hTargetBuffer:DETACH-DATA-SOURCE() NO-ERROR.
           
            DELETE OBJECT hDataSet NO-ERROR. 
            
        END. 
*/

    
    END. 
  
*/  
    
/*
METHOD PUBLIC VOID Read (
    ip_top AS INTEGER, 
    ip_skip AS INTEGER,
    ip_ablfilter AS CHARACTER, 
    ip_id AS CHARACTER, 
    ip_orderby AS CHARACTER, 
    aa as char, 
    OUTPUT DATASET-HANDLE hDataSet):

   DEFINE VARIABLE tablename      AS CHARACTER init "Avdeling" NO-UNDO.         
 
   LOG-MANAGER:WRITE-MESSAGE("Read Obselete:( " + quoter(tablename) + ")","BE" ).
    
        
   // DEFINE VARIABLE tablename      AS CHARACTER NO-UNDO.         
       
    DEFINE VARIABLE cWhere         AS CHARACTER NO-UNDO.
    DEFINE VARIABLE hQuery         AS HANDLE    NO-UNDO.
    DEFINE VARIABLE lUseReposition AS LOGICAL   NO-UNDO.
    DEFINE VARIABLE iCount         AS INTEGER   NO-UNDO.
    DEFINE VARIABLE ablFilter      AS CHARACTER NO-UNDO.
    DEFINE VARIABLE id             AS CHARACTER INITIAL ? NO-UNDO.
    DEFINE VARIABLE iMaxRows       AS INTEGER   INITIAL ? NO-UNDO.
    DEFINE VARIABLE iSkipRows      AS INTEGER   INITIAL ? NO-UNDO.
    DEFINE VARIABLE cOrderBy       AS CHARACTER INITIAL "" NO-UNDO.
    DEFINE VARIABLE iSeq           AS INTEGER   NO-UNDO. 

    DEFINE VARIABLE baseName       AS CHARACTER NO-UNDO.    
    baseName = CAPS(SUBSTRING(tableName, 1, 1)) + SUBSTRING(tableName, 2).

    ASSIGN 
        iMaxRows  = ip_top  
        iSkipRows = ip_skip 
        ablFilter = ip_ablfilter 
        id        = ip_id
        cOrderBy  = ip_orderby
        cWhere    = "WHERE " + ablFilter .
        
    hDataSet = getDynamicDataset (tablename, TRUE ).
        
    LOG-MANAGER:WRITE-MESSAGE("DataSource Buffer:( " + quoter(DataSourceBuffer:NAME) + ")","JSDO" ).
    
    IF cOrderBy > "" THEN 
    DO:
        cOrderBy = REPLACE(cOrderBy, ",", " by ").
        cOrderBy = "by " + cOrderBy + " ".
        cOrderBy = REPLACE(cOrderBy, "by id desc", "").
        cOrderBy = REPLACE(cOrderBy, "by id ", "").
        cOrderBy = REPLACE(cOrderBy, "by seq desc", "").
        cOrderBy = REPLACE(cOrderBy, "by seq ", "").
    END.

    LOG-MANAGER:WRITE-MESSAGE("OrderBy:( " + quoter(cOrderBy) + ")","JSDO" ).
    
    lUseReposition = iSkipRows <> ?.

    IF iMaxRows <> ? AND iMaxRows > 0 THEN 
    DO:
        hTargetBuffer:BATCH-SIZE = iMaxRows.
    END.
    ELSE 
    DO:
        IF id > "" THEN
            hTargetBuffer:BATCH-SIZE = 1.
        ELSE                                 
            hTargetBuffer:BATCH-SIZE = 0.
    END.                        

    hTargetBuffer:ATTACH-DATA-SOURCE(DataSource).

    IF cOrderBy = ? THEN cOrderBy = "".
    cWhere = IF cWhere > "" THEN (cWhere + " " + cOrderBy) 
    ELSE ("WHERE " + cOrderBy).
      
    LOG-MANAGER:WRITE-MESSAGE("Query where:( " + quoter(cWhere) + ")","JSDO" ).
      
    DataSource:FILL-WHERE-STRING = cWhere.

    IF lUseReposition THEN 
    DO:
        LOG-MANAGER:WRITE-MESSAGE("Reposition:( " + quoter(lUseReposition) + ")","JSDO" ).
            
        hQuery = DataSource:QUERY.
        hQuery:QUERY-OPEN.

        IF id > "" AND id <> "?" THEN 
            hQuery:REPOSITION-TO-ROWID(TO-ROWID(id)).

        ELSE IF iSkipRows <> ? AND iSkipRows > 0 THEN 
            DO:
                hQuery:REPOSITION-TO-ROW(iSkipRows).
                IF NOT DataSourceBuffer:AVAILABLE THEN
                    hQuery:GET-NEXT() NO-ERROR.
            END.

        iCount = 0.
        REPEAT WHILE NOT hQuery:QUERY-OFF-END AND iCount < iMaxRows:
            hQuery:GET-NEXT () NO-ERROR.
            IF DataSourceBuffer:AVAILABLE THEN 
            DO:
                hTargetBuffer:BUFFER-CREATE.
                hTargetBuffer:BUFFER-COPY( DataSourceBuffer)  .
                ASSIGN  
                    hTargetBuffer::id  = STRING((DataSourceBuffer:ROWID))
                    iSeq               = iSeq + 1
                    hTargetBuffer::seq = iSeq.
                LOG-MANAGER:WRITE-MESSAGE("seq:(" + string(hTargetBuffer::seq,"9999") + ") id(" + quoter(hTargetBuffer::id) + ")","JSDO" ).
            END.
            iCount = iCount + 1.
        END.
    END.
    ELSE 
    DO:
        RecordCounter = 0 . 
        IF id > "" THEN  DataSource:RESTART-ROWID(1) = TO-ROWID ((id)).
        hTargetBuffer:SET-CALLBACK ("AFTER-ROW-FILL", "After-Row-Fill").
        hDataSet:FILL().
    END.

    FINALLY:
        hTargetBuffer:DETACH-DATA-SOURCE() NO-ERROR.
           
        DELETE OBJECT hDataSet NO-ERROR. 
            
    END. 
END. 
*/
    
