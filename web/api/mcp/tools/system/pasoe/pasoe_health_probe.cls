USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS web.api.mcp.tools.system.pasoe.pasoe_health_probe INHERITS web.api.mcp.tools.base.tool :

    METHOD PUBLIC OVERRIDE JsonObject Execute(id AS integer, poArguments AS JsonObject):

DEFINE VARIABLE cInstance   AS CHARACTER NO-UNDO INITIAL "oepas1".
DEFINE VARIABLE cPort       AS CHARACTER NO-UNDO INITIAL "8810".
DEFINE VARIABLE cUser       AS CHARACTER NO-UNDO INITIAL "tomcat".
DEFINE VARIABLE cPass       AS CHARACTER NO-UNDO INITIAL "tomcat".
DEFINE VARIABLE oClient     AS OpenEdge.Net.HTTP.IHttpClient NO-UNDO.
DEFINE VARIABLE oResponse   AS OpenEdge.Net.HTTP.IHttpResponse NO-UNDO.
DEFINE VARIABLE oCredential AS OpenEdge.Net.HTTP.Credentials NO-UNDO.
DEFINE VARIABLE oResult     AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
DEFINE VARIABLE oBody       AS Progress.Lang.Object NO-UNDO.
DEFINE VARIABLE mBody       AS MEMPTR NO-UNDO.
DEFINE VARIABLE cRespText   AS CHARACTER NO-UNDO.
DEFINE VARIABLE oReq        AS OpenEdge.Net.HTTP.IHttpRequest NO-UNDO.
DEFINE VARIABLE oHeader     AS OpenEdge.Net.HTTP.HttpHeader NO-UNDO.
DEFINE VARIABLE cUrl        AS CHARACTER NO-UNDO.

oClient     = OpenEdge.Net.HTTP.ClientBuilder:Build():Client.
oCredential = NEW OpenEdge.Net.HTTP.Credentials("OESPA", cUser, cPass).
cUrl        = "http://localhost:" + cPort + "/oemanager/applications/" + cInstance + "/agents".

oReq = OpenEdge.Net.HTTP.RequestBuilder:Get(cUrl)
           :UsingBasicAuthentication(oCredential)
           :Request.
oHeader = NEW OpenEdge.Net.HTTP.HttpHeader("Accept", "application/vnd.progress+json").
oReq:SetHeader(oHeader).

oResponse = oClient:Execute(oReq).
oBody = oResponse:Entity.

oResult = NEW Progress.Json.ObjectModel.JsonObject().
oResult:Add("status_code", oResponse:StatusCode).
oResult:Add("status_reason", oResponse:StatusReason).
oResult:Add("body_type", oBody:GetClass():TypeName).

IF TYPE-OF(oBody, OpenEdge.Core.String) THEN DO:
    cRespText = CAST(oBody, OpenEdge.Core.String):Value.
    oResult:Add("body_text", SUBSTRING(cRespText, 1, 500)).
END.
ELSE IF TYPE-OF(oBody, Progress.Json.ObjectModel.JsonObject) THEN DO:
    oResult:Add("body_json", CAST(oBody, Progress.Json.ObjectModel.JsonObject)).
END.
ELSE IF TYPE-OF(oBody, OpenEdge.Core.ByteBucket) THEN DO:
    mBody = CAST(oBody, OpenEdge.Core.ByteBucket):GetBytes():Value.
    oResult:Add("body_text", SUBSTRING(GET-STRING(mBody, 1), 1, 500)).
END.

RETURN CreateMcpResponseJson(id, oResult, false).


    END.

END CLASS.
