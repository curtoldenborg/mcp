 
 /*------------------------------------------------------------------------
    File        : executesqlquery
    Author(s)   : colde
    Created     : Sat Mar 17 14:11:49 CET 2025
  ----------------------------------------------------------------------*/


USING Progress.Json.ObjectModel.*.
USING Progress.Lang.*.
USING OpenEdge.Net.*.
USING OpenEdge.Net.HTTP.*.
USING OpenEdge.Web.*.


BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS web.api.rest.executesqlquery INHERITS OpenEdge.Web.WebHandler: 

    
    METHOD OVERRIDE PROTECTED INTEGER HandlePost(INPUT poRequest AS OpenEdge.Web.IWebRequest):
        DEFINE VARIABLE response       AS WebResponse                NO-UNDO.
        DEFINE VARIABLE oResponse AS OpenEdge.Net.HTTP.IHttpResponse NO-UNDO.
        DEFINE VARIABLE writer         AS WebResponseWriter          NO-UNDO.
        DEFINE VARIABLE oWriter   AS OpenEdge.Web.WebResponseWriter  NO-UNDO.
        DEFINE VARIABLE oBody     AS OpenEdge.Core.String            NO-UNDO.
        
        DEFINE VARIABLE accessType     AS CHARACTER                  NO-UNDO.
        DEFINE VARIABLE queryString    AS CHARACTER                  NO-UNDO.        
        DEFINE VARIABLE filter         AS CHARACTER                  NO-UNDO.
        DEFINE VARIABLE cquery      AS CHAR INIT "select * from customer" NO-UNDO. 
        DEFINE VARIABLE lBody      AS LONGCHAR NO-UNDO. 
        define variable jsonRequest as jsonobject no-undo. 
       
        DEFINE VARIABLE hDataSet       AS HANDLE                     NO-UNDO.
        DEFINE VARIABLE jsonObject     AS JsonObject                 NO-UNDO.       
       
        // --- show header information curt 
        DEFINE VARIABLE oHeader        AS CLASS                      OpenEdge.Net.HTTP.HttpHeader NO-UNDO.
        DEFINE VARIABLE oHeaderArray   AS CLASS                      OpenEdge.Net.HTTP.HttpHeader EXTENT NO-UNDO.
        DEFINE VARIABLE iHeaderCount   AS INTEGER                    NO-UNDO.
        DEFINE VARIABLE i-loop         AS INTEGER                    NO-UNDO. 


        iHeaderCount = poRequest:GetHeaders(oHeaderArray).
        DO i-loop = 1 TO iHeadercount:
        //    LOG-MANAGER:WRITE-MESSAGE(CAPS(oHeaderArray[i-loop]:Name) + "=" + QUOTER(oHeaderArray[i-loop]:Value), "HEADER-INF").
        END.                     

        accessType  = poRequest:GetPathParameter("AccessType").
        queryString = poRequest:GetContextValue("QUERY_STRING").
       
     //   LOG-MANAGER:WRITE-MESSAGE("WebRequest.Method=" + quoter(poRequest:Method),"REQUEST").
     //   LOG-MANAGER:WRITE-MESSAGE("WebRequest.PathInfo=" + quoter(poRequest:pathInfo),"REQUEST").
     //   LOG-MANAGER:WRITE-MESSAGE("AccesssType="  + quoter(accessType), "REQUEST").
     //   LOG-MANAGER:WRITE-MESSAGE("Query_string=" + quoter(queryString),"REQUEST").
        
     //    https://documentation.progress.com/output/oehttpclient/117/index.html?OpenEdge.Web.WebRequest.html 
       
        IF queryString > "" THEN 
        DO:
            DEFINE VARIABLE cParam AS CHARACTER NO-UNDO.
            DEFINE VARIABLE i      AS INTEGER   NO-UNDO.
            DEFINE VARIABLE cName  AS CHARACTER NO-UNDO.
            DEFINE VARIABLE idx    AS INTEGER   NO-UNDO.
            
            DO i = 1 TO NUM-ENTRIES(queryString, "&"):
                cParam = ENTRY(i, queryString, "&").
                idx = INDEX(cParam, "=").
                IF idx > 0 THEN 
                DO:
                    cName = SUBSTRING(cParam, 1, idx - 1).
         //           LOG-MANAGER:WRITE-MESSAGE( "DEBUG: cParam: " + cParam  + cName, "DEBUG").
                    IF cName = "filter" THEN 
                    DO:
                        filter = SUBSTRING(cParam, INDEX(queryString, "=") + 1).
                        IF filter > "" THEN 
                        DO:
                            filter = OpenEdge.Net.URI:Decode(filter).
                        END.
       //                 LOG-MANAGER:WRITE-MESSAGE("Filter=" + quoter(filter),"REQUEST").
                    END.
                END.
            END.
        END.
        
        
        IF TYPE-OF(poRequest:Entity, JsonObject) THEN 
        DO:
              jsonRequest = CAST(poRequest:Entity, JsonObject) .
              jsonRequest:WriteFile("c:\temp\sql_query.json", TRUE).
              cQuery = jsonRequest:getCharacter("sql_query") no-error.
        END.
       
        LOG-MANAGER:WRITE-MESSAGE( "query: " + cquery,"DEBUG"). 
     //   LOG-MANAGER:WRITE-MESSAGE(accessType,"REQUEST" ).
    
        oresponse = NEW WebResponse().        
        
        RUN web\api\executesqlquery.p (INPUT cQuery, OUTPUT DATASET-HANDLE hDataset). 
        hDataset:WRITE-JSON("longchar",lBody, TRUE).
      
        oBody = NEW OpenEdge.Core.String(lbody).   
             
        ASSIGN 
            oResponse:Entity        = oBody
            oResponse:ContentType   = 'application/json'
            oResponse:ContentLength = oBody:Size
            .
        
        oWriter = NEW WebResponseWriter(oResponse).
        oWriter:Open().
        oWriter:Close().
        RETURN 0.
    END. 

    METHOD OVERRIDE PROTECTED INTEGER HandleGet(INPUT poRequest AS OpenEdge.Web.IWebRequest):
        LOG-MANAGER:WRITE-MESSAGE("Method=" + quoter(poRequest:Method),"REQUEST").
        UNDO, THROW NEW Progress.Lang.AppError("METHOD NOT IMPLEMENTED").
    END METHOD.
  
    METHOD OVERRIDE PROTECTED INTEGER HandlePut(INPUT poRequest AS OpenEdge.Web.IWebRequest):
        LOG-MANAGER:WRITE-MESSAGE("Method=" + quoter(poRequest:Method),"REQUEST").
        UNDO, THROW NEW Progress.Lang.AppError("METHOD NOT IMPLEMENTED").
    END. 

    METHOD OVERRIDE PROTECTED INTEGER HandleNotAllowedMethod( INPUT poRequest AS OpenEdge.Web.IWebRequest ):
        UNDO, THROW NEW Progress.Lang.AppError("METHOD NOT IMPLEMENTED").
    END METHOD.

    METHOD OVERRIDE PROTECTED INTEGER HandleNotImplemented( INPUT poRequest AS OpenEdge.Web.IWebRequest ):
        UNDO, THROW NEW Progress.Lang.AppError("METHOD NOT IMPLEMENTED").
    END METHOD.    
    
END CLASS.

