
BLOCK-LEVEL ON ERROR UNDO, THROW.

DEF VAR hDataset AS HANDLE NO-UNDO. 

RUN web\api\tabledefinitions.p  ('customer',OUTPUT DATASET-HANDLE hDataset). 
hDataset:WRITE-JSON("file","c:\temp\tebledefinitions.json", TRUE).
