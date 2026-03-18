 

USING Progress.Lang.*.
using web.api.graphql.StringConstant.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS web.api.graphql.parse: 

    DEFINE VARIABLE graphqlquery              as char   no-undo. 
    DEFINE variable statement_seperator_start as char   init "~{" no-undo. 
    DEFINE variable statement_seperator_end   as char   init "~}" no-undo. 
    DEFINE VARIable ilevelcouter as int no-undo. 
    DEFINE VARIABLE graphqlDataset            as handle no-undo. 

    DEFINE TEMP-TABLE datasetbuilder NO-UNDO
        FIELD levelcouter     AS INT
        FIELD tabename        AS CHAR 
        FIELD fieldlist       AS CHAR 
        FIELD sortby          AS CHAR 
        FIELD filterStatement AS CHAR 
        FIELD uniqueid        AS CHAR
        FIELD uniqueField     AS CHAR
        FIELD wherestatement  AS CHAR 
        FIELD methodcall      AS CHAR.  


    CONSTRUCTOR PUBLIC parse (input GraphGlquery as character ):

        SUPER ().
        THIS-OBJECT:graphqlquery = GraphGlquery. // REPLACE(GraphGlquery," ","").  
        parsestatement().
    END CONSTRUCTOR.


    METHOD char execute (input cString as char):

        DEF    VAR      icnt       as int  no-undo.           
        DEFINE variable blocks as char extent no-undo. 
        define variable level      as int  no-undo. 

        extent(blocks) = num-entries(graphqlquery,StringConstant:CURLY_OPEN).
        level = extent(blocks).
        DO icnt = 1 to extent(blocks):
           
             index
        END.     
        
        return "". 
    END METHOD.


    METHOD void buildDatasetTable (statements as char extent):
        DEF VAR icnt as int no-undo.           
        DO icnt = 1 to extent(statements):    
            CheckForNewTable(statements[icnt]).
            // CheckForFields(statements[icnt]).
        END. 

        for each datasetbuilder: 
            message datasetbuilder.tabename datasetbuilder.fieldlist 
            datasetbuilder.levelcouter view-as alert-box. 
        end.         

    END METHOD.


    METHOD void CheckForNewTable (statement as char ):
        
        DEF VAR sep AS CHAR INIT "|" NO-UNDO.
        def var list as char no-undo.
        def var params as char no-undo. 
        def var icnt as int no-undo. 
        def var list2 as char no-undo. 
          
        assign
        statement = left-trim(trim(statement))
        statement = REPLACE(statement,"(",sep)
        statement = REPLACE(statement,")",sep).
        
        // aa aa aaa(xxx: xx)
        IF NUM-ENTRIES(statement,sep) = 3 THEN
        do: 
            list   = ENTRY(1,statement,sep).
            params = ENTRY(2,statement,sep).
            
            do iCnt = 1 to num-entries(list,''):
                if num-entries(list,'') = icnt then 
                do:
                   CREATE datasetbuilder.
                   datasetbuilder.tabename = ENTRY(icnt,list,'').
                   ilevelcouter = ilevelcouter + 1.
                   datasetbuilder.levelcouter = ilevelcouter .
                end. 
                else list2 = list2 + ' ' + ENTRY(icnt,list,'').
            end.  
            list2 = left-trim(trim(list2)).
            if list2 ne "" then 
            do:
               find first datasetbuilder where datasetbuilder.levelcouter = ilevelcouter - 1. 
               datasetbuilder.fieldlist  = list2 .
            end. 
        END. 
        ELSE .
        
        /*
        ELSE // aaa(xxx: xx)
        IF  NUM-ENTRIES(statement,'(') GE 3 THEN 
        DO: 
            CREATE datasetbuilder.
            datasetbuilder.tabename = statement.
            ilevelcouter = ilevelcouter + 1.
            datasetbuilder.levelcouter = ilevelcouter .
            RETURN.    
        END.
        ELSE 
        */ 
        
         
    END. 
 
  
    METHOD progress.lang.object parsestatement ():
        DEF    VAR      icnt       as int  no-undo.           
        DEFINE variable statements as char extent no-undo. 
        define variable level      as int  no-undo. 
      
  //      message THIS-OBJECT:graphqlquery
  //          num-entries(graphqlquery,statement_seperator_start)
  //          num-entries(graphqlquery,statement_seperator_end) view-as alert-box.
   
        extent(statements) = num-entries(graphqlquery,statement_seperator_start).
        level = extent(statements).
        DO icnt = 1 to extent(statements): 
            statements[icnt] = removewhitespace(left-trim(trim(entry(icnt,graphqlquery,statement_seperator_start)))).
            if statements[icnt] = "" then level = level - 1 .
          
            if icnt = extent(statements) then 
                statements[icnt] = removewhitespace(REPLACE(statements[icnt],statement_seperator_end,'')).
        END.     
        
        buildDatasetTable(statements).        
        
       //  message statements[icnt] view-as alert-box. 
       // LOG-MANAGER:WRITE-MESSAGE("Method=" + quoter(poRequest:Method),"REQUEST").
    END. 


    METHOD char removewhitespace (input cString as char):
        def var icnt as int  no-undo. 
        def var tmp  as char no-undo. 
        tmp = cString.
        do icnt = 1 to 10:
            tmp = REPLACE(tmp,"  "," ").
        end.     
        return tmp. 
    END METHOD.
  

    METHOD void createdataset ():
        CREATE DATASET graphqlDataset.     
    END METHOD.

END CLASS.