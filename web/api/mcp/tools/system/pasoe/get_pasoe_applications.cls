USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS web.api.mcp.tools.system.pasoe.get_pasoe_applications INHERITS web.api.mcp.tools.base.tool :

    METHOD PUBLIC OVERRIDE JsonObject Execute(id AS integer, poArguments AS JsonObject):

        DEFINE VARIABLE cPort        AS CHARACTER                            NO-UNDO INITIAL "8810".
        DEFINE VARIABLE cUser        AS CHARACTER                            NO-UNDO INITIAL "tomcat".
        DEFINE VARIABLE cPass        AS CHARACTER                            NO-UNDO INITIAL "tomcat".
        DEFINE VARIABLE oClient      AS OpenEdge.Net.HTTP.IHttpClient        NO-UNDO.
        DEFINE VARIABLE oResponse    AS OpenEdge.Net.HTTP.IHttpResponse      NO-UNDO.
        DEFINE VARIABLE oCredential  AS OpenEdge.Net.HTTP.Credentials        NO-UNDO.
        DEFINE VARIABLE oResult      AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
        DEFINE VARIABLE oAppsResp    AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
        DEFINE VARIABLE oAppResult   AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
        DEFINE VARIABLE oAppDetail   AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
        DEFINE VARIABLE oAppEntry    AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
        DEFINE VARIABLE oAppsArray   AS Progress.Json.ObjectModel.JsonArray  NO-UNDO.
        DEFINE VARIABLE oDetailArray AS Progress.Json.ObjectModel.JsonArray  NO-UNDO.
        DEFINE VARIABLE oBody        AS Progress.Lang.Object                 NO-UNDO.
        DEFINE VARIABLE oReq         AS OpenEdge.Net.HTTP.IHttpRequest       NO-UNDO.
        DEFINE VARIABLE oHeader      AS OpenEdge.Net.HTTP.HttpHeader         NO-UNDO.
        DEFINE VARIABLE iStatus      AS INTEGER                              NO-UNDO.
        DEFINE VARIABLE i            AS INTEGER                              NO-UNDO.
        DEFINE VARIABLE j            AS INTEGER                              NO-UNDO.
        DEFINE VARIABLE cUrl         AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cAppName     AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cBaseUrl     AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cEndpoints   AS CHARACTER                            NO-UNDO INITIAL "agents,sessions,metrics".
        DEFINE VARIABLE cEndpoint    AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE oSection     AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
        DEFINE VARIABLE oAppNames    AS Progress.Json.ObjectModel.JsonArray  NO-UNDO.

        IF poArguments:Has("port") THEN 
        DO:
            cPort = STRING(poArguments:GetInteger("port")).
            IF cPort = "" OR cPort = ? THEN cPort = "8810".
        END.
        IF poArguments:Has("username") THEN cUser = poArguments:GetCharacter("username").
        IF poArguments:Has("password") THEN cPass = poArguments:GetCharacter("password").

        cBaseUrl    = "http://localhost:" + cPort + "/oemanager".
        oClient     = OpenEdge.Net.HTTP.ClientBuilder:Build():Client.
        oCredential = NEW OpenEdge.Net.HTTP.Credentials("OESPA", cUser, cPass).

        oResult = NEW Progress.Json.ObjectModel.JsonObject().
        oResult:Add("timestamp", STRING(NOW)).
        oResult:Add("port", INTEGER(cPort)).
        oResult:Add("oemanager_url", cBaseUrl).

        /* Step 1: get list of all applications */
        cUrl  = cBaseUrl + "/applications".
        oReq  = OpenEdge.Net.HTTP.RequestBuilder:Get(cUrl):UsingBasicAuthentication(oCredential):Request.
        oHeader = NEW OpenEdge.Net.HTTP.HttpHeader("Accept", "application/vnd.progress+json").
        oReq:SetHeader(oHeader).
        oResponse = oClient:Execute(oReq).
        iStatus   = oResponse:StatusCode.

        IF iStatus <> 200 THEN 
        DO:
            oResult:Add("error", "Failed to get applications list - HTTP " + STRING(iStatus)).
            RETURN CreateMcpResponseJson(id, oResult, false).
        END.

        oBody = oResponse:Entity.
        IF NOT TYPE-OF(oBody, Progress.Json.ObjectModel.JsonObject) THEN 
        DO:
            oResult:Add("error", "Unexpected response body type").
            RETURN CreateMcpResponseJson(id, oResult, false).
        END.

        oAppsResp = CAST(oBody, Progress.Json.ObjectModel.JsonObject).
        oResult:Add("applications_raw", oAppsResp).

        /* Try to extract app names from result */
        IF oAppsResp:Has("result") THEN 
        DO:
            oAppResult = oAppsResp:GetJsonObject("result").

            /* result may contain an array directly or a named key */
            IF oAppResult:Has("Application") THEN 
            DO:
                oAppsArray  = oAppResult:GetJsonArray("Application").
                oDetailArray = NEW Progress.Json.ObjectModel.JsonArray().

                DO i = 1 TO oAppsArray:Length:
                    oAppEntry  = oAppsArray:GetJsonObject(i).
                    cAppName   = oAppEntry:GetCharacter("name") NO-ERROR.
                    IF cAppName = "" OR cAppName = ? THEN NEXT.

                    oSection = NEW Progress.Json.ObjectModel.JsonObject().
                    oSection:Add("name", cAppName).

                    /* Fetch agents, sessions, metrics per app */
                    DO j = 1 TO NUM-ENTRIES(cEndpoints):
                        cEndpoint = ENTRY(j, cEndpoints).
                        cUrl = cBaseUrl + "/applications/" + cAppName + "/" + cEndpoint.
                        oReq = OpenEdge.Net.HTTP.RequestBuilder:Get(cUrl):UsingBasicAuthentication(oCredential):Request.
                        oHeader = NEW OpenEdge.Net.HTTP.HttpHeader("Accept", "application/vnd.progress+json").
                        oReq:SetHeader(oHeader).
                        oResponse = oClient:Execute(oReq).
                        IF oResponse:StatusCode = 200 THEN 
                        DO:
                            oBody = oResponse:Entity.
                            IF TYPE-OF(oBody, Progress.Json.ObjectModel.JsonObject) THEN
                                oSection:Add(cEndpoint, CAST(oBody, Progress.Json.ObjectModel.JsonObject)).
                        END.
                        ELSE
                            oSection:Add(cEndpoint + "_error", "HTTP " + STRING(oResponse:StatusCode)).
                    END.

                    oDetailArray:Add(oSection).
                END.

                oResult:Add("application_details", oDetailArray).
            END.
        END.

        RETURN CreateMcpResponseJson(id, oResult, false).


    END.

END CLASS.
