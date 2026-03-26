USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS web.api.mcp.tools.automagic.customer_crud INHERITS web.api.mcp.tools.base.tool :

    METHOD PUBLIC OVERRIDE JsonObject Execute(id AS integer, poArguments AS JsonObject):

DEFINE VARIABLE cAction      AS CHARACTER NO-UNDO.
DEFINE VARIABLE iCustNum     AS INTEGER   NO-UNDO.
DEFINE VARIABLE cName        AS CHARACTER NO-UNDO.
DEFINE VARIABLE cAddress     AS CHARACTER NO-UNDO.
DEFINE VARIABLE cAddress2    AS CHARACTER NO-UNDO.
DEFINE VARIABLE cCity        AS CHARACTER NO-UNDO.
DEFINE VARIABLE cState       AS CHARACTER NO-UNDO.
DEFINE VARIABLE cPostal      AS CHARACTER NO-UNDO.
DEFINE VARIABLE cCountry     AS CHARACTER NO-UNDO.
DEFINE VARIABLE cPhone       AS CHARACTER NO-UNDO.
DEFINE VARIABLE cFax         AS CHARACTER NO-UNDO.
DEFINE VARIABLE cEmail       AS CHARACTER NO-UNDO.
DEFINE VARIABLE cContact     AS CHARACTER NO-UNDO.
DEFINE VARIABLE cSalesRep    AS CHARACTER NO-UNDO.
DEFINE VARIABLE cTerms       AS CHARACTER NO-UNDO.
DEFINE VARIABLE cComments    AS CHARACTER NO-UNDO.
DEFINE VARIABLE dCreditLim   AS DECIMAL   NO-UNDO.
DEFINE VARIABLE iDiscount    AS INTEGER   NO-UNDO.
DEFINE VARIABLE lHasCredit   AS LOGICAL   NO-UNDO.
DEFINE VARIABLE lHasDiscount AS LOGICAL   NO-UNDO.
DEFINE VARIABLE iMax         AS INTEGER   NO-UNDO INITIAL 100.
DEFINE VARIABLE iCount       AS INTEGER   NO-UNDO.
DEFINE VARIABLE iNewNum      AS INTEGER   NO-UNDO INITIAL 1.
DEFINE VARIABLE cDelName     AS CHARACTER NO-UNDO.
DEFINE VARIABLE oResult      AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
DEFINE VARIABLE oArray       AS Progress.Json.ObjectModel.JsonArray  NO-UNDO.
DEFINE VARIABLE oRow         AS Progress.Json.ObjectModel.JsonObject NO-UNDO.

ASSIGN cAction = poArguments:GetCharacter("action") NO-ERROR.

IF cAction = ? OR cAction = "" THEN DO:
    oResult = NEW Progress.Json.ObjectModel.JsonObject().
    oResult:Add("success", FALSE).
    oResult:Add("error", "action required: list|get|create|update|delete").
    RETURN CreateMcpResponseJson(id, oResult, false).
END.

IF poArguments:Has("custNum")      THEN iCustNum   = INTEGER(poArguments:GetDecimal("custNum")).
IF poArguments:Has("name")         THEN cName      = poArguments:GetCharacter("name").
IF poArguments:Has("address")      THEN cAddress   = poArguments:GetCharacter("address").
IF poArguments:Has("address2")     THEN cAddress2  = poArguments:GetCharacter("address2").
IF poArguments:Has("city")         THEN cCity      = poArguments:GetCharacter("city").
IF poArguments:Has("state")        THEN cState     = poArguments:GetCharacter("state").
IF poArguments:Has("postalCode")   THEN cPostal    = poArguments:GetCharacter("postalCode").
IF poArguments:Has("country")      THEN cCountry   = poArguments:GetCharacter("country").
IF poArguments:Has("phone")        THEN cPhone     = poArguments:GetCharacter("phone").
IF poArguments:Has("fax")          THEN cFax       = poArguments:GetCharacter("fax").
IF poArguments:Has("emailAddress") THEN cEmail     = poArguments:GetCharacter("emailAddress").
IF poArguments:Has("contact")      THEN cContact   = poArguments:GetCharacter("contact").
IF poArguments:Has("salesRep")     THEN cSalesRep  = poArguments:GetCharacter("salesRep").
IF poArguments:Has("terms")        THEN cTerms     = poArguments:GetCharacter("terms").
IF poArguments:Has("comments")     THEN cComments  = poArguments:GetCharacter("comments").
IF poArguments:Has("maxRows")      THEN iMax       = INTEGER(poArguments:GetDecimal("maxRows")).

lHasCredit   = poArguments:Has("creditLimit").
lHasDiscount = poArguments:Has("discount").
IF lHasCredit   THEN dCreditLim = poArguments:GetDecimal("creditLimit").
IF lHasDiscount THEN iDiscount  = INTEGER(poArguments:GetDecimal("discount")).

