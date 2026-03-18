 

USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS web.api.mcp.tools.sales_pr_month INHERITS web.api.mcp.tools.base.tool : 


    /* Define a temp-table to hold the monthly results */
    DEFINE TEMP-TABLE ttMonthlySales NO-UNDO SERIALIZE-NAME "MonthlySales"
        FIELD SalesYear  AS INTEGER
        FIELD SalesMonth AS INTEGER
        FIELD TotalSales AS DECIMAL.


    METHOD PUBLIC OVERRIDE LONGCHAR ToolDefinition():
        RETURN  '
      ~{
        "name": "sales_pr_month",
        "description": "Returns json list of sales pr month",
        "inputSchema": ~{
          "type": "object",
          "properties": ~{~},
          "required": []
         ~}
       ~}'.
    END.


    METHOD PUBLIC OVERRIDE Progress.Json.ObjectModel.JsonObject Execute(id AS integer,  poArguments AS Progress.Json.ObjectModel.JsonObject ):
        
        DEFINE VARIABLE jsonSales AS LONGCHAR                            NO-UNDO. 
        DEFINE VARIABLE oData     AS Progress.Json.ObjectModel.JsonArray NO-UNDO.
        
        FOR EACH Order NO-LOCK:
            FIND ttMonthlySales WHERE ttMonthlySales.SalesYear  = YEAR(Order.OrderDate)
                AND ttMonthlySales.SalesMonth = MONTH(Order.OrderDate) 
                NO-ERROR.
    
            IF NOT AVAILABLE ttMonthlySales THEN 
            DO:
                CREATE ttMonthlySales.
                ASSIGN 
                    ttMonthlySales.SalesYear  = YEAR(Order.OrderDate)
                    ttMonthlySales.SalesMonth = MONTH(Order.OrderDate).
            END.
            /* Sum the Order total */
            FOR EACH OrderLine OF Order NO-LOCK:
                ttMonthlySales.TotalSales = ttMonthlySales.TotalSales + OrderLine.ExtendedPrice.
            END.
        END.

        /* Write the temp-table directly into the JsonArray object */
        oData = NEW Progress.Json.ObjectModel.JsonArray().
        TEMP-TABLE ttMonthlySales:WRITE-JSON("JsonArray", oData,true). 

        RETURN CreateMcpResponseJson(id,oData,false).
    END. 


END CLASS.