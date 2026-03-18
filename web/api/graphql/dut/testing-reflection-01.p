
USING Progress.Reflect.*.
USING Progress.Lang.Class.*.

LOG-MANAGER:LOGFILE-NAME = "C:\temp\log2.txt".   
  
DEFINE VARIABLE myMethodExt AS METHOD EXTENT NO-UNDO.
DEFINE VARIABLE xxparams    AS Progress.Reflect.PARAMETER EXTENT NO-UNDO.

DEFINE VARIABLE myReflect   AS Progress.Lang.Class NO-UNDO.

myReflect = Progress.Lang.Class:GetClass("web.api.graphql.entity.orderentity").
myMethodExt = myReflect:GetMethods().

xxparams = myMethodExt[2]:GetParameters().

MESSAGE GET-CLASS() myMethodExt[2] xxparams[2] xxparams[1]VIEW-AS ALERT-BOX.
    

/*    
DEFINE VARIABLE poParamList AS Progress.Lang.Parameterlist NO-UNDO.
DEFINE VARIABLE methodHandle AS Progress.Reflect.Method NO-UNDO.

/*
DEFINE VARIABLE poParamList AS Progress.Lang.Parameterlist NO-UNDO.
 poParamList = NEW Progress.Lang.Parameterlist(1).
 poParamList:SetParameter(1,'CHARACTER','INPUT','SS').
 //poParamList:setParameter(1,?).
 
   //  oClass = Progress.Lang.Class:GetClass(pcClass).                                          
*/                         
 
DEFINE VARIABLE myMethodExt AS METHOD EXTENT NO-UNDO.
DEFINE VARIABLE myMethod    AS METHOD NO-UNDO.
DEFINE VARIABLE myReflect   AS Progress.Lang.Class NO-UNDO.
DEFINE VARIABLE xxparams    AS Progress.Reflect.PARAMETER EXTENT NO-UNDO.

// access the class
myReflect = Progress.Lang.Class:GetClass("web.api.graphql.entity.orderentity").
// create a parameter list
myParams = NEW Progress.Lang.ParameterList(1).
// set the parameter list for myMethod1
myParams:SetParameter(1, "INTEGER", "INPUT", 1).
// get an array of all methods in the class
myMethodExt = myReflect:GetMethods().
// show the signature of the first entry in the array

xxparams = myMethodExt[2]:GetParameters().
MESSAGE myMethodExt[2] xxparams[2] xxparams[1]VIEW-AS ALERT-BOX.
// Get the signature of one method (myMethod1)
myMethod = myReflect:GetMethod("aggregate", myParams).
*/

/*    
    
    
    
    
    
     
    /*
      DEFINE VARIABLE entitypath AS CHARACTER INIT 'web.api.graphql.entity.' NO-UNDO. 
      DEFINE VARIABLE dynObject   AS web.api.graphql.entity.IBusinessEntity NO-UNDO.
      dynObject = DYNAMIC-NEW entitypath + QueryTable.tablenameAlias + 'entity' () 
      SIGNATURE 
      */

 
 
DEF VAR objclass AS PROGRESS.lang.OBJECT. 
 
objClass = DYNAMIC-NEW 'web.api.graphql.entity.orderentity' ().


DEFINE VARIABLE poParamList AS Progress.Lang.Parameterlist NO-UNDO.
DEFINE VARIABLE methodHandle AS Progress.Reflect.Method NO-UNDO.

/*
DEFINE VARIABLE poParamList AS Progress.Lang.Parameterlist NO-UNDO.
 poParamList = NEW Progress.Lang.Parameterlist(1).
 poParamList:SetParameter(1,'CHARACTER','INPUT','SS').
 //poParamList:setParameter(1,?).
 
   //  oClass = Progress.Lang.Class:GetClass(pcClass).                                          
*/                         
 