/* ---- LIST ---- */
IF cAction = "list" THEN DO:
    oArray = NEW Progress.Json.ObjectModel.JsonArray().
    iCount = 0.
    FOR EACH Customer NO-LOCK BY Customer.CustNum:
        IF cName     <> "" AND cName     <> ? AND INDEX(Customer.Name, cName) = 0 THEN NEXT.
        IF cCountry  <> "" AND cCountry  <> ? AND Customer.Country  <> cCountry   THEN NEXT.
        IF cSalesRep <> "" AND cSalesRep <> ? AND Customer.SalesRep <> cSalesRep  THEN NEXT.
        iCount = iCount + 1.
        IF iCount > iMax THEN LEAVE.
        oRow = NEW Progress.Json.ObjectModel.JsonObject().
        oRow:Add("CustNum",      Customer.CustNum).
        oRow:Add("Name",         Customer.Name).
        oRow:Add("City",         Customer.City).
        oRow:Add("Country",      Customer.Country).
        oRow:Add("Phone",        Customer.Phone).
        oRow:Add("EmailAddress", Customer.EmailAddress).
        oRow:Add("Contact",      Customer.Contact).
        oRow:Add("SalesRep",     Customer.SalesRep).
        oRow:Add("CreditLimit",  Customer.CreditLimit).
        oRow:Add("Balance",      Customer.Balance).
        oRow:Add("Discount",     Customer.Discount).
        oArray:Add(oRow).
    END.
    oResult = NEW Progress.Json.ObjectModel.JsonObject().
    oResult:Add("success",   TRUE).
    oResult:Add("count",     iCount).
    oResult:Add("customers", oArray).
    RETURN CreateMcpResponseJson(id, oResult, false).
END.

/* ---- GET ---- */
IF cAction = "get" THEN DO:
    oResult = NEW Progress.Json.ObjectModel.JsonObject().
    IF iCustNum = 0 OR iCustNum = ? THEN DO:
        oResult:Add("success", FALSE).
        oResult:Add("error", "custNum required for get").
        RETURN CreateMcpResponseJson(id, oResult, false).
    END.
    FIND Customer WHERE Customer.CustNum = iCustNum NO-LOCK NO-ERROR.
    IF AVAILABLE Customer THEN DO:
        oResult:Add("success",      TRUE).
        oResult:Add("CustNum",      Customer.CustNum).
        oResult:Add("Name",         Customer.Name).
        oResult:Add("Address",      Customer.Address).
        oResult:Add("Address2",     Customer.Address2).
        oResult:Add("City",         Customer.City).
        oResult:Add("State",        Customer.State).
        oResult:Add("PostalCode",   Customer.PostalCode).
        oResult:Add("Country",      Customer.Country).
        oResult:Add("Phone",        Customer.Phone).
        oResult:Add("Fax",          Customer.Fax).
        oResult:Add("EmailAddress", Customer.EmailAddress).
        oResult:Add("Contact",      Customer.Contact).
        oResult:Add("SalesRep",     Customer.SalesRep).
        oResult:Add("CreditLimit",  Customer.CreditLimit).
        oResult:Add("Balance",      Customer.Balance).
        oResult:Add("Discount",     Customer.Discount).
        oResult:Add("Terms",        Customer.Terms).
        oResult:Add("Comments",     Customer.Comments).
    END.
    ELSE DO:
        oResult:Add("success", FALSE).
        oResult:Add("error", "Customer " + STRING(iCustNum) + " not found").
    END.
    RETURN CreateMcpResponseJson(id, oResult, false).
END.

/* ---- CREATE ---- */
IF cAction = "create" THEN DO:
    oResult = NEW Progress.Json.ObjectModel.JsonObject().
    IF cName = "" OR cName = ? THEN DO:
        oResult:Add("success", FALSE).
        oResult:Add("error", "name required for create").
        RETURN CreateMcpResponseJson(id, oResult, false).
    END.
    FOR EACH Customer NO-LOCK BY Customer.CustNum DESCENDING:
        iNewNum = Customer.CustNum + 5.
        LEAVE.
    END.
    CREATE Customer.
    ASSIGN
        Customer.CustNum = iNewNum
        Customer.Name    = cName
        Customer.Balance = 0.
    IF cAddress  <> ? THEN Customer.Address      = cAddress.
    IF cAddress2 <> ? THEN Customer.Address2     = cAddress2.
    IF cCity     <> ? THEN Customer.City         = cCity.
    IF cState    <> ? THEN Customer.State        = cState.
    IF cPostal   <> ? THEN Customer.PostalCode   = cPostal.
    IF cCountry  <> ? THEN Customer.Country      = cCountry.
    IF cPhone    <> ? THEN Customer.Phone        = cPhone.
    IF cFax      <> ? THEN Customer.Fax          = cFax.
    IF cEmail    <> ? THEN Customer.EmailAddress = cEmail.
    IF cContact  <> ? THEN Customer.Contact      = cContact.
    IF cSalesRep <> ? THEN Customer.SalesRep     = cSalesRep.
    IF cTerms    <> ? THEN Customer.Terms        = cTerms.
    IF cComments <> ? THEN Customer.Comments     = cComments.
    IF lHasCredit   THEN Customer.CreditLimit = dCreditLim.
    IF lHasDiscount THEN Customer.Discount    = iDiscount.
    oResult:Add("success", TRUE).
    oResult:Add("message", "Customer created").
    oResult:Add("CustNum", Customer.CustNum).
    oResult:Add("Name",    Customer.Name).
    RETURN CreateMcpResponseJson(id, oResult, false).
