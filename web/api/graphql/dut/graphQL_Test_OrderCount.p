DEF VAR oOrder AS web.api.graphql.entity.orderentity. 
DEFINE VARIABLE Params    AS Progress.Reflect.PARAMETER EXTENT NO-UNDO.                                                    

oOrder = NEW web.api.graphql.entity.orderentity().
params = oOrder:SIGNATURE('aggregate').


MESSAGE params[1]:datatype 
        params[1]:NAME
        params[1]:mode 
        VIEW-AS ALERT-BOX. 

        //MESSAGE oGraph:numberofrecords VIEW-AS ALERT-BOX. 

/*        
DEFINE VARIABLE myReflect   AS Progress.Lang.Class NO-UNDO.
myReflect = Progress.Lang.Class:GetClass("web.api.graphql.entity.orderentity").
myMethodExt = myReflect:GetMethods().
*/        

