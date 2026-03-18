 

USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.


CLASS web.api.mcp.tools.get_current_time INHERITS web.api.mcp.tools.base.tool :  


   METHOD PUBLIC OVERRIDE LONGCHAR ToolDefinition():
        RETURN  '
      ~{
          "name": "get_current_time",
          "description": "Returns the current date and time, optionally in spesified timezone.",
          "inputSchema": ~{
            "type": "object",
            "properties": ~{
              "timezone": ~{
                "type": "string",
                "description": "IANA timezone string,e.g. Europe/Oslo or UTC. Defaults to UTC if not provided."
              ~}
            ~},
            "required": []
          ~}
        ~}'.
      
      
    END.
    
    METHOD PUBLIC OVERRIDE Progress.Json.ObjectModel.JsonObject Execute(id AS integer,  poArguments AS Progress.Json.ObjectModel.JsonObject ):
        
        /* Definer variabler */
        DEFINE VARIABLE oRoot    AS JsonObject NO-UNDO.
        DEFINE VARIABLE oTime    AS JsonObject NO-UNDO.
        DEFINE VARIABLE lcJson   AS LONGCHAR   NO-UNDO.
        DEFINE VARIABLE iUnix    AS INTEGER    NO-UNDO.
        DEFINE VARIABLE dtNow    AS DATETIME-TZ NO-UNDO.
        
        /* Sett nåværende tidspunkt */
        dtNow = NOW.
        
        /* Beregn Unix Timestamp (sekunder siden 01/01/1970) */
        iUnix = INTERVAL(dtNow, DATETIME-TZ(1,1,1970,0,0,0,0), "seconds").
        
        /* Opprett JSON-objekter */
        oRoot = NEW JsonObject().
        oTime = NEW JsonObject().
        
        /* Legg til verdier i "current_time" objektet */
        oTime:Add("iso8601",      REPLACE(ISO-DATE(dtNow), "+01:00", "Z")). /* Forenklet UTC eks */
        oTime:Add("timezone",     "Europe/Oslo").
        oTime:Add("local",        ISO-DATE(dtNow)).
        oTime:Add("date",         STRING(YEAR(dtNow), "9999") + "-" + STRING(MONTH(dtNow), "99") + "-" + STRING(DAY(dtNow), "99")).
        oTime:Add("time",         STRING(TIME, "HH:MM:SS")).
        oTime:Add("weekday",      ENTRY(WEEKDAY(dtNow), "Sunday,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday")).
        oTime:Add("unix_timestamp", iUnix).
        
        /* Legg objektet inn i rot-objektet */
        oRoot:Add("current_time", oTime).
        
        /* Skriv ut til LONGCHAR */
        oRoot:Write(lcJson, TRUE).
        
        
        RETURN CreateMcpResponseText(id,STRING(lcJson),false).
    END. 

END CLASS.