 
/*------------------------------------------------------------------------
   File        : parse
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : colde
   Created     : Wed Mar 19 08:45:17 CET 2025
   Notes       : 
 ----------------------------------------------------------------------*/

USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS web.api.graphql.schemadef: 

    DEFINE variable statement_seperator_start as char   init "~{" no-undo. 
    DEFINE variable statement_seperator_end   as char   init "~}" no-undo. 
    DEFINE VARIABLE lbody AS longchar no-undo. 
  
    DEFINE TEMP-TABLE dtdatabasesschema   NO-UNDO SERIALIZE-NAME "schema"  
        FIELD body AS clob SERIALIZE-NAME "schema". 

    DEFINE DATASET dsdatabasesschema FOR dtdatabasesschema.
   
   // DEFINE OUTPUT PARAMETER DATASET FOR dsdatabasesschema.
    
    CONSTRUCTOR PUBLIC schemadef():
        // simple().
        DATASET dsdatabasesschema:SERIALIZE-HIDDEN = TRUE.
    END CONSTRUCTOR.
    
    METHOD LONGCHAR getschema ():
        readadvanced(). 
        RETURN lBody. 
    END METHOD.
    
    METHOD void readsimple ():
       DEF VAR lc AS LONGCHAR. 
       DEF VAR cFile AS CHAR INIT "C:\projects\pasoem8m\m8m\web\api\graphql\easyschema.i" NO-UNDO. 
       COPY-LOB FROM FILE cFile TO lbody. 
    END METHOD.

    METHOD void readadvanced ():
       DEF VAR lc AS LONGCHAR. 
       DEF VAR cFile AS CHAR INIT "C:\projects\pasoem8m\m8m\web\api\graphql\advancedschema.i" NO-UNDO. 
       COPY-LOB FROM FILE cFile TO lbody. 
    END METHOD.
    
    METHOD HANDLE getDataSet ():
        simple ().
        RETURN DATASET dsdatabasesschema:handle. 
    END METHOD.

    METHOD void simple ():
       DEF VAR lc AS LONGCHAR. 
       DEF VAR cFile AS CHAR INIT "web/api/graphql/easyschema.i" NO-UNDO. 
       CREATE dtdatabasesschema. 
       COPY-LOB FROM FILE cFile TO dtdatabasesschema.body. 
    END METHOD.

    METHOD void advanced ():
       DEF VAR lc AS LONGCHAR. 
       DEF VAR cFile AS CHAR INIT "web/api/graphql/advancedschema.i" NO-UNDO. 
       CREATE dtdatabasesschema. 
       COPY-LOB FROM FILE cFile TO dtdatabasesschema.body. 
    END METHOD.


END CLASS.