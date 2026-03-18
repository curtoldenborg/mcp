
/*------------------------------------------------------------------------
    File        : employee.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Curt
    Created     : Wed Mar 20 11:06:02 CET 2024
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

BLOCK-LEVEL ON ERROR UNDO, THROW.

/* ********************  Preprocessor Definitions  ******************** */


DEFINE TEMP-TABLE dtEmployee SERIALIZE-NAME "items"
    FIELD employeeid AS INTEGER
    FIELD NAME       AS CHARACTER SERIALIZE-NAME "name"
    FIELD phone      AS CHARACTER 
    FIELD email      AS CHARACTER .         
        
DEFINE DATASET dsEmployee FOR dtEmployee.

DEFINE INPUT PARAMETER  EmployeeId LIKE Employee.empnum NO-UNDO.
DEFINE OUTPUT PARAMETER DATASET FOR DsEmployee.

DEFINE QUERY qEmployee FOR Employee.
DEFINE DATA-SOURCE srcEmployee FOR QUERY qEmployee.

DATASET dsEmployee:SERIALIZE-HIDDEN = TRUE. 


// query qEmployee:query-prepare(substitute("for each Employee &1 by Employee.name":U, if EmployeeId = -1 then "" else substitute("where Employee.empnum = &1":U, EmployeeId))).


QUERY qEmployee:QUERY-PREPARE("for each Employee ").

BUFFER dtEmployee:ATTACH-DATA-SOURCE(DATA-SOURCE srcEmployee:handle, "name,firstname,EmployeeId,empnum,phone,workphone":U).
BUFFER dtEmployee:SET-CALLBACK-PROCEDURE("AFTER-ROW-FILL","_postEmployeeFill").

DATASET dsEmployee:fill().
BUFFER dtEmployee:DETACH-DATA-SOURCE().


PROCEDURE _postEmployeeFill PRIVATE:

    DEFINE INPUT PARAMETER dataset FOR dsEmployee.
    dtEmployee.NAME  = employee.firstname + " " + employee.lastname.    
    dtEmployee.email = LC(employee.firstname + "." + employee.lastname + "@pug.no").    
    
END PROCEDURE.

/* ***************************  Main Block  *************************** */
