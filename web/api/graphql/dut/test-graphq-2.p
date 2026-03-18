


DEFINE TEMP-TABLE dtdatabasesschema SERIALIZE-NAME "tableinformation"
    FIELD tablenumber AS INTEGER   SERIALIZE-NAME "tablenumber"          
    FIELD tablename   AS CHARACTER SERIALIZE-NAME "tablename" .         

DEFINE TEMP-TABLE dtfield SERIALIZE-NAME "fields"
    FIELD tablenumber AS INTEGER   SERIALIZE-HIDDEN          
    FIELD fieldname   AS CHARACTER SERIALIZE-NAME "fieldname"          
    FIELD datatype    AS CHARACTER SERIALIZE-NAME "datatype" 
    FIELD primaryindex AS LOGICAL .         

DEFINE DATASET dsdatabasesschema FOR dtdatabasesschema, dtfield
    DATA-RELATION relation1 FOR dtdatabasesschema, dtfield
    RELATION-FIELDS (tablenumber, tablenumber) NESTED.

    
// DEFINE INPUT PARAMETER cTableName AS CHAR NO-UNDO. 
// DEFINE OUTPUT PARAMETER DATASET FOR dsdatabasesschema.
 DEFINE VARIABLE cTableName AS CHAR INIT "customer" NO-UNDO. 
 //DEFINE VARIABLE hDATASET FOR dsdatabasesschema.

 

DATASET dsdatabasesschema:SERIALIZE-HIDDEN = TRUE. 

FOR EACH _file WHERE NOT _hidden AND _file._file-name = cTableName , EACH _field OF _file BREAK BY (_file._file-name): 
    IF FIRST-OF (_file._file-name) THEN 
    DO:
        CREATE dtdatabasesschema. 
        dtdatabasesschema.tablename = _file._file-name. 
        dtdatabasesschema.tablenumber = _file._file-number. 
        
    END. 
 
 
    FIND FIRST _index OF _file  WHERE _File._File-num > 0  AND  _File._File-name = cTableName AND _index._Unique NO-LOCK. 
   
   EACH _Index       WHERE _Unique,
    EACH _File        OF _Index WHERE _File._File-num > 0,
    EACH _Index-field OF _Index,
    EACH _Field       OF _Index-field NO-LOCK:

    IF _Index-seq = 1 THEN
    
    CREATE dtfield. 
    dtfield.fieldname = _field._field-name. 
    dtfield.datatype  = _field._data-type.  
    dtfield.tablenumber = _file._file-number. 
    dtfield.PRIMARYindex = IF AVAIL _index THEN TRUE ELSE FALSE. 
END. 

DEF VAR lSchema AS LONGCHAR NO-UNDO. 
DEF VAR cDataType AS CHAR NO-UNDO. 
FOR EACH dtdatabasesschema, EACH  dtfield WHERE  dtfield.tablenumber = dtdatabasesschema.tablenumber BREAK BY (dtdatabasesschema.tablenumber) BY primaryindex:  
    IF FIRST-OF (dtdatabasesschema.tablenumber) THEN 
       lSchema = lSchema + '~n type ' + dtdatabasesschema.tablename + ' ~{~n' .  
    
    IF dtfield.datatype = "character" THEN cDatatype = "String". 
    ELSE IF dtfield.datatype = "integer"   THEN cDatatype = "Int".
    ELSE IF dtfield.datatype = "Logical"   THEN cDatatype = "Boolean".
    ELSE IF dtfield.datatype = "Decimal"   THEN cDatatype = "Float".
    ELSE cDatatype = dtfield.datatype.
     
    lSchema = lschema + FILL(' ',4) + dtfield.fieldname + ': ' + cdatatype  + '!~n'  .
       
END.
lSchema = lschema + '~}~n'.

MESSAGE string(lschema) VIEW-AS ALERT-BOX. 

/*
     String: a string of text
Int: a signed 32-bit integer
Float: a double-precision floating-point number
Boolean: a true/false value
ID: a unique identifier used for refetching an object

type User {
  id: ID!
  name: String!
  email: String!
}
 */
              /*
    find _file no-lock where _file._file-name = "customer" no-error.
if available( _file ) then
  do:

    find _field no-lock where _file-recid = recid ( _file ) and _field-name = "custnum" no-error.

    if available( _field ) then
      do:

        message "common field exists!".

        find first _index-field no-lock where _field-recid = recid( _field ) no-error.
        if available( _index-field ) then
          do:

            message "and there is at least one index on tableNameId!".

            find _index no-lock where recid( _index ) = _index-recid no-error.

            message _index-name _unique _num-comp.  /* you probably want a unique single component index */

          end.

      end.

  end.
            */
