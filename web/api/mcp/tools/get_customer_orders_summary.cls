 

USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS web.api.mcp.tools.get_customer_orders_summary INHERITS web.api.mcp.tools.base.tool : 


    /* 1. Define the Temp-Table with the new OrderDate field */
    DEFINE TEMP-TABLE ttCustomerOrder NO-UNDO
        FIELD CustName   AS CHARACTER LABEL "Customer"
        FIELD OrderNum   AS INTEGER   LABEL "Order #"
        FIELD OrderDate  AS DATE      LABEL "Date"
        FIELD OrderTotal AS DECIMAL   LABEL "Total Value"
        FIELD LineCount  AS INTEGER   LABEL "Lines"
        INDEX idxDate IS PRIMARY OrderDate DESCENDING  /* Index for fast sorting by date */
        INDEX idxCust            CustName  OrderNum.

    METHOD PUBLIC OVERRIDE LONGCHAR ToolDefinition():
        RETURN  '
      ~{
          "name": "get_customer_orders_summary",
          "description": "Retrieves a summarized list of customer orders from the Sports2000 database, including line totals and order dates, within a specific date range.",
          "inputSchema": ~{
            "type": "object",
            "properties": ~{
              "startDate": ~{
                "type": "string",
                "format": "date",
                "description": "The beginning of the order date range (DDMMYY)."
              ~},
              "endDate": ~{
                "type": "string",
                "format": "date",
                "description": "The end of the order date range (DDMMYY)."
              ~},
              "minOrderValue": ~{
                "type": "number",
                "description": "Optional filter to only return orders with a TotalOrder greater than this value."
              ~}
            ~},
            "required": ["startDate", "endDate"]
          ~}
        ~}
        '.
    END.


    METHOD PUBLIC OVERRIDE Progress.Json.ObjectModel.JsonObject Execute(id AS integer,  poArguments AS Progress.Json.ObjectModel.JsonObject ):
        
        DEFINE VARIABLE jsonSales  AS LONGCHAR                            NO-UNDO. 
        DEFINE VARIABLE oData      AS Progress.Json.ObjectModel.JsonArray NO-UNDO.

        /* Variables for your filter */
        DEFINE VARIABLE dStartDate AS DATE                                INITIAL 01/01/1998 NO-UNDO.
        DEFINE VARIABLE dEndDate   AS DATE                                INITIAL 12/31/2029 NO-UNDO.

        ASSIGN 
            dStartDate = DATE(poArguments:GetCharacter("startdate"))
            dEndDate   = DATE(poArguments:GetCharacter("enddate"))
            NO-ERROR.
        
        LOG-MANAGER:WRITE-MESSAGE("Query:Startdate:" + quoter(dStartDate) + ":Enddate:" + quoter(dEndDate),"LOG").
        
        /* 2. Populate the Temp-Table with the Date Filter */
        FOR EACH Order WHERE Order.OrderDate >= dStartDate 
            AND Order.OrderDate <= dEndDate NO-LOCK,
            FIRST Customer OF Order NO-LOCK:
    
            /* Create a record in our temp-table */
            CREATE ttCustomerOrder.
            ASSIGN 
                ttCustomerOrder.CustName  = Customer.Name
                ttCustomerOrder.OrderNum  = Order.OrderNum
                ttCustomerOrder.OrderDate = Order.OrderDate.

            /* Calculate the totals from OrderLines */
            FOR EACH OrderLine OF Order NO-LOCK:
                ASSIGN 
                    ttCustomerOrder.OrderTotal = ttCustomerOrder.OrderTotal + OrderLine.ExtendedPrice
                    ttCustomerOrder.LineCount  = ttCustomerOrder.LineCount + 1.
            END.
        END.

        /* Write the temp-table directly into the JsonArray object */
        oData = NEW Progress.Json.ObjectModel.JsonArray().
        TEMP-TABLE ttCustomerOrder:WRITE-JSON("JsonArray", oData,true). 

        RETURN CreateMcpResponseJson(id,oData,false).
    END. 


END CLASS.


/*

/* 2. Populate and Filter */
FOR EACH Order WHERE Order.OrderDate >= dStartDate 
                 AND Order.OrderDate <= dEndDate NO-LOCK,
    FIRST Customer OF Order NO-LOCK:
    
    /* Variable to hold the running total for this specific order */
    DEFINE VARIABLE deCalcTotal AS DECIMAL NO-UNDO.
    DEFINE VARIABLE iCalcLines  AS INTEGER NO-UNDO.
    
    ASSIGN deCalcTotal = 0
           iCalcLines  = 0.

    /* Calculate the order total from the lines */
    FOR EACH OrderLine OF Order NO-LOCK:
        ASSIGN deCalcTotal = deCalcTotal + OrderLine.ExtendedPrice
               iCalcLines  = iCalcLines  + 1.
    END.

    /* 3. THE FILTER: Only create the tt record if it meets the minimum */
    IF deCalcTotal >= deMinOrderVal THEN DO:
        CREATE ttCustomerOrder.
        ASSIGN 
            ttCustomerOrder.CustName   = Customer.Name
            ttCustomerOrder.OrderNum   = Order.OrderNum
            ttCustomerOrder.OrderDate  = Order.OrderDate
            ttCustomerOrder.OrderTotal = deCalcTotal
            ttCustomerOrder.LineCount  = iCalcLines.
    END.
END.
*/