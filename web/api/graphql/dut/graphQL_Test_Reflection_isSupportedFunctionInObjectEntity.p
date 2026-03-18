DEF VAR oObject AS web.api.graphql.querybuilder. 

DEFINE VARIABLE Params    AS Progress.Reflect.PARAMETER EXTENT NO-UNDO.                                                    

oObject = NEW web.api.graphql.querybuilder().

IF oObject:isSupportedFunctionInObjectEntity("orderaggregate", OUTPUT params)
  THEN 
        
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

