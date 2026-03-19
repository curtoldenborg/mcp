

BLOCK-LEVEL ON ERROR UNDO, THROW.

USING Progress.Json.ObjectModel.*.

DEFINE VARIABLE oObject AS web.api.mcp.tools.sales_pr_month no-undo. 
DEFINE VARIABLE poArguments    AS JsonObject        NO-UNDO.
DEFINE VARIABLE oJsonResponse AS JsonObject NO-UNDO.
DEFINE VARIABLE lcDisplay AS LONGCHAR NO-UNDO.

oObject = new web.api.mcp.tools.sales_pr_month().

DEFINE VARIABLE oTool         AS web.api.mcp.tools.base.tool  NO-UNDO.          
DEFINE VARIABLE cToolName     AS CHARACTER         NO-UNDO.
DEFINE VARIABLE cClassName    AS CHARACTER         NO-UNDO. 
 cToolName = "sales_pr_month". 
 cClassName = "web.api.mcp.tools." + cToolName.
 oTool = DYNAMIC-NEW cClassName().

oJsonResponse =  oObject:Execute(1, poArguments).

/* Serialize JsonObject to a formatted string */
oJsonResponse:Write(lcDisplay, TRUE). 
oJsonResponse:WriteFile("debug_response.json", TRUE).

MESSAGE STRING(lcDisplay) VIEW-AS ALERT-BOX. 