DEFINE VARIABLE myMethodExt AS METHOD EXTENT NO-UNDO.
DEFINE VARIABLE myMethod    AS METHOD NO-UNDO.
DEFINE VARIABLE myReflect   AS Progress.Lang.Class NO-UNDO.
DEFINE VARIABLE myParams    AS Progress.Lang.ParameterList NO-UNDO.
DEFINE VARIABLE xxparams    AS Progress.Reflect.PARAMETER EXTENT NO-UNDO.

// access the class
myReflect = Progress.Lang.Class:GetClass("web.api.graphql.entity.orderentity").
// create a parameter list
myParams = NEW Progress.Lang.ParameterList(1).
// set the parameter list for myMethod1
myParams:SetParameter(1, "INTEGER", "INPUT", 1).
// get an array of all methods in the class
myMethodExt = myReflect:GetMethods().
// show the signature of the first entry in the array

xxparams = myMethodExt[2]:GetParameters().
MESSAGE myMethodExt[2] xxparams[2] xxparams[1]VIEW-AS ALERT-BOX.
// Get the signature of one method (myMethod1)
myMethod = myReflect:GetMethod("aggregate", myParams).
         
         
// show the signature of that method
MESSAGE myMethod VIEW-AS ALERT-BOX.
MESSAGE "Done" VIEW-AS ALERT-BOX.

*/

/* 
 methodHandle = objClass:GetClass():GetMethod('aggregate',poParamList).
 methodHandle = objClass:GetClass():GetMethod('aggregate',?).
 methodHandle:GetSignature('fsdf').
 */
 //methodHandle = objClass:GetClass():GetMethod("aggregate").
 
 
 
// hQueryResultDataSet:WRITE-JSON("FILE","C:\temp\dataset-result.txt", TRUE).
     /*
     
     reflection 
     
         DEFINE VARIABLE classHandle AS Progress.Lang.Class NO-UNDO.
DEFINE VARIABLE methodHandle AS Progress.Reflect.Method NO-UNDO.
DEFINE VARIABLE methodName AS CHARACTER NO-UNDO.

/* Get the class handle for the object */
classHandle = Progress.Lang.Class:GetClass("web.api.graphql.entity.orderentity").
methodHandle = classHandle:Aggregate().
       */
 /*    
/* Get the method handle for a specific method */
methodHandle = classHandle:GetMethod("aggregate").

/* Get the method signature */
methodName = methodHandle:GetSignature().

MESSAGE "Method Signature:" methodName VIEW-AS ALERT-BOX.
       */
 // oGraph:BuildResultDataset(). 
          /*
{
  "graphql_query": "query { customers { edges { node { id custNum name address city state postalCode country phone salesRep { id name } createdAt updatedAt } } } }"
}
            */          /*
            
                     USING Progress.Reflect.*.
USING Progress.Lang.Class.*.
/* ***************************  Definitions  ************************** */

BLOCK-LEVEL ON ERROR UNDO, THROW.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
DEFINE VARIABLE myMethodExt AS METHOD EXTENT NO-UNDO.
DEFINE VARIABLE myMethod AS METHOD NO-UNDO.
DEFINE VARIABLE myReflect AS Progress.Lang.Class NO-UNDO.
DEFINE VARIABLE myParams AS Progress.Lang.ParameterList NO-UNDO.

// access the class
myReflect = Progress.Lang.Class:GetClass("jzwClass1").
// create a parameter list
myParams = NEW Progress.Lang.ParameterList(1).
// set the parameter list for myMethod1
myParams:SetParameter(1, "INTEGER", "INPUT", 1).
// get an array of all methods in the class
myMethodExt = myReflect:GetMethods().
// show the signature of the first entry in the array
MESSAGE myMethodExt[1]  VIEW-AS ALERT-BOX.
// Get the signature of one method (myMethod1)
myMethod = myReflect:GetMethod("myMethod1", myParams).
// show the signature of that method
MESSAGE myMethod VIEW-AS ALERT-BOX.
MESSAGE "Done" VIEW-AS ALERT-BOX.
*/
