
/*------------------------------------------------------------------------
    File        : web.IBusinessEntity
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.

INTERFACE web.IBusinessEntity:  
    //METHOD PUBLIC LONGCHAR Read(filter AS CHARACTER).
    
    DEFINE PROPERTY ValidDataSource AS LOGICAL NO-UNDO  GET. SET.
    METHOD PUBLIC VOID Read(OUTPUT DATASET-HANDLE hDataSet).
    METHOD PUBLIC VOID Read(filter AS CHARACTER, OUTPUT DATASET-HANDLE hDataSet).
    METHOD PUBLIC VOID Read(ip_top AS INT, ip_skip AS INT, ip_abfilter AS CHAR, ip_id AS CHAR, ip_orderby AS CHAR , OUTPUT DATASET-HANDLE hDataSet).
    
   // METHOD PUBLIC VOID Save( OUTPUT DATASET-HANDLE hDataSet).
    
    
END INTERFACE.