END.

/* ---- UPDATE ---- */
IF cAction = "update" THEN DO:
    oResult = NEW Progress.Json.ObjectModel.JsonObject().
    IF iCustNum = 0 OR iCustNum = ? THEN DO:
        oResult:Add("success", FALSE).
        oResult:Add("error", "custNum required for update").
        RETURN CreateMcpResponseJson(id, oResult, false).
    END.
    FIND Customer WHERE Customer.CustNum = iCustNum EXCLUSIVE-LOCK NO-ERROR.
    IF AVAILABLE Customer THEN DO:
        IF cName     <> "" AND cName     <> ? THEN Customer.Name         = cName.
        IF cAddress  <> "" AND cAddress  <> ? THEN Customer.Address      = cAddress.
        IF cAddress2 <> "" AND cAddress2 <> ? THEN Customer.Address2     = cAddress2.
        IF cCity     <> "" AND cCity     <> ? THEN Customer.City         = cCity.
        IF cState    <> "" AND cState    <> ? THEN Customer.State        = cState.
        IF cPostal   <> "" AND cPostal   <> ? THEN Customer.PostalCode   = cPostal.
        IF cCountry  <> "" AND cCountry  <> ? THEN Customer.Country      = cCountry.
        IF cPhone    <> "" AND cPhone    <> ? THEN Customer.Phone        = cPhone.
        IF cFax      <> "" AND cFax      <> ? THEN Customer.Fax         = cFax.
        IF cEmail    <> "" AND cEmail    <> ? THEN Customer.EmailAddress = cEmail.
        IF cContact  <> "" AND cContact  <> ? THEN Customer.Contact      = cContact.
        IF cSalesRep <> "" AND cSalesRep <> ? THEN Customer.SalesRep    = cSalesRep.
        IF cTerms    <> "" AND cTerms    <> ? THEN Customer.Terms       = cTerms.
        IF cComments <> "" AND cComments <> ? THEN Customer.Comments    = cComments.
        IF lHasCredit   THEN Customer.CreditLimit = dCreditLim.
        IF lHasDiscount THEN Customer.Discount    = iDiscount.
        oResult:Add("success", TRUE).
        oResult:Add("message", "Customer " + STRING(iCustNum) + " updated").
        oResult:Add("CustNum", Customer.CustNum).
        oResult:Add("Name",    Customer.Name).
    END.
    ELSE DO:
        oResult:Add("success", FALSE).
        oResult:Add("error", "Customer " + STRING(iCustNum) + " not found").
    END.
    RETURN CreateMcpResponseJson(id, oResult, false).
END.

/* ---- DELETE ---- */
IF cAction = "delete" THEN DO:
    oResult = NEW Progress.Json.ObjectModel.JsonObject().
    IF iCustNum = 0 OR iCustNum = ? THEN DO:
        oResult:Add("success", FALSE).
        oResult:Add("error", "custNum required for delete").
        RETURN CreateMcpResponseJson(id, oResult, false).
    END.
    FIND Customer WHERE Customer.CustNum = iCustNum EXCLUSIVE-LOCK NO-ERROR.
    IF AVAILABLE Customer THEN DO:
        cDelName = Customer.Name.
        DELETE Customer.
        oResult:Add("success", TRUE).
        oResult:Add("message", "Customer " + STRING(iCustNum) + " (" + cDelName + ") deleted").
        oResult:Add("CustNum", iCustNum).
    END.
    ELSE DO:
        oResult:Add("success", FALSE).
        oResult:Add("error", "Customer " + STRING(iCustNum) + " not found").
    END.
    RETURN CreateMcpResponseJson(id, oResult, false).
END.

/* ---- UNKNOWN ACTION ---- */
oResult = NEW Progress.Json.ObjectModel.JsonObject().
oResult:Add("success", FALSE).
oResult:Add("error", "Unknown action: " + cAction + ". Use: list|get|create|update|delete").
RETURN CreateMcpResponseJson(id, oResult, false).


    END.

END CLASS.
