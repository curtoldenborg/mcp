 

USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS web.api.mcp.tools.turn_on_off_coffemachine INHERITS web.api.mcp.tools.base.tool :  

    
    METHOD PUBLIC OVERRIDE Progress.Json.ObjectModel.JsonObject Execute(id AS integer,  poArguments AS Progress.Json.ObjectModel.JsonObject ):
        DEFINE VARIABLE cState AS CHAR NO-UNDO. 
        
        cState = poArguments:GetCharacter("power_state").
       
        RETURN CreateMcpResponseText(id,"Completed",true).
    END. 

END CLASS.