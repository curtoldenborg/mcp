 
/*------------------------------------------------------------------------
   File        : sqlexecstream
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : colde
   Created     : Mon Mar 17 16:33:04 CET 2025
   Notes       : 
 ----------------------------------------------------------------------*/

USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS web.api.sqlexecstream: 


    DEFINE STREAM instream.


    METHOD PUBLIC STATIC VOID execSing(INPUT SqlStatement AS CHAR, OUTPUT Result AS LONGCHAR,OUTPUT resultfile AS CHARACTER  ):

     
        DEFINE VARIABLE ConnectionParameter AS CHARACTER NO-UNDO INIT " -db sports2000 -H localhost -S 5151 -user sysprogress -password sysprogress". 
        DEFINE VARIABLE SQLExp              AS CHARACTER NO-UNDO INIT "C:\progress\OE128_64\bin\sqlexp.bat".
        DEFINE VARIABLE ipcCommand          AS CHARACTER NO-UNDO. 
        DEFINE VARIABLE aline               AS CHARACTER NO-UNDO. 
        DEFINE VARIABLE queryfile           AS CHARACTER NO-UNDO. 
        DEFINE VARIABLE uid                 AS CHARACTER NO-UNDO. 
        DEFINE VARIABLE cList               AS CHAR      NO-UNDO. 

        uid = REPLACE(GUID(GENERATE-UUID),'-','').
        queryFile   = SESSION:TEMP-DIR  + 'query_' + uid + '.sql'.
        resultFile  = SESSION:TEMP-DIR  + 'query_' + uid + '.res'.

        OUTPUT STREAM Instream TO VALUE(queryFile). 
        PUT stream instream UNFORMATTED SqlStatement skip.  
        OUTPUT STREAM Instream CLOSE.
        ipcCommand = SQLExp + ConnectionParameter + ' -infile ' + queryFile + ' -outfile ' + resultFile.


        INPUT-OUTPUT STREAM Instream THROUGH VALUE(ipcCommand) CONVERT TARGET SESSION:CHARSET SOURCE "UTF-8" NO-ECHO UNBUFFERED .
        REPEAT:                                 
            IMPORT STREAM instream UNFORMATTED aline .
            cList = clist + aline. 
        END.
      
        INPUT-OUTPUT STREAM Instream CLOSE.

        COPY-LOB FROM FILE resultFile TO Result.

    END METHOD.



    METHOD PUBLIC STATIC VOID readfile(INPUT filename AS CHARACTER  ):
    
    /*
        INPUT STREAM Instream THROUGH VALUE(ipcCommand) CONVERT TARGET SESSION:CHARSET SOURCE "UTF-8" NO-ECHO UNBUFFERED .
        REPEAT:                                 
            IMPORT STREAM instream UNFORMATTED aline .
            cList = clist + aline. 
        END.
    */
     
    
    END METHOD.



END CLASS.