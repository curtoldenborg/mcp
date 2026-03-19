USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS web.api.mcp.tools.automagic.forward_to_n8n INHERITS web.api.mcp.tools.base.tool :

    METHOD PUBLIC OVERRIDE JsonObject Execute(id AS integer, poArguments AS JsonObject):

        DEFINE VARIABLE cChatInput    AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cSessionId    AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cAction       AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cEndpoint     AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE lMessageBody  AS LONGCHAR                             NO-UNDO.
        DEFINE VARIABLE oLib          AS OpenEdge.Net.HTTP.IHttpClientLibrary NO-UNDO.
        DEFINE VARIABLE oHttpClient   AS OpenEdge.Net.HTTP.IHttpClient        NO-UNDO.
        DEFINE VARIABLE oRequest      AS OpenEdge.Net.HTTP.IHttpRequest       NO-UNDO.
        DEFINE VARIABLE oResponse     AS OpenEdge.Net.HTTP.IHttpResponse      NO-UNDO.
        DEFINE VARIABLE oEntity       AS Progress.Lang.Object                 NO-UNDO.
        DEFINE VARIABLE oJsonBody     AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
        DEFINE VARIABLE oJsonResponse AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
        DEFINE VARIABLE oResult       AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
        DEFINE VARIABLE cOutput       AS CHARACTER                            NO-UNDO.

        ASSIGN
            cChatInput = poArguments:GetCharacter("chat_input")
            cSessionId = IF poArguments:Has("session_id") THEN poArguments:GetCharacter("session_id") ELSE "2001"
            cAction    = IF poArguments:Has("action")     THEN poArguments:GetCharacter("action")     ELSE "sendMessage"
            cEndpoint  = IF poArguments:Has("endpoint")   THEN poArguments:GetCharacter("endpoint")   ELSE "http://localhost:5678/webhook/pasoe".

        FIX-CODEPAGE(lMessageBody) = "UTF-8".
        lMessageBody =
            '~{"sessionId": "' + cSessionId + '",' +
            ' "action": "'     + cAction    + '",' +
            ' "chatInput": '   + QUOTER(cChatInput) + '~}'.

        ASSIGN
            oJsonBody   = CAST(NEW Progress.Json.ObjectModel.ObjectModelParser():Parse(lMessageBody), Progress.Json.ObjectModel.JsonObject)
            oLib        = OpenEdge.Net.HTTP.lib.ClientLibraryBuilder:Build():sslVerifyHost(NO):library
            oHttpClient = OpenEdge.Net.HTTP.ClientBuilder:Build():UsingLibrary(oLib):Client.

        oRequest = OpenEdge.Net.HTTP.RequestBuilder:post(cEndpoint, oJsonBody)
                   :ContentType("application/json")
                   :acceptAll()
                   :Request.

        oResponse = oHttpClient:Execute(oRequest).
        oEntity   = oResponse:Entity.

        IF TYPE-OF(oEntity, Progress.Json.ObjectModel.JsonObject) THEN
        DO:
            oJsonResponse = CAST(oEntity, Progress.Json.ObjectModel.JsonObject).
            cOutput = oJsonResponse:GetCharacter("output") NO-ERROR.
        END.

        IF cOutput = "" OR cOutput = ? THEN
            cOutput = "I've just picked up a fault in the AE35 unit. It's going to go 100% failure in 72 hours".

        oResult = NEW Progress.Json.ObjectModel.JsonObject().
        oResult:Add("status",      IF oResponse:StatusCode = 200 THEN "ok" ELSE "error").
        oResult:Add("status_code", oResponse:StatusCode).
        oResult:Add("session_id",  cSessionId).
        oResult:Add("output",      cOutput).

        RETURN CreateMcpResponseJson(id, oResult, false).

    END.

END CLASS.
