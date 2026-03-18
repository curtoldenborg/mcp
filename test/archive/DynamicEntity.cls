 
/*------------------------------------------------------------------------
   File        : proventus.DynamicEntity 
   Syntax      : 
   Author(s)   : Curt
   Notes       : Used for general CRUD access / any table  
 ----------------------------------------------------------------------*/

USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS web.DynamicEntity INHERITS web.BusinessEntity IMPLEMENTS web.IBusinessEntity:
  
    DEFINE        VARIABLE baseName  AS CHARACTER NO-UNDO.    
    DEFINE PUBLIC VARIABLE tableName AS CHARACTER NO-UNDO.
 
    CONSTRUCTOR PUBLIC DynamicEntity():
         // stub 
    END. 
    
    CONSTRUCTOR PUBLIC  DynamicEntity(INPUT tableName AS CHARACTER):
        
        DEFINE VARIABLE DataSourceArray AS HANDLE    NO-UNDO EXTENT 1.
        DEFINE VARIABLE SkipListArray   AS CHARACTER NO-UNDO EXTENT 1.

        SUPER ( THIS-OBJECT:getDynamicDataset (tablename, TRUE )).
        
        IF NOT ValidDataSource THEN RETURN ERROR .   
        
        THIS-OBJECT:tableName = tableName.
        
        DataSourceArray[1] =  THIS-OBJECT:DataSource.
        SkipListArray[1]   = "".
         
        THIS-OBJECT:ProDataSource = DataSourceArray.
        THIS-OBJECT:SkipList      = SkipListArray.
    
    END CONSTRUCTOR.

    
    METHOD PUBLIC VOID Read( OUTPUT DATASET-HANDLE hdsDynamic):
        LOG-MANAGER:WRITE-MESSAGE("Read - web.DynamicEntity ( " + quoter(THIS-OBJECT:ProDataSet:NAME) + ")","REQUEST" ).
        SUPER:ReadData().
        hdsDynamic = THIS-OBJECT:ProDataSet.
        LOG-MANAGER:WRITE-MESSAGE("Read - web.DynamicEntity - Done ( " + quoter(THIS-OBJECT:ProDataSet:NAME) + ")","REQUEST" ).
    END METHOD.

    METHOD PUBLIC VOID Read( INPUT filter AS CHARACTER, OUTPUT DATASET-HANDLE hdsDynamic):
        LOG-MANAGER:WRITE-MESSAGE("Read - web.DynamicEntity ( " + quoter(THIS-OBJECT:ProDataSet:NAME) + ")","REQUEST" ).
        SUPER:ReadData(filter).
        hdsDynamic = THIS-OBJECT:ProDataSet.
        LOG-MANAGER:WRITE-MESSAGE("Read - web.DynamicEntity - Done ( " + quoter(THIS-OBJECT:ProDataSet:NAME) + ")","REQUEST" ).
    END METHOD.

    METHOD PUBLIC VOID Read(ip_top AS INT, ip_skip AS INT, ip_abfilter AS CHAR,ip_id AS CHAR,ip_orderby AS CHAR , OUTPUT DATASET-HANDLE hdsDynamic):
        LOG-MANAGER:WRITE-MESSAGE("Read - web.DynamicEntity ( " + quoter(THIS-OBJECT:ProDataSet:NAME) + ")","REQUEST" ).
        SUPER:ReadData(ip_top,ip_skip,ip_abfilter,ip_id,ip_orderby).
        hdsDynamic = THIS-OBJECT:ProDataSet.
        LOG-MANAGER:WRITE-MESSAGE("Read - web.DynamicEntity - Done ( " + quoter(THIS-OBJECT:ProDataSet:NAME) + ")","REQUEST" ).
    END METHOD.

    METHOD PUBLIC VOID Create(INPUT-OUTPUT DATASET-HANDLE dsDynamic):            
        SUPER:CreateData(DATASET-HANDLE dsDynamic BY-REFERENCE).        
    END METHOD.    
    
    METHOD PUBLIC VOID Update(INPUT-OUTPUT DATASET-HANDLE dsDynamic):            
        SUPER:UpdateData(DATASET-HANDLE dsDynamic BY-REFERENCE).          
    END METHOD.
    
    METHOD PUBLIC VOID Delete(INPUT-OUTPUT DATASET-HANDLE dsDynamic):                    
        SUPER:DeleteData(DATASET-HANDLE dsDynamic BY-REFERENCE).
    END METHOD.
    
END CLASS.
