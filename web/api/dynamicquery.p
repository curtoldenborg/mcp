
/*------------------------------------------------------------------------
    File        : dynamicquery.p
  ----------------------------------------------------------------------*/


BLOCK-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER cTablename AS CHAR NO-UNDO. 
DEFINE INPUT PARAMETER cWhereClause AS CHAR NO-UNDO. 
DEFINE OUTPUT PARAMETER opJsonResult AS LONGCHAR NO-UNDO. 

    if cWhereClause ne "" then cWhereClause = " WHERE " + cWhereClause. 
   
   /* Dynamiske håndtak */
    DEFINE VARIABLE hTable  AS HANDLE NO-UNDO.
    DEFINE VARIABLE hBuffer AS HANDLE NO-UNDO.
    DEFINE VARIABLE hQuery  AS HANDLE NO-UNDO.
    DEFINE VARIABLE hDBBuf  AS HANDLE NO-UNDO.
    
    /* 1. Opprett en dynamisk Temp-Table basert på DB-tabellens skjema */
    CREATE TEMP-TABLE hTable.
    CREATE BUFFER hDBBuf FOR TABLE cTablename.
    hTable:CREATE-LIKE(hDBBuf).
    hTable:TEMP-TABLE-PREPARE("Result").
    hBuffer = hTable:DEFAULT-BUFFER-HANDLE.
    
    /* 2. Fyll Temp-Tabellen fra databasen */
    CREATE QUERY hQuery.
    hQuery:SET-BUFFERS(hDBBuf).
    hQuery:QUERY-PREPARE("FOR EACH " + cTablename + " NO-LOCK " + cWhereClause).
    hQuery:QUERY-OPEN().
    
    /* Bruk hBuffer:COPY-DATA for lynrask kopiering av hele rader */
    hQuery:GET-FIRST().
    DO WHILE NOT hQuery:QUERY-OFF-END:
        hBuffer:BUFFER-CREATE().
        hBuffer:BUFFER-COPY(hDBBuf).
        hQuery:GET-NEXT().
    END.
    
    /* 3. Serialiser hele tabellen til JSON med ett kall */
    /* Parametere: Target (Longchar), Formatted, Encoding, OmmitInitialValues, HideTableHandle */
    hTable:WRITE-JSON("LONGCHAR", opJsonResult, TRUE).
    
    /* Opprydding */
    hQuery:QUERY-CLOSE().
    DELETE OBJECT hQuery.
    DELETE OBJECT hTable.
    DELETE OBJECT hDBBuf.    
        
        
        