USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS web.api.mcp.tools.system.pasoe.oemanager_dashboard INHERITS web.api.mcp.tools.base.tool :

    METHOD PUBLIC OVERRIDE JsonObject Execute(id AS integer, poArguments AS JsonObject):

DEFINE VARIABLE cPort        AS CHARACTER NO-UNDO INITIAL "8810".
DEFINE VARIABLE cUser        AS CHARACTER NO-UNDO INITIAL "tomcat".
DEFINE VARIABLE cPass        AS CHARACTER NO-UNDO INITIAL "tomcat".
DEFINE VARIABLE cBaseUrl     AS CHARACTER NO-UNDO.
DEFINE VARIABLE oClient      AS OpenEdge.Net.HTTP.IHttpClient NO-UNDO.
DEFINE VARIABLE oResponse    AS OpenEdge.Net.HTTP.IHttpResponse NO-UNDO.
DEFINE VARIABLE oCredential  AS OpenEdge.Net.HTTP.Credentials NO-UNDO.
DEFINE VARIABLE oReq         AS OpenEdge.Net.HTTP.IHttpRequest NO-UNDO.
DEFINE VARIABLE oHeader      AS OpenEdge.Net.HTTP.HttpHeader NO-UNDO.
DEFINE VARIABLE oResult      AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
DEFINE VARIABLE oAppsResp    AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
DEFINE VARIABLE oAppResult   AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
DEFINE VARIABLE oAppEntry    AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
DEFINE VARIABLE oAppsArray   AS Progress.Json.ObjectModel.JsonArray NO-UNDO.
DEFINE VARIABLE oAppDetail   AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
DEFINE VARIABLE oDetailArray AS Progress.Json.ObjectModel.JsonArray NO-UNDO.
DEFINE VARIABLE oSection     AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
DEFINE VARIABLE iStatus      AS INTEGER NO-UNDO.
DEFINE VARIABLE i            AS INTEGER NO-UNDO.
DEFINE VARIABLE cUrl         AS CHARACTER NO-UNDO.
DEFINE VARIABLE cAppName     AS CHARACTER NO-UNDO.

IF poArguments:Has("port")     THEN DO: cPort = STRING(poArguments:GetInteger("port")). IF cPort = "" OR cPort = ? THEN cPort = "8810". END.
IF poArguments:Has("username") THEN cUser = poArguments:GetCharacter("username").
IF poArguments:Has("password") THEN cPass = poArguments:GetCharacter("password").

cBaseUrl    = "http://localhost:" + cPort + "/oemanager".
oClient     = OpenEdge.Net.HTTP.ClientBuilder:Build():Client.
oCredential = NEW OpenEdge.Net.HTTP.Credentials("OESPA", cUser, cPass).

oResult = NEW Progress.Json.ObjectModel.JsonObject().
oResult:Add("timestamp",     STRING(NOW)).
oResult:Add("port",          INTEGER(cPort)).
oResult:Add("oemanager_url", cBaseUrl).

cUrl      = cBaseUrl + "/applications".
oReq      = OpenEdge.Net.HTTP.RequestBuilder:Get(cUrl):UsingBasicAuthentication(oCredential):Request.
oHeader   = NEW OpenEdge.Net.HTTP.HttpHeader("Accept", "application/vnd.progress+json").
oReq:SetHeader(oHeader).
oResponse = oClient:Execute(oReq).
iStatus   = oResponse:StatusCode.

IF iStatus <> 200 THEN DO:
    oResult:Add("error", "HTTP " + STRING(iStatus)).
    RETURN CreateMcpResponseJson(id, oResult, false).
END.

oAppsResp    = CAST(oResponse:Entity, Progress.Json.ObjectModel.JsonObject).
oResult:Add("oemanager_version", oAppsResp:GetCharacter("versionStr")).
oAppResult   = oAppsResp:GetJsonObject("result").
oAppsArray   = oAppResult:GetJsonArray("Application").
oDetailArray = NEW Progress.Json.ObjectModel.JsonArray().
oResult:Add("total_applications", oAppsArray:Length).

DO i = 1 TO oAppsArray:Length:
    oAppEntry  = oAppsArray:GetJsonObject(i).
    cAppName   = oAppEntry:GetCharacter("name").
    IF cAppName = "" OR cAppName = ? THEN NEXT.

    oAppDetail = NEW Progress.Json.ObjectModel.JsonObject().
    oAppDetail:Add("name",        cAppName).
    oAppDetail:Add("version",     oAppEntry:GetCharacter("version")).
    oAppDetail:Add("description", oAppEntry:GetCharacter("description")).
    IF oAppEntry:Has("webapps") THEN
        oAppDetail:Add("webapps", oAppEntry:GetJsonArray("webapps")).

    /* Agents */
    oReq    = OpenEdge.Net.HTTP.RequestBuilder:Get(cBaseUrl + "/applications/" + cAppName + "/agents"):UsingBasicAuthentication(oCredential):Request.
    oHeader = NEW OpenEdge.Net.HTTP.HttpHeader("Accept", "application/vnd.progress+json").
    oReq:SetHeader(oHeader).
    oResponse = oClient:Execute(oReq).
    IF oResponse:StatusCode = 200 AND TYPE-OF(oResponse:Entity, Progress.Json.ObjectModel.JsonObject) THEN DO:
        oSection = CAST(oResponse:Entity, Progress.Json.ObjectModel.JsonObject).
        IF oSection:GetCharacter("outcome") = "SUCCESS" THEN oAppDetail:Add("agents", oSection:GetJsonObject("result")).
    END.

    /* Sessions */
    oReq    = OpenEdge.Net.HTTP.RequestBuilder:Get(cBaseUrl + "/applications/" + cAppName + "/sessions"):UsingBasicAuthentication(oCredential):Request.
    oHeader = NEW OpenEdge.Net.HTTP.HttpHeader("Accept", "application/vnd.progress+json").
    oReq:SetHeader(oHeader).
    oResponse = oClient:Execute(oReq).
    IF oResponse:StatusCode = 200 AND TYPE-OF(oResponse:Entity, Progress.Json.ObjectModel.JsonObject) THEN DO:
        oSection = CAST(oResponse:Entity, Progress.Json.ObjectModel.JsonObject).
        IF oSection:GetCharacter("outcome") = "SUCCESS" THEN oAppDetail:Add("sessions", oSection:GetJsonObject("result")).
    END.

    /* Metrics */
    oReq    = OpenEdge.Net.HTTP.RequestBuilder:Get(cBaseUrl + "/applications/" + cAppName + "/metrics"):UsingBasicAuthentication(oCredential):Request.
    oHeader = NEW OpenEdge.Net.HTTP.HttpHeader("Accept", "application/vnd.progress+json").
    oReq:SetHeader(oHeader).
    oResponse = oClient:Execute(oReq).
    IF oResponse:StatusCode = 200 AND TYPE-OF(oResponse:Entity, Progress.Json.ObjectModel.JsonObject) THEN DO:
        oSection = CAST(oResponse:Entity, Progress.Json.ObjectModel.JsonObject).
        IF oSection:GetCharacter("outcome") = "SUCCESS" THEN oAppDetail:Add("metrics", oSection:GetJsonObject("result")).
    END.

    /* Properties */
    oReq    = OpenEdge.Net.HTTP.RequestBuilder:Get(cBaseUrl + "/applications/" + cAppName + "/properties"):UsingBasicAuthentication(oCredential):Request.
    oHeader = NEW OpenEdge.Net.HTTP.HttpHeader("Accept", "application/vnd.progress+json").
    oReq:SetHeader(oHeader).
    oResponse = oClient:Execute(oReq).
    IF oResponse:StatusCode = 200 AND TYPE-OF(oResponse:Entity, Progress.Json.ObjectModel.JsonObject) THEN DO:
        oSection = CAST(oResponse:Entity, Progress.Json.ObjectModel.JsonObject).
        IF oSection:GetCharacter("outcome") = "SUCCESS" THEN oAppDetail:Add("properties", oSection:GetJsonObject("result")).
    END.

    oDetailArray:Add(oAppDetail).
END.

oResult:Add("applications", oDetailArray).
RETURN CreateMcpResponseJson(id, oResult, false).


    END.

END CLASS.
