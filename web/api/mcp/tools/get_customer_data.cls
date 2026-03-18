USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS web.api.mcp.tools.get_customer_data INHERITS web.api.mcp.tools.base.tool :

DEFINE TEMP-TABLE ttCustomer NO-UNDO
FIELD CustNum      AS INTEGER   LABEL "Cust #"
FIELD Name         AS CHARACTER LABEL "Name"
FIELD City         AS CHARACTER LABEL "City"
FIELD Country      AS CHARACTER LABEL "Country"
FIELD Phone        AS CHARACTER LABEL "Phone"
FIELD EmailAddress AS CHARACTER LABEL "Email"
FIELD Balance      AS DECIMAL   LABEL "Balance"
FIELD CreditLimit  AS DECIMAL   LABEL "Credit Limit"
FIELD SalesRep     AS CHARACTER LABEL "Sales Rep"
FIELD Discount     AS INTEGER   LABEL "Discount".

/*
    METHOD PUBLIC OVERRIDE LONGCHAR ToolDefinition():
        RETURN 
        '
      ~{
          "name": "get_customer_data",
          "description": "Retrieves customer data from the Sports2000 Customer table. Optional filters: customerName (partial match on Name) and country (exact match). Returns CustNum, Name, City, Country, Phone, EmailAddress, Balance, CreditLimit, SalesRep and Discount.",
          "inputSchema": ~{ 
          "type": "object", 
          "properties": ~{"customerName": ~{"type": "string", "description": "Partial name filter (leave empty for all)"},"country": ~{"type": "string", "description": "Country filter - exact match (leave empty for all)"},"maxRows": ~{"type": "number", "description": "Max number of rows to return, default 50"}
          ,~},
           "required": [] 
          ~}
        ~}        '.
    END.
  */  

    METHOD PUBLIC OVERRIDE JsonObject Execute(id AS integer, poArguments AS JsonObject):
        
        DEFINE VARIABLE cName    AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cCountry AS CHARACTER NO-UNDO.
        DEFINE VARIABLE iMax     AS INTEGER   NO-UNDO INITIAL 50.
        DEFINE VARIABLE iCount   AS INTEGER   NO-UNDO.
        DEFINE VARIABLE oData    AS Progress.Json.ObjectModel.JsonArray NO-UNDO.
        
        ASSIGN
            cName    = poArguments:GetCharacter("customerName")
            cCountry = poArguments:GetCharacter("country")
            NO-ERROR.
        
        IF poArguments:Has("maxRows") THEN
            iMax = poArguments:GetInteger("maxRows").
        
        FOR EACH Customer NO-LOCK BY Customer.CustNum:
            IF cName <> "" AND INDEX(Customer.Name, cName) = 0 THEN NEXT.
            IF cCountry <> "" AND Customer.Country <> cCountry THEN NEXT.
            iCount = iCount + 1.
            IF iCount > iMax THEN LEAVE.
            CREATE ttCustomer.
            ASSIGN
                ttCustomer.CustNum      = Customer.CustNum
                ttCustomer.Name         = Customer.Name
                ttCustomer.City         = Customer.City
                ttCustomer.Country      = Customer.Country
                ttCustomer.Phone        = Customer.Phone
                ttCustomer.EmailAddress = Customer.EmailAddress
                ttCustomer.Balance      = Customer.Balance
                ttCustomer.CreditLimit  = Customer.CreditLimit
                ttCustomer.SalesRep     = Customer.SalesRep
                ttCustomer.Discount     = Customer.Discount.
        END.
        
        oData = NEW Progress.Json.ObjectModel.JsonArray().
        TEMP-TABLE ttCustomer:WRITE-JSON("JsonArray", oData, TRUE).
        RETURN CreateMcpResponseJson(id, oData, false).


    END.

END CLASS.
