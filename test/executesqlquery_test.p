

BLOCK-LEVEL ON ERROR UNDO, THROW.



DEFINE VAR  SqlStatement AS CHAR NO-UNDO INIT "SELECT * from pub.customer;".


def var hDataset as handle. 
def var lBody as longchar. 
RUN web/api/executesqlquery.p (SqlStatement, OUTPUT DATASET-HANDLE hDataset).
hDataset:WRITE-JSON("longchar",lBody, TRUE).

DEF VAR cfile AS CHAR INIT "c:\temp\result.txt". 
COPY-LOB lBody TO FILE cFile. 
// MESSAGE STRING (lbody) VIEW-AS ALERT-BOX. 

/*
OUTPUT TO VALUE("GrantAll.sql").

FOR EACH _File WHERE _Tbl-Type = "T":
    PUT UNFORMATTED "GRANT ALL ON PUB." + QUOTER(_File-Name) + " TO PUBLIC;" SKIP.
  //  PUT UNFORMATTED "GO" SKIP.
END.

OUTPUT CLOSE.
*/
