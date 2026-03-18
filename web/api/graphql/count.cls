 
/*------------------------------------------------------------------------
   File        : count
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : colde
   Created     : Wed Mar 19 09:56:10 CET 2025
   Notes       : 
 ----------------------------------------------------------------------*/

USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.


CLASS web.api.graphql.count: 

    DEFINE PUBLIC VARIABLE numberOfRecords AS INTEGER NO-UNDO. 

    CONSTRUCTOR PUBLIC count (INPUT cTablename AS CHARACTER ):
        SUPER ().
        numberOfRecords = countRecords(cTablename,'').
    END CONSTRUCTOR.

 
    CONSTRUCTOR PUBLIC count (INPUT cTablename AS CHARACTER, cWhereStatement AS CHARACTER  ):
        SUPER ().
        numberOfRecords = countRecords(cTablename,cWhereStatement).
    END CONSTRUCTOR.

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

    METHOD logical fillTempTableFromDatabaseTable (INPUT cTablename AS CHARACTER, cWhereStatement AS CHARACTER  ):

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
    
        RETURN true.
 
        FINALLY:
           DELETE OBJECT h_qry NO-ERROR.
           DELETE OBJECT h_buffer NO-ERROR.
        END.     
    END METHOD.

END CLASS.

/*
QUERY _query:QUERY-PREPARE("for each _file where not _hidden  ").

BUFFER dtdatabasesschema:ATTACH-DATA-SOURCE(DATA-SOURCE _datasource:handle, "tablename,_file-name":U).

DATASET dsdatabasesschema:fill().
BUFFER dtdatabasesschema:DETACH-DATA-SOURCE().

PROCEDURE _postFill PRIVATE:

    DEFINE INPUT PARAMETER dataset FOR dsdatabasesschema.
    dtdatabasesschema.tablearea = "pub" .    
    dtdatabasesschema.tablename = "pub." + dtdatabasesschema.tablename.
    
END PROCEDURE.
*/
