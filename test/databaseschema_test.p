
BLOCK-LEVEL ON ERROR UNDO, THROW.

DEF VAR hDataset AS HANDLE NO-UNDO. 

RUN web\api\databaseschema.p  (OUTPUT DATASET-HANDLE hDataset). 
hDataset:WRITE-JSON("file","c:\temp\databaseschema.json", TRUE).
