 
/*------------------------------------------------------------------------
   File        : basetool
   Author(s)   : colde
 ----------------------------------------------------------------------*/

USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS web.api.mcp.tools.base.tool ABSTRACT: 

    // METHOD PUBLIC ABSTRACT longchar tooldefinition().
    
    /* Force all tools to implement their specific logic */
    METHOD PUBLIC ABSTRACT Progress.Json.ObjectModel.JsonObject Execute(
        INPUT id AS int, INPUT poArguments AS Progress.Json.ObjectModel.JsonObject ).

    
    METHOD PUBLIC longchar tooldefinition():

        DEFINE VARIABLE cJsonFile  AS CHAR                                        NO-UNDO. 
        DEFINE VARIABLE lcJsonText AS LONGCHAR                                    NO-UNDO. 
        DEFINE VARIABLE oParser    AS Progress.Json.ObjectModel.ObjectModelParser NO-UNDO.
        DEFINE VARIABLE oJson      AS Progress.Json.ObjectModel.JsonObject        NO-UNDO.

        cJsonFile = REPLACE(THIS-OBJECT:GetClass():TypeName, ".", "/") + ".json".
        
        IF SEARCH(cJsonFile) <> ? THEN 
        DO:
            FILE-INFO:FILE-NAME = cJsonFile.
            cJsonFile = FILE-INFO:FULL-PATHNAME.
            oParser = NEW Progress.Json.ObjectModel.ObjectModelParser().
            oJson = CAST(oParser:ParseFile(cJsonFile), Progress.Json.ObjectModel.JsonObject).
            oJson:Write(INPUT-OUTPUT lcJsonText, TRUE). 
        END. 
      
        RETURN lcJsonText.
        FINALLY:
            DELETE OBJECT oparser NO-ERROR. 
            DELETE OBJECT ojson NO-ERROR. 
        END. 
    END. 
    
    CONSTRUCTOR  tool ( ):
        web.api.mcp.tools:RegisterTool(this-object:getClass():typename, tooldefinition() ).
    END CONSTRUCTOR.
   
      
    /* Shared utility: standardized error response formatting */
    METHOD PUBLIC STATIC Progress.Json.ObjectModel.JsonObject CreateErrorResponse(
        INPUT piCode    AS INTEGER,
        INPUT pcMessage AS CHARACTER
        ):
        DEFINE VARIABLE oResponse AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
        oResponse = NEW Progress.Json.ObjectModel.JsonObject().
        oResponse:ADD("jsonrpc", "2.0").
        oResponse:ADD("error", NEW Progress.Json.ObjectModel.JsonObject()).
        oResponse:GetJsonObject("error"):ADD("code", piCode).
        oResponse:GetJsonObject("error"):ADD("message", pcMessage).
        RETURN oResponse.
    END METHOD.

    /* Shared utility: standardized error response formatting */
    METHOD PROTECTED Progress.Json.ObjectModel.JsonObject CreateSuccess(
        INPUT piCode    AS INTEGER,
        INPUT pcMessage AS CHARACTER
        ):
        DEFINE VARIABLE oResponse AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
        oResponse = NEW Progress.Json.ObjectModel.JsonObject().
        oResponse:ADD("jsonrpc", "2.0").
        oResponse:ADD("error", NEW Progress.Json.ObjectModel.JsonObject()).
        oResponse:GetJsonObject("error"):ADD("code", piCode).
        oResponse:GetJsonObject("error"):ADD("message", pcMessage).
        RETURN oResponse.
    END METHOD.


    METHOD PUBLIC Progress.Json.ObjectModel.JsonObject CreateMcpResponseText(
        INPUT piId      AS INTEGER,
        INPUT pcMessage AS LONGCHAR,
        INPUT plIsError AS LOGICAL
        ):
        DEFINE VARIABLE oResponse AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
        DEFINE VARIABLE oResult   AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
        DEFINE VARIABLE oContent  AS Progress.Json.ObjectModel.JsonArray  NO-UNDO.
        DEFINE VARIABLE oItem     AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
    
        oResponse = NEW Progress.Json.ObjectModel.JsonObject().
        oResponse:Add("jsonrpc", "2.0").
        oResponse:Add("id", piId).
    
        oResult  = NEW Progress.Json.ObjectModel.JsonObject().
        oContent = NEW Progress.Json.ObjectModel.JsonArray().
        oItem    = NEW Progress.Json.ObjectModel.JsonObject().
    
        oItem:Add("type", "text").
        oItem:Add("text", pcMessage).
        
        oContent:Add(oItem).
        oResult:Add("content", oContent).
        oResult:Add("isError", plIsError).
        oResponse:Add("result", oResult).
    
        RETURN oResponse.
        
    END METHOD.


 METHOD PUBLIC static Progress.Json.ObjectModel.JsonObject CreateMcpResponseTextIsError(
        INPUT piId      AS INTEGER,
        INPUT pcMessage AS LONGCHAR):
        DEF VAR  plIsError AS LOGICAL INIT TRUE. 
       
        DEFINE VARIABLE oResponse AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
        DEFINE VARIABLE oResult   AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
        DEFINE VARIABLE oContent  AS Progress.Json.ObjectModel.JsonArray  NO-UNDO.
        DEFINE VARIABLE oItem     AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
    
        oResponse = NEW Progress.Json.ObjectModel.JsonObject().
        oResponse:Add("jsonrpc", "2.0").
        oResponse:Add("id", piId).
    
        oResult  = NEW Progress.Json.ObjectModel.JsonObject().
        oContent = NEW Progress.Json.ObjectModel.JsonArray().
        oItem    = NEW Progress.Json.ObjectModel.JsonObject().
    
        oItem:Add("type", "text").
        oItem:Add("text", pcMessage).
        
        oContent:Add(oItem).
        oResult:Add("content", oContent).
        oResult:Add("isError", plIsError).
        oResponse:Add("result", oResult).
    
        RETURN oResponse.
        
    END METHOD.


    METHOD PUBLIC Progress.Json.ObjectModel.JsonObject CreateMcpResponseJson(
        INPUT piId      AS INTEGER,
        /* Accept a JsonArray/Object instead of just a string */
        INPUT poData    AS Progress.Json.ObjectModel.JsonArray, 
        INPUT plIsError AS LOGICAL
        ):
        DEFINE VARIABLE oResponse AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
        DEFINE VARIABLE oResult   AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
        DEFINE VARIABLE oContent  AS Progress.Json.ObjectModel.JsonArray  NO-UNDO.
        DEFINE VARIABLE oItem     AS Progress.Json.ObjectModel.JsonObject NO-UNDO.

        oResponse = NEW Progress.Json.ObjectModel.JsonObject().
        oResponse:Add("jsonrpc", "2.0").
        oResponse:Add("id", piId).

        oResult  = NEW Progress.Json.ObjectModel.JsonObject().
        oContent = NEW Progress.Json.ObjectModel.JsonArray().
        oItem    = NEW Progress.Json.ObjectModel.JsonObject().

        /* The 'text' property is for strings; use 'json' for structured data */
        
        oItem:Add("type", "text"). 
        oItem:Add("text", poData:GetJsonText()).
    
        oContent:Add(oItem).
        oResult:Add("content", oContent).
        oResult:Add("isError", plIsError).

        oResponse:Add("result", oResult).

        RETURN oResponse.
    END METHOD.

    METHOD PUBLIC Progress.Json.ObjectModel.JsonObject CreateMcpResponseJson(
        INPUT piId      AS INTEGER,
        /* Accept a JsonArray/Object instead of just a string */
        INPUT poData    AS Progress.Json.ObjectModel.JsonObject, 
        INPUT plIsError AS LOGICAL
        ):
        DEFINE VARIABLE oResponse AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
        DEFINE VARIABLE oResult   AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
        DEFINE VARIABLE oContent  AS Progress.Json.ObjectModel.JsonArray  NO-UNDO.
        DEFINE VARIABLE oItem     AS Progress.Json.ObjectModel.JsonObject NO-UNDO.

        oResponse = NEW Progress.Json.ObjectModel.JsonObject().
        oResponse:Add("jsonrpc", "2.0").
        oResponse:Add("id", piId).

        oResult  = NEW Progress.Json.ObjectModel.JsonObject().
        oContent = NEW Progress.Json.ObjectModel.JsonArray().
        oItem    = NEW Progress.Json.ObjectModel.JsonObject().

        /* The 'text' property is for strings; use 'json' for structured data */
        
        oItem:Add("type", "text"). 
        oItem:Add("text", poData:GetJsonText()).
    
        oContent:Add(oItem).
        oResult:Add("content", oContent).
        oResult:Add("isError", plIsError).

        oResponse:Add("result", oResult).

        RETURN oResponse.
    END METHOD.



END CLASS.