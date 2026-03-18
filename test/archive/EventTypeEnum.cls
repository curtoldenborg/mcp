
/*------------------------------------------------------------------------
    File        : web.EventTypeEnum
    Purpose     : Event TYPE Constants (CHARACTER) 
   
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Progress.Lang.*.

CLASS web.EventTypeEnum: 

    DEFINE PUBLIC STATIC PROPERTY AfterFill         AS CHARACTER NO-UNDO INIT "AFTER-FILL":U        GET . 
    DEFINE PUBLIC STATIC PROPERTY BeforeFill        AS CHARACTER NO-UNDO INIT "BEFORE-FILL":U       GET .  
    DEFINE PUBLIC STATIC PROPERTY BeforeRowFill     AS CHARACTER NO-UNDO INIT "BEFORE-ROW-FILL":U   GET . 
    DEFINE PUBLIC STATIC PROPERTY AfterRowFill      AS CHARACTER NO-UNDO INIT "AFTER-ROW-FILL":U    GET . 
    DEFINE PUBLIC STATIC PROPERTY RowDelete         AS CHARACTER NO-UNDO INIT "ROW-DELETE":U        GET . 
    DEFINE PUBLIC STATIC PROPERTY RowUpdate         AS CHARACTER NO-UNDO INIT "ROW-UPDATE":U        GET .  
    DEFINE PUBLIC STATIC PROPERTY FindFailed        AS CHARACTER NO-UNDO INIT "FIND-FAILED":U       GET .  
    DEFINE PUBLIC STATIC PROPERTY Synchronize       AS CHARACTER NO-UNDO INIT "SYNCHRONIZE":U       GET .  
   
    /*------------------------------------------------------------------------------
        Purpose: Disallow instance creation                                                                       
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PRIVATE EventTypeEnum ():
        SUPER ().
        
    END CONSTRUCTOR.

END CLASS.