USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS web.api.mcp.tools.system.pasoe.pasoe_health_check INHERITS web.api.mcp.tools.base.tool :

    METHOD PUBLIC OVERRIDE JsonObject Execute(id AS integer, poArguments AS JsonObject):

        DEFINE VARIABLE cInstance    AS CHARACTER                            NO-UNDO INITIAL "oepas1".
        DEFINE VARIABLE cPort        AS CHARACTER                            NO-UNDO INITIAL "8810".
        DEFINE VARIABLE cUser        AS CHARACTER                            NO-UNDO INITIAL "tomcat".
        DEFINE VARIABLE cPass        AS CHARACTER                            NO-UNDO INITIAL "tomcat".
        DEFINE VARIABLE cBaseUrl     AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE oClient      AS OpenEdge.Net.HTTP.IHttpClient        NO-UNDO.
        DEFINE VARIABLE oResponse    AS OpenEdge.Net.HTTP.IHttpResponse      NO-UNDO.
        DEFINE VARIABLE oCredential  AS OpenEdge.Net.HTTP.Credentials        NO-UNDO.
        DEFINE VARIABLE oResult      AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
        DEFINE VARIABLE oSection     AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
        DEFINE VARIABLE oBody        AS Progress.Lang.Object                 NO-UNDO.
        DEFINE VARIABLE oReq         AS OpenEdge.Net.HTTP.IHttpRequest       NO-UNDO.
        DEFINE VARIABLE oHeader      AS OpenEdge.Net.HTTP.HttpHeader         NO-UNDO.
        DEFINE VARIABLE iStatus      AS INTEGER                              NO-UNDO.
        DEFINE VARIABLE i            AS INTEGER                              NO-UNDO.
        DEFINE VARIABLE cEndpoints   AS CHARACTER                            NO-UNDO INITIAL "agents,sessions,metrics".
        DEFINE VARIABLE cSectionName AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cEndpoint    AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cUrl         AS CHARACTER                            NO-UNDO.

        IF poArguments:Has("instance") THEN 
        DO:
            cInstance = poArguments:GetCharacter("instance").
            IF cInstance = "" OR cInstance = ? THEN cInstance = "oepas1".
        END.
        IF poArguments:Has("port") THEN 
        DO:
            cPort = STRING(poArguments:GetInteger("port")).
            IF cPort = "" OR cPort = ? THEN cPort = "8810".
        END.
        IF poArguments:Has("username") THEN cUser = poArguments:GetCharacter("username").
        IF poArguments:Has("password") THEN cPass = poArguments:GetCharacter("password").

        cBaseUrl    = "http://localhost:" + cPort + "/oemanager/applications/" + cInstance.
        oClient     = OpenEdge.Net.HTTP.ClientBuilder:Build():Client.
        oCredential = NEW OpenEdge.Net.HTTP.Credentials("OESPA", cUser, cPass).

        oResult = NEW Progress.Json.ObjectModel.JsonObject().
        oResult:Add("instance",      cInstance).
        oResult:Add("timestamp",     STRING(NOW)).
        oResult:Add("port",          INTEGER(cPort)).
        oResult:Add("oemanager_url", cBaseUrl).

        DO i = 1 TO NUM-ENTRIES(cEndpoints):
            cEndpoint    = ENTRY(i, cEndpoints).
            cSectionName = cEndpoint.
            cUrl         = cBaseUrl + "/" + cSectionName.

            oReq = OpenEdge.Net.HTTP.RequestBuilder:Get(cUrl)
               :UsingBasicAuthentication(oCredential)
               :Request.
            oHeader = NEW OpenEdge.Net.HTTP.HttpHeader("Accept", "application/vnd.progress+json").
            oReq:SetHeader(oHeader).

            oResponse = oClient:Execute(oReq).
            iStatus   = oResponse:StatusCode.

            IF iStatus = 200 THEN 
            DO:
                oBody = oResponse:Entity.
                IF TYPE-OF(oBody, Progress.Json.ObjectModel.JsonObject) THEN
                    oResult:Add(cSectionName, CAST(oBody, Progress.Json.ObjectModel.JsonObject)).
                ELSE
                    oResult:Add(cSectionName + "_error", "unexpected body type: " + oBody:GetClass():TypeName).
            END.
            ELSE
                oResult:Add(cSectionName + "_error", "HTTP " + STRING(iStatus)).
        END.

        RETURN CreateMcpResponseJson(id, oResult, false).


    END.

END CLASS.
