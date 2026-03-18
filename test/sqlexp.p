

BLOCK-LEVEL ON ERROR UNDO, THROW.


DEFINE INPUT PARAMETER  SqlStatement AS CHARACTER NO-UNDO. // INIT "SELECT * from pub.customer;".
DEFINE OUTPUT PARAMETER Result AS LONGCHAR NO-UNDO.
DEFINE OUTPUT PARAMETER resultfile AS CHARACTER NO-UNDO.


DEFINE VARIABLE ConnectionParameter AS CHARACTER NO-UNDO INIT " -db sports2000 -H localhost -S 5151 ". 
DEFINE VARIABLE SQLExp              AS CHARACTER NO-UNDO INIT "C:\progress\OE128_64\bin\sqlexp.bat".
DEFINE VARIABLE ipcCommand AS CHARACTER NO-UNDO. 
DEFINE VARIABLE aline AS CHARACTER NO-UNDO. 
DEFINE VARIABLE queryfile AS CHARACTER NO-UNDO. 
DEFINE VARIABLE uid AS CHARACTER NO-UNDO. 

DEFINE STREAM instream.

uid = REPLACE(GUID(GENERATE-UUID),'-','').

queryFile   = SESSION:TEMP-DIR  + 'query_' + uid + '.sql'.
resultFile  = SESSION:TEMP-DIR  + 'query_' + uid + '.res'.


OUTPUT STREAM Instream TO VALUE(queryFile). 
   PUT UNFORMATTED SqlStatement .  
OUTPUT STREAM Instream CLOSE.

ipcCommand = SQLExp + ConnectionParameter + ' -infile ' + queryFile + ' -outfile ' + resultFile.

INPUT-OUTPUT STREAM Instream THROUGH VALUE(ipcCommand) CONVERT TARGET SESSION:CHARSET SOURCE "UTF-8" NO-ECHO UNBUFFERED .
REPEAT:                                 
     IMPORT STREAM instream UNFORMATTED aline .
END.
INPUT STREAM Instream CLOSE.

COPY-LOB FROM FILE resultFile TO Result.


