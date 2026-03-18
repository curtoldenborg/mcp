

BLOCK-LEVEL ON ERROR UNDO, THROW.

DEFINE TEMP-TABLE dtdatabasesschema SERIALIZE-NAME "databaseschema"
    FIELD tablename   AS CHARACTER SERIALIZE-NAME "tablename"       
    FIELD tablearea   AS CHARACTER SERIALIZE-NAME "area"   
    FIELD tablenumber AS INT  .
        
DEFINE DATASET dsdatabasesschema FOR dtdatabasesschema.

DEFINE OUTPUT PARAMETER DATASET FOR dsdatabasesschema.

DATASET dsdatabasesschema:SERIALIZE-HIDDEN = TRUE. 

FOR EACH _file WHERE NOT _hidden  : 
    CREATE dtdatabasesschema. 
    dtdatabasesschema.tablename = "pub." + _file._file-name. 
    dtdatabasesschema.tablearea = "pub".
    dtdatabasesschema.tablenumber = _file._file-number. 
END. 
