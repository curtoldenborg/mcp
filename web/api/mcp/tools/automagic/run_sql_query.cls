USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS web.api.mcp.tools.automagic.run_sql_query INHERITS web.api.mcp.tools.base.tool :

    METHOD PUBLIC OVERRIDE JsonObject Execute(id AS integer, poArguments AS JsonObject):

        DEFINE VARIABLE cQueryName AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cParam1    AS CHARACTER NO-UNDO.
        DEFINE VARIABLE iCount     AS INTEGER   NO-UNDO.
        DEFINE VARIABLE cRows      AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cRow       AS CHARACTER NO-UNDO.
        DEFINE VARIABLE lcResult   AS LONGCHAR  NO-UNDO.
        DEFINE VARIABLE iInvNum    AS INTEGER   NO-UNDO.
        DEFINE VARIABLE cQ         AS CHARACTER NO-UNDO INITIAL '"'.

        ASSIGN 
            cQueryName = poArguments:GetCharacter("query_name") NO-ERROR.
        ASSIGN 
            cParam1 = poArguments:GetCharacter("param1")     NO-ERROR.

        cRows  = "".
        iCount = 0.

        CASE cQueryName:

            WHEN "top_customers" THEN 
                DO:
                    FOR EACH Customer NO-LOCK BY Customer.Balance DESCENDING:
                        cRow = "~{".
                        cRow = cRow + cQ + "CustNum" + cQ + ":" + cQ + STRING(Customer.CustNum) + cQ.
                        cRow = cRow + "," + cQ + "Name" + cQ + ":" + cQ + REPLACE(Customer.Name,cQ,"") + cQ.
                        cRow = cRow + "," + cQ + "Balance" + cQ + ":" + cQ + STRING(Customer.Balance,">>>,>>9.99") + cQ.
                        cRow = cRow + "," + cQ + "Credit" + cQ + ":" + cQ + STRING(Customer.CreditLimit,">>>,>>9.99") + cQ.
                        cRow = cRow + "," + cQ + "City" + cQ + ":" + cQ + REPLACE(Customer.City,cQ,"") + cQ.
                        cRow = cRow + "," + cQ + "State" + cQ + ":" + cQ + REPLACE(Customer.State,cQ,"") + cQ.
                        cRow = cRow + "~}".
                        IF iCount > 0 THEN cRows = cRows + ",".
                        cRows = cRows + cRow.
                        iCount = iCount + 1.
                        IF iCount >= 50 THEN LEAVE.
                    END.
                END.

            WHEN "open_orders" THEN 
                DO:
                    FOR EACH Order NO-LOCK WHERE Order.OrderStatus <> "Shipped",
                        FIRST Customer OF Order NO-LOCK BY Order.OrderDate DESCENDING:
                        IF cParam1 <> "" AND cParam1 <> ? THEN
                            IF Order.CustNum <> INTEGER(cParam1) THEN NEXT.
                        cRow = "~{".
                        cRow = cRow + cQ + "OrderNum" + cQ + ":" + cQ + STRING(Order.OrderNum) + cQ.
                        cRow = cRow + "," + cQ + "CustNum" + cQ + ":" + cQ + STRING(Order.CustNum) + cQ.
                        cRow = cRow + "," + cQ + "Customer" + cQ + ":" + cQ + REPLACE(Customer.Name,cQ,"") + cQ.
                        cRow = cRow + "," + cQ + "Date" + cQ + ":" + cQ + STRING(Order.OrderDate,"99/99/9999") + cQ.
                        cRow = cRow + "," + cQ + "Status" + cQ + ":" + cQ + REPLACE(Order.OrderStatus,cQ,"") + cQ.
                        cRow = cRow + "," + cQ + "SalesRep" + cQ + ":" + cQ + REPLACE(Order.SalesRep,cQ,"") + cQ.
                        cRow = cRow + "~}".
                        IF iCount > 0 THEN cRows = cRows + ",".
                        cRows = cRows + cRow.
                        iCount = iCount + 1.
                        IF iCount >= 50 THEN LEAVE.
                    END.
                END.

            WHEN "low_stock_items" THEN 
                DO:
                    FOR EACH Item NO-LOCK WHERE Item.OnHand <= Item.ReOrder BY Item.OnHand:
                        cRow = "~{".
                        cRow = cRow + cQ + "ItemNum" + cQ + ":" + cQ + STRING(Item.ItemNum) + cQ.
                        cRow = cRow + "," + cQ + "Name" + cQ + ":" + cQ + REPLACE(Item.ItemName,cQ,"") + cQ.
                        cRow = cRow + "," + cQ + "OnHand" + cQ + ":" + cQ + STRING(Item.OnHand) + cQ.
                        cRow = cRow + "," + cQ + "ReOrder" + cQ + ":" + cQ + STRING(Item.ReOrder) + cQ.
                        cRow = cRow + "," + cQ + "Price" + cQ + ":" + cQ + STRING(Item.Price,">>>,>>9.99") + cQ.
                        cRow = cRow + "," + cQ + "Category" + cQ + ":" + cQ + REPLACE(Item.Category1,cQ,"") + cQ.
                        cRow = cRow + "~}".
                        IF iCount > 0 THEN cRows = cRows + ",".
                        cRows = cRows + cRow.
                        iCount = iCount + 1.
                        IF iCount >= 50 THEN LEAVE.
                    END.
                END.

            WHEN "sales_by_rep" THEN 
                DO:
                    FOR EACH SalesRep NO-LOCK BY SalesRep.RepName:
                        cRow = "~{".
                        cRow = cRow + cQ + "SalesRep" + cQ + ":" + cQ + REPLACE(SalesRep.SalesRep,cQ,"") + cQ.
                        cRow = cRow + "," + cQ + "RepName" + cQ + ":" + cQ + REPLACE(SalesRep.RepName,cQ,"") + cQ.
                        cRow = cRow + "," + cQ + "Region" + cQ + ":" + cQ + REPLACE(SalesRep.Region,cQ,"") + cQ.
