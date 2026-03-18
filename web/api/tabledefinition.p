

BLOCK-LEVEL ON ERROR UNDO, THROW.


DEFINE TEMP-TABLE dtdatabasesschema SERIALIZE-NAME "tableinformation"
    FIELD tablenumber AS INTEGER   SERIALIZE-NAME "tablenumber"          
    FIELD tablename   AS CHARACTER SERIALIZE-NAME "tablename" .         

DEFINE TEMP-TABLE dtfield SERIALIZE-NAME "fields"
    FIELD tablenumber AS INTEGER   SERIALIZE-HIDDEN          
    FIELD fieldname   AS CHARACTER SERIALIZE-NAME "fieldname"          
    FIELD datatype    AS CHARACTER SERIALIZE-NAME "datatype" .         

DEFINE DATASET dsdatabasesschema FOR dtdatabasesschema, dtfield
    DATA-RELATION relation1 FOR dtdatabasesschema, dtfield
    RELATION-FIELDS (tablenumber, tablenumber) NESTED.

DEFINE INPUT PARAMETER cTableName AS CHAR NO-UNDO. 
DEFINE OUTPUT PARAMETER DATASET FOR dsdatabasesschema.

DATASET dsdatabasesschema:SERIALIZE-HIDDEN = TRUE. 

FOR EACH _file WHERE NOT _hidden AND _file._file-name = cTableName , EACH _field OF _file BREAK BY (_file._file-name): 
    IF FIRST-OF (_file._file-name) THEN 
    DO:
        CREATE dtdatabasesschema. 
        dtdatabasesschema.tablename = _file._file-name. 
        dtdatabasesschema.tablenumber = _file._file-number. 
        
    END. 

    CREATE dtfield. 
    dtfield.fieldname = _field._field-name. 
    dtfield.datatype  = _field._data-type.  
    dtfield.tablenumber = _file._file-number. 
END. 

