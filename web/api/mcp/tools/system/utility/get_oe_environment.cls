USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS web.api.mcp.tools.system.utility.get_oe_environment INHERITS web.api.mcp.tools.base.tool :

    METHOD PUBLIC OVERRIDE JsonObject Execute(id AS integer, poArguments AS JsonObject):

        DEFINE VARIABLE oResult   AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
        DEFINE VARIABLE cPropath  AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cDlcPath  AS CHARACTER                            NO-UNDO.

        oResult  = NEW Progress.Json.ObjectModel.JsonObject().
        cPropath = PROPATH.
        cDlcPath = OS-GETENV("DLC").

        oResult:Add("status",  "ok").
        oResult:Add("propath", cPropath).
        oResult:Add("dlc",     cDlcPath).
        oResult:Add("pasoe instance", 'oepas1').
        oResult:Add("pasoe path",     'C:\progress\OE128_64_WRK\oepas1\').
        oResult:Add("pasoe root",     'C:\progress\OE128_64_WRK\oepas1\webapps\ROOT' ).
   
        RETURN CreateMcpResponseJson(id, oResult, false).

    END.

END CLASS.