//_treldat.p
 
      /*********************************************************************
* Copyright (C) 2000 by Progress Software Corporation. All rights    *
* reserved. Prior versions of this work may contain portions         *
* contributed by participants of Possenet.                           *
*                                                                    *
*********************************************************************/
       /*
/*----------------------------------------------------------------------------

File: _treldat.p

Description:
   Display table relations to the currently set output device (e.g., a file, 
   the printer).
 
Input Parameters:
   p_DbId    - Id of the _Db record for this database.
   p_Tbl     - The table to show relations for or "ALL"

Author: Tony Lavinio, Laura Stern

Date Created: 10/12/92

Modified on 05/31/95 gfs Allow display of hidden tables (not meta-schema).
            06/14/94 gfs Added NO-LOCKs to file accesses.
            07/10/98 DLM Added DBVERSION and _Owner check
----------------------------------------------------------------------------*/
{ prodict/fhidden.i }

DEFINE INPUT PARAMETER p_DbId  AS RECID NO-UNDO.
DEFINE INPUT PARAMETER p_Tbl   AS CHAR  NO-UNDO.

DEFINE SHARED STREAM rpt.

DEFINE WORKFILE g_relate NO-UNDO
  FIELD g_owner  LIKE _File._File-name
  FIELD g_member LIKE _File._File-name
  FIELD g_idx    LIKE _Index._Index-name.

DEFINE BUFFER g_mfile  FOR _File.
DEFINE BUFFER g_xfield FOR _Field.
DEFINE BUFFER g_xfile  FOR _File.

DEFINE VARIABLE noway    AS LOGICAL NO-UNDO.
DEFINE VARIABLE line     AS CHAR    NO-UNDO.  

FORM
  line FORMAT "x(77)" NO-LABEL
  WITH FRAME rptline DOWN NO-BOX USE-TEXT STREAM-IO.

FORM 
  SKIP(1)
  SPACE(3) g_mfile._File-name LABEL "Working on" FORMAT "x(32)" SPACE
  SKIP(1)
  WITH FRAME working_on SIDE-LABELS VIEW-AS DIALOG-BOX 
  TITLE "Generating Report".

/*-----------------------------Mainline code---------------------------*/

FIND _DB WHERE RECID(_Db) = p_DbId NO-LOCK.
IF INTEGER(DBVERSION("DICTDB")) > 8 THEN DO:
  FIND _File WHERE  _File._File-name = "_File" 
               AND _File._Owner = "PUB" NO-LOCK.
  noway = CAN-DO(_Can-read,USERID("DICTDB")).
  FIND _File WHERE _File._File-name = "_Field" 
               AND _File._Owner = "PUB" NO-LOCK.
  noway = noway AND CAN-DO(_Can-read,USERID("DICTDB")).
  FIND _File WHERE  _File._File-name = "_Index" 
               AND _File._Owner = "PUB" NO-LOCK.
  noway = noway AND CAN-DO(_Can-read,USERID("DICTDB")).
  FIND _File WHERE _File._File-name = "_Index-field" 
               AND _File._Owner = "PUB" NO-LOCK.
  noway = noway AND CAN-DO(_Can-read,USERID("DICTDB")).
END.  
ELSE DO:
  FIND _File "_File" NO-LOCK.
  noway = CAN-DO(_Can-read,USERID("DICTDB")).
  FIND _File "_Index" NO-LOCK.
  noway = noway AND CAN-DO(_Can-read,USERID("DICTDB")).
  FIND _File "_Field" NO-LOCK.
  noway = noway AND CAN-DO(_Can-read,USERID("DICTDB")).
END.  

IF NOT noway THEN DO:
  MESSAGE "You do not have permission to use this option"
      VIEW-AS ALERT-BOX ERROR BUTTONS OK.
  RETURN.
END.

IF p_Tbl = "ALL" THEN
  SESSION:IMMEDIATE-DISPLAY = yes.

