USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS web.api.mcp.tools.automagic.get_customer_data_sql INHERITS web.api.mcp.tools.base.tool :

    METHOD PUBLIC OVERRIDE JsonObject Execute(id AS integer, poArguments AS JsonObject):

        DEFINE VARIABLE cSQL      AS LONGCHAR  NO-UNDO.
        DEFINE VARIABLE cWhere    AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cName     AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cCountry  AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cSalesRep AS CHARACTER NO-UNDO.
        DEFINE VARIABLE dMinBal   AS DECIMAL   NO-UNDO INITIAL ?.
        DEFINE VARIABLE dMaxBal   AS DECIMAL   NO-UNDO INITIAL ?.
        DEFINE VARIABLE iMax      AS INTEGER   NO-UNDO INITIAL 50.
        DEFINE VARIABLE hDataset  AS HANDLE    NO-UNDO.
        DEFINE VARIABLE lBody     AS LONGCHAR  NO-UNDO.

        /* Read optional input arguments */
        ASSIGN
            cName = poArguments:GetCharacter("customerName") NO-ERROR.
        ASSIGN
            cCountry = poArguments:GetCharacter("country")      NO-ERROR.
        ASSIGN
            cSalesRep = poArguments:GetCharacter("salesRep")     NO-ERROR.

        IF poArguments:Has("minBalance") THEN
            dMinBal = poArguments:GetDecimal("minBalance").
        IF poArguments:Has("maxBalance") THEN
            dMaxBal = poArguments:GetDecimal("maxBalance").
        IF poArguments:Has("maxRows") THEN
            iMax = poArguments:GetInteger("maxRows").

        /* Build WHERE clause dynamically */
        IF cName <> "" AND cName <> ? THEN 
        DO:
            IF cWhere <> "" THEN cWhere = cWhere + " AND ".
            cWhere = cWhere + "Name LIKE '%" + cName + "%'".
        END.
        IF cCountry <> "" AND cCountry <> ? THEN 
        DO:
            IF cWhere <> "" THEN cWhere = cWhere + " AND ".
            cWhere = cWhere + "Country = '" + cCountry + "'".
        END.
        IF cSalesRep <> "" AND cSalesRep <> ? THEN 
        DO:
            IF cWhere <> "" THEN cWhere = cWhere + " AND ".
            cWhere = cWhere + "SalesRep = '" + cSalesRep + "'".
        END.
        IF dMinBal <> ? THEN 
        DO:
            IF cWhere <> "" THEN cWhere = cWhere + " AND ".
            cWhere = cWhere + "Balance >= " + STRING(dMinBal).
        END.
        IF dMaxBal <> ? THEN 
        DO:
            IF cWhere <> "" THEN cWhere = cWhere + " AND ".
            cWhere = cWhere + "Balance <= " + STRING(dMaxBal).
        END.

        /* Build final SQL statement */
        cSQL = "SELECT TOP " + STRING(iMax)
            + " CustNum, Name, City, Country, Phone, EmailAddress,"
            + " Balance, CreditLimit, SalesRep, Discount"
            + " FROM PUB.Customer".

        IF cWhere <> "" THEN
            cSQL = cSQL + " WHERE " + cWhere.

        cSQL = cSQL + " ORDER BY CustNum".

        LOG-MANAGER:WRITE-MESSAGE("get_customer_data_sql: " + STRING(cSQL), "LOG").

        RUN web\api\executesqlquery.p (INPUT cSQL, OUTPUT DATASET-HANDLE hDataset).
        hDataset:WRITE-JSON("longchar", lBody, TRUE).

        RETURN CreateMcpResponseText(id, lBody, TRUE).

        CATCH e AS Progress.Lang.Error:
            DEFINE VARIABLE iLoop AS INTEGER NO-UNDO.
            LOG-MANAGER:WRITE-MESSAGE("get_customer_data_sql ERROR", "ERR").
            DO iLoop = 1 TO e:NumMessages:
                LOG-MANAGER:WRITE-MESSAGE(
                    SUBSTITUTE("Error &1: &2", e:GetMessageNum(iLoop), e:GetMessage(iLoop)),
                    "ERR").
            END.
            RETURN CreateMcpResponseText(id, "Error executing SQL customer query.", FALSE).
        END CATCH.

    END.

END CLASS.
