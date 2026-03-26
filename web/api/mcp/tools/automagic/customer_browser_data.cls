USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS web.api.mcp.tools.automagic.customer_browser_data INHERITS web.api.mcp.tools.base.tool :

    METHOD PUBLIC OVERRIDE JsonObject Execute(id AS integer, poArguments AS JsonObject):

DEFINE VARIABLE iPage     AS INTEGER   NO-UNDO.
DEFINE VARIABLE cFilter   AS CHARACTER NO-UNDO.
DEFINE VARIABLE cSortBy   AS CHARACTER NO-UNDO.
DEFINE VARIABLE iStart    AS INTEGER   NO-UNDO.
DEFINE VARIABLE iEnd      AS INTEGER   NO-UNDO.
DEFINE VARIABLE iCount    AS INTEGER   NO-UNDO.
DEFINE VARIABLE iRowNum   AS INTEGER   NO-UNDO.
DEFINE VARIABLE oResult   AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
DEFINE VARIABLE oRows     AS Progress.Json.ObjectModel.JsonArray  NO-UNDO.
DEFINE VARIABLE oRow      AS Progress.Json.ObjectModel.JsonObject NO-UNDO.

iPage = INTEGER(poArguments:GetCharacter("page")) NO-ERROR.
IF iPage <= 0 OR ERROR-STATUS:ERROR THEN iPage = 1.

cFilter = poArguments:GetCharacter("filter").
cSortBy = poArguments:GetCharacter("sortBy").
IF cSortBy = "" THEN cSortBy = "CustNum".

iStart = (iPage - 1) * 25 + 1.
iEnd   = iPage * 25.

/* Count total matching rows */
FOR EACH Customer NO-LOCK
    WHERE (cFilter = ""
        OR Customer.Name    BEGINS cFilter
        OR Customer.City    BEGINS cFilter
        OR Customer.Country BEGINS cFilter):
    iCount = iCount + 1.
END.

oRows = NEW Progress.Json.ObjectModel.JsonArray().

IF cSortBy = "Name" THEN
DO:
    FOR EACH Customer NO-LOCK
        WHERE (cFilter = ""
            OR Customer.Name    BEGINS cFilter
            OR Customer.City    BEGINS cFilter
            OR Customer.Country BEGINS cFilter)
        BY Customer.Name:

        iRowNum = iRowNum + 1.
        IF iRowNum < iStart THEN NEXT.
        IF iRowNum > iEnd   THEN LEAVE.

        oRow = NEW Progress.Json.ObjectModel.JsonObject().
        oRow:Add("custNum",     Customer.CustNum).
        oRow:Add("name",        Customer.Name).
        oRow:Add("city",        Customer.City).
        oRow:Add("country",     Customer.Country).
        oRow:Add("balance",     Customer.Balance).
        oRow:Add("creditLimit", Customer.CreditLimit).
        oRow:Add("phone",       Customer.Phone).
        oRow:Add("contact",     Customer.Contact).
        oRow:Add("salesRep",    Customer.SalesRep).
        oRows:Add(oRow).
    END.
END.
ELSE
DO:
    FOR EACH Customer NO-LOCK
        WHERE (cFilter = ""
            OR Customer.Name    BEGINS cFilter
            OR Customer.City    BEGINS cFilter
            OR Customer.Country BEGINS cFilter)
        BY Customer.CustNum:

        iRowNum = iRowNum + 1.
        IF iRowNum < iStart THEN NEXT.
        IF iRowNum > iEnd   THEN LEAVE.

        oRow = NEW Progress.Json.ObjectModel.JsonObject().
        oRow:Add("custNum",     Customer.CustNum).
        oRow:Add("name",        Customer.Name).
        oRow:Add("city",        Customer.City).
        oRow:Add("country",     Customer.Country).
        oRow:Add("balance",     Customer.Balance).
        oRow:Add("creditLimit", Customer.CreditLimit).
        oRow:Add("phone",       Customer.Phone).
        oRow:Add("contact",     Customer.Contact).
        oRow:Add("salesRep",    Customer.SalesRep).
        oRows:Add(oRow).
    END.
END.

oResult = NEW Progress.Json.ObjectModel.JsonObject().
oResult:Add("page",       iPage).
oResult:Add("totalRows",  iCount).
oResult:Add("totalPages", INTEGER((iCount + 24) / 25)).
oResult:Add("rowsPerPage",25).
oResult:Add("sortBy",     cSortBy).
oResult:Add("filter",     cFilter).
oResult:Add("rows",       oRows).

RETURN CreateMcpResponseJson(id, oResult, false).


    END.

END CLASS.