FOR EACH g_mfile NO-LOCK
  WHERE g_mfile._Db-recid = p_DbId
  AND (IF p_Tbl = "ALL" THEN (IF NOT fHidden THEN NOT _Hidden ELSE g_mfile._File-Number > 0)
                        ELSE g_mfile._File-name = p_Tbl):
  IF INTEGER(DBVERSION("DICTDB")) > 8 AND
    (g_mfile._Owner <> "PUB" AND g_mfile._Owner <> "_FOREIGN") THEN NEXT.
    
  IF p_Tbl = "ALL" THEN
    DISPLAY g_mfile._File-name WITH FRAME working_on.

  /* Clear work file */
  FOR EACH g_relate NO-LOCK: DELETE g_relate.  END.

  FOR
    EACH _Index       WHERE _Unique,
    EACH _File        OF _Index WHERE _File._File-num > 0,
    EACH _Index-field OF _Index,
    EACH _Field       OF _Index-field NO-LOCK:

    IF _Index-seq = 1 THEN
      FOR EACH g_xfield WHERE g_xfield._Field-name = _Field._Field-name
        AND RECID(g_xfield) <> RECID(_Field),
        EACH g_xfile OF g_xfield NO-LOCK:
        IF g_mfile._File-name <> _File._File-name
          AND g_mfile._File-name <> g_xfile._File-name THEN NEXT.
        CREATE g_relate.
        ASSIGN
          g_relate.g_owner  = _File._File-name
          g_relate.g_member = g_xfile._File-name
          g_relate.g_idx    = _Index._Index-name.
      END.
    ELSE
      FOR EACH g_relate
        WHERE g_idx = _Index._Index-name AND g_owner = _File._File-name,
        EACH g_xfile WHERE g_xfile._File-name = g_member NO-LOCK:
        IF NOT CAN-FIND(g_xfield OF g_xfile
          WHERE g_xfield._Field-name = _Field._Field-name) 
          AND available g_relate
          THEN DELETE g_relate.
      END.
  END.

  FOR EACH g_relate NO-LOCK BREAK BY g_owner BY g_member:
    IF NOT (FIRST-OF(g_member) AND LAST-OF(g_member)) THEN DELETE g_relate.
  END.

  DISPLAY STREAM rpt g_mfile._File-nam + ":" @ line WITH FRAME rptline.
  DOWN STREAM rpt WITH FRAME rptline.
  line= ?.

  FOR EACH g_relate NO-LOCK WHERE g_owner = g_mfile._File-name BY g_owner:
    line = "  " + g_member + " OF " + g_owner + " ".
    FIND g_xfile NO-LOCK WHERE g_xfile._db-recid = p_DbId
                           AND g_xfile._File-name = g_owner
                           AND (g_xfile._Owner = "PUB" OR g_xfile._Owner = "_FOREIGN").
    FIND _Index OF g_xfile NO-LOCK WHERE _Index-name = g_idx.
    FOR EACH _Index-field OF _Index,EACH _Field OF _Index-field NO-LOCK:
      line = line + STRING(_Index-seq > 1,",/(") + _Field-name.
    END.
    line = line + ")".
    DISPLAY STREAM rpt line WITH FRAME rptline.
    DOWN STREAM rpt WITH FRAME rptline.
  END.

  FOR EACH g_relate NO-LOCK 
        WHERE g_member = g_mfile._File-name BY g_member:
    line = "  " + g_member + " OF " + g_owner + " ".
    FIND g_xfile NO-LOCK WHERE g_xfile._db-recid = p_DbId
                           AND g_xfile._File-name = g_owner
                           AND (g_xfile._Owner = "PUB" OR g_xfile._Owner = "_FOREIGN").
    FIND _Index OF g_xfile NO-LOCK WHERE _Index-name = g_idx.
    FOR EACH _Index-field OF _Index,EACH _Field OF _Index-field NO-LOCK:
      line = line + STRING(_Index-seq > 1,",/(") + _Field-name.
    END.
    line = line + ")".
    DISPLAY STREAM rpt line WITH FRAME rptline.
    DOWN STREAM rpt WITH FRAME rptline.
  END.

  IF line = ? THEN DO:
    DISPLAY STREAM rpt "   No relations found for this file." 
      @ line WITH FRAME rptline.
    DOWN STREAM rpt 2 WITH FRAME rptline.
  END.
  ELSE
    DOWN STREAM rpt 1 WITH FRAME rptline.
END.

IF p_Tbl = "ALL" THEN DO:
  HIDE FRAME working_on NO-PAUSE. 
  SESSION:IMMEDIATE-DISPLAY = no.
END.
     */
/* _treldat.p - end of file */




 
