DEF VAR cStatement AS CHAR NO-UNDO. 
cStatement = '
~{
  user~(id: $userId) ~{
    id
    name
    email
    posts(filter: $filter) ~{
      id
      title
      content
      comments ~{
        id
        text
        author ~{
          id
          name
        ~}
      ~}
    ~}
  ~}
~} ' .


DEF VAR oGraph AS web.api.graphql.parse. 

oGraph = NEW web.api.graphql.parse(cStatement). 

message "" view-as alert-box.


/*
USING Progress.Json.ObjectModel.*.

DEF VAR Graphql_Query AS LONGCHAR NO-UNDO.

   DEFINE VARIABLE ojsonObject     AS JsonObject                 NO-UNDO.   
         DEFINE VARIABLE oParser      AS ObjectModelParser NO-UNDO.
         
FIX-CODEPAGE(Graphql_Query) = "utf-8".          

             REPLACE
 Graphql_Query = "<query 
                    < customers 
                     < id >  > >>".        
               {
  user(id: "1") 
  {
    id
    name
    email
    posts {
      id
      title
      content
    }
  }
}
query GetComplexData($userId: ID!, $filter: PostFilterInput) {
  user(id: $userId) {
    id
    name
    email
    posts(filter: $filter) {
      id
      title
      content
      comments {
        id
        text
        author {
          id
          name
        }
      }
    }
  }
}

 

 PROCEDURE parse:
    DEFINE INPUT PARAMETER gQuery AS CHAR        NO-UNDO.
    
    DEFINE VARIABLE myArray AS CHARACTER EXTENT NO-UNDO.
    DEFINE VARIABLE i       AS INTEGER   NO-UNDO.  
    DEFINE VARIABLE cText   AS CHARACTER NO-UNDO.  
     
    myArray = oJsonObject:GetNames().

    DO i = 1 TO EXTENT(myArray):
        cText = oJsonObject:getJsonText(myArray[i]).

        MESSAGE "Parent Object : " cParent SKIP(1) 
            "Property : " myArray[i] " : " cText SKIP(1)
            "Number of Properties in the object : " EXTENT(myArray) SKIP
            "Current Property : " i SKIP                
            VIEW-AS ALERT-BOX TITLE "ProcessObject" .
    END.
END.
*/
 
 /*        
// jsonObject = CAST(Graphql_Query, JsonObject) .
  oParser = NEW ObjectModelParser().
oJsonObject = CAST(oParser:Parse(Graphql_Query), JsonObject). 

          RUN   ProcessObject( oJsonObject).
 
   DEFINE VARIABLE cParent      AS CHARACTER         NO-UNDO.

PROCEDURE ProcessObject:
    DEFINE INPUT PARAMETER oJsonObject AS JsonObject        NO-UNDO.
    
    DEFINE VARIABLE myArray AS CHARACTER EXTENT NO-UNDO.
    DEFINE VARIABLE i       AS INTEGER   NO-UNDO.  
    DEFINE VARIABLE cText   AS CHARACTER NO-UNDO.  
     
    myArray = oJsonObject:GetNames().

    DO i = 1 TO EXTENT(myArray):
        cText = oJsonObject:getJsonText(myArray[i]).

        MESSAGE "Parent Object : " cParent SKIP(1) 
            "Property : " myArray[i] " : " cText SKIP(1)
            "Number of Properties in the object : " EXTENT(myArray) SKIP
            "Current Property : " i SKIP                
            VIEW-AS ALERT-BOX TITLE "ProcessObject" .
    END.
END.
*/