//      cRow = cRow + "," + cQ + "MonthQuota" + cQ + ":" + cQ + STRING(SalesRep.MonthQuota) + cQ.
                        cRow = cRow + "~}".
                        IF iCount > 0 THEN cRows = cRows + ",".
                        cRows = cRows + cRow.
                        iCount = iCount + 1.
                        IF iCount >= 50 THEN LEAVE.
                    END.
                END.

            WHEN "recent_invoices" THEN 
                DO:
                    FOR EACH Invoice NO-LOCK,
                        FIRST Customer OF Invoice NO-LOCK BY Invoice.InvoiceDate DESCENDING:
                        IF cParam1 <> "" AND cParam1 <> ? THEN
                            IF Invoice.CustNum <> INTEGER(cParam1) THEN NEXT.
                        ASSIGN 
                            iInvNum = Invoice.InvoiceNum.
                        cRow = "~{".
                        cRow = cRow + cQ + "InvoiceNum" + cQ + ":" + cQ + STRING(iInvNum) + cQ.
                        cRow = cRow + "," + cQ + "CustNum" + cQ + ":" + cQ + STRING(Invoice.CustNum) + cQ.
                        cRow = cRow + "," + cQ + "Customer" + cQ + ":" + cQ + REPLACE(Customer.Name,cQ,"") + cQ.
                        cRow = cRow + "," + cQ + "Date" + cQ + ":" + cQ + STRING(Invoice.InvoiceDate,"99/99/9999") + cQ.
                        cRow = cRow + "," + cQ + "Amount" + cQ + ":" + cQ + STRING(Invoice.Amount,">>>,>>9.99") + cQ.
                        cRow = cRow + "," + cQ + "TotalPaid" + cQ + ":" + cQ + STRING(Invoice.TotalPaid,">>>,>>9.99") + cQ.
                        cRow = cRow + "~}".
                        IF iCount > 0 THEN cRows = cRows + ",".
                        cRows = cRows + cRow.
                        iCount = iCount + 1.
                        IF iCount >= 50 THEN LEAVE.
                    END.
                END.

            OTHERWISE 
            DO:
                cRow = "~{" + cQ + "error" + cQ + ":" + cQ + "Unknown: " + cQueryName + cQ + "~}".
                cRows = cRow.
            END.

        END CASE.

        lcResult = "[" + cRows + "]".
        RETURN CreateMcpResponseText(id, lcResult,False).


    END.

END CLASS.
