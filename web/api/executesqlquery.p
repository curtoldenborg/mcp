

BLOCK-LEVEL ON ERROR UNDO, THROW.


DEFINE TEMP-TABLE dtQueryResult SERIALIZE-NAME "query_result"
    FIELD line AS character SERIALIZE-NAME "resultline".         

DEFINE DATASET dsQueryResult FOR dtQueryResult.

DEFINE INPUT PARAMETER cQuery AS CHARACTER NO-UNDO. 
DEFINE OUTPUT PARAMETER DATASET FOR dsQueryResult.

DEFINE VARIABLE lcResult       AS LONGCHAR NO-UNDO. 
DEFINE VARIABLE ResultFilename AS CHARACTER     NO-UNDO. 

DATASET dsQueryResult:SERIALIZE-HIDDEN = true. 

RUN web/api/sqlexp.p (cQuery, output lcResult,output ResultFilename).

DEFINE STREAM instream.

INPUT STREAM Instream FROM VALUE(ResultFilename) CONVERT TARGET SESSION:CHARSET SOURCE "UTF-8" NO-ECHO UNBUFFERED .
REPEAT:                       
    create dtQueryResult.
    IMPORT STREAM instream UNFORMATTED dtQueryResult.line .
END.
INPUT STREAM Instream CLOSE.



