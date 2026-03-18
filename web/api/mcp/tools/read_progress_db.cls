 

USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS web.api.mcp.tools.read_progress_db INHERITS web.api.mcp.tools.base.tool :  
   
   /*
   METHOD PUBLIC OVERRIDE LONGCHAR ToolDefinition():
        RETURN  '
           ~{
        "name": "read_progress_db",
        "description": "Queries the OpenEdge database using a standard ABL WHERE clause.",
        "inputSchema": ~{
          "type": "object",
          "properties": ~{
            "tableName": ~{ "type": "string", "description": "The table name (e.g., Customer)" ~},
            "whereClause": ~{ "type": "string", "description": "The ABL filter (e.g., CustNum < 50)" ~}
          ~},
          "required": ["tableName", "whereClause"]
        ~}
      ~}'.
    END.
    */
    METHOD PUBLIC OVERRIDE Progress.Json.ObjectModel.JsonObject Execute(id AS integer,  poArguments AS Progress.Json.ObjectModel.JsonObject ):
       
        DEFINE VARIABLE cTableName   AS CHAR NO-UNDO. 
        DEFINE VARIABLE cWhereClause AS CHAR NO-UNDO. 
        DEFINE VARIABLE opJsonResult AS LONGCHAR  NO-UNDO.
        DEFINE VARIABLE oJson AS Progress.Json.ObjectModel.JsonObject NO-UNDO. 
       
        ASSIGN 
            cTablename   = poArguments:GetCharacter("tableName")
            cWhereClause = poArguments:GetCharacter("whereClause").
        
        LOG-MANAGER:WRITE-MESSAGE("Query:" + quoter(cTablename) + " WHERE " + quoter(cWhereClause),"LOG" ).    
        
        IF TRIM(cWhereClause) NE "" THEN cWhereClause = " WHERE " + cWhereClause . 
        
        opJsonResult = dynamicQuery(cTableName,cWhereClause).
        oJson = CreateMcpResponseText(id,opJsonResult,true).
        
        RETURN oJson.
        
        CATCH e AS Progress.Lang.Error:
            /* Handle class not found or execution errors */
            RETURN CreateMcpResponseText(id,'error..',false).
        END CATCH. 
        
    END. 
    

    METHOD PUBLIC LONGCHAR DynamicQuery(cTableName AS CHAR, cWhereClause AS CHAR):
       
        DEFINE VARIABLE opJsonResult AS LONGCHAR NO-UNDO. 
 
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

        RETURN opJsonResult. 
     END.         

END CLASS.