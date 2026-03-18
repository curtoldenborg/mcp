 
 /*------------------------------------------------------------------------
    File        : databaseschema
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : colde
    Created     : Sat Mar 15 14:11:49 CET 2025
    Notes       : 
  ----------------------------------------------------------------------*/


USING Progress.Json.ObjectModel.*.
USING Progress.Lang.*.
USING OpenEdge.Net.*.
USING OpenEdge.Net.HTTP.*.
USING OpenEdge.Web.*.


BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS web.api.rest.databaseschema INHERITS OpenEdge.Web.WebHandler: 

   
    METHOD OVERRIDE PROTECTED INTEGER HandleGet(INPUT poRequest AS OpenEdge.Web.IWebRequest):
        DEFINE VARIABLE response       AS WebResponse                NO-UNDO.
        DEFINE VARIABLE oResponse AS OpenEdge.Net.HTTP.IHttpResponse NO-UNDO.
        DEFINE VARIABLE writer         AS WebResponseWriter          NO-UNDO.
           DEFINE VARIABLE oWriter   AS OpenEdge.Web.WebResponseWriter  NO-UNDO.
        DEFINE VARIABLE body           AS LONGCHAR                   NO-UNDO.
        DEFINE VARIABLE oBody     AS OpenEdge.Core.String            NO-UNDO.
        
        DEFINE VARIABLE accessType     AS CHARACTER                  NO-UNDO.
        DEFINE VARIABLE tableName      AS CHARACTER                  NO-UNDO.
        DEFINE VARIABLE queryString    AS CHARACTER                  NO-UNDO.        
        DEFINE VARIABLE filter         AS CHARACTER                  NO-UNDO.
        
        DEFINE VARIABLE hDataSet       AS HANDLE                     NO-UNDO.
        DEFINE VARIABLE jsonObject     AS JsonObject                 NO-UNDO.       
       
        // --- show header information curt 
        DEFINE VARIABLE oHeader        AS CLASS                      OpenEdge.Net.HTTP.HttpHeader NO-UNDO.
        DEFINE VARIABLE oHeaderArray   AS CLASS                      OpenEdge.Net.HTTP.HttpHeader EXTENT NO-UNDO.
        DEFINE VARIABLE iHeaderCount   AS INTEGER                    NO-UNDO.
        DEFINE VARIABLE i-loop         AS INTEGER                    NO-UNDO. 


        iHeaderCount = poRequest:GetHeaders(oHeaderArray).
        DO i-loop = 1 TO iHeadercount:
            LOG-MANAGER:WRITE-MESSAGE(CAPS(oHeaderArray[i-loop]:Name) + "=" + QUOTER(oHeaderArray[i-loop]:Value), "HEADER-INF").
        END.                     

        accessType  = poRequest:GetPathParameter("AccessType").
        tableName   = poRequest:GetPathParameter("TableName").
        queryString = poRequest:GetContextValue("QUERY_STRING").
       
        LOG-MANAGER:WRITE-MESSAGE("WebRequest.Method=" + quoter(poRequest:Method),"REQUEST").
        LOG-MANAGER:WRITE-MESSAGE("WebRequest.PathInfo=" + quoter(poRequest:pathInfo),"REQUEST").
        
        LOG-MANAGER:WRITE-MESSAGE("AccesssType="  + quoter(accessType), "REQUEST").
        LOG-MANAGER:WRITE-MESSAGE("TableName="    + quoter(tableName),  "REQUEST").
        LOG-MANAGER:WRITE-MESSAGE("Query_string=" + quoter(queryString),"REQUEST").
        
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
                    LOG-MANAGER:WRITE-MESSAGE( "DEBUG: cParam: " + cParam  + cName, "DEBUG").
                    IF cName = "filter" THEN 
                    DO:
                        filter = SUBSTRING(cParam, INDEX(queryString, "=") + 1).
                        IF filter > "" THEN 
                        DO:
                            filter = OpenEdge.Net.URI:Decode(filter).
                        END.
                        LOG-MANAGER:WRITE-MESSAGE("Filter=" + quoter(filter),"REQUEST").
                    END.
                END.
            END.
        END.
        
        LOG-MANAGER:WRITE-MESSAGE(accessType,"REQUEST" ).
        oresponse = NEW WebResponse().        
      
        DEFINE VARIABLE lBody      AS LONGCHAR NO-UNDO. 
        def var oSchemaDef AS web.api.graphql.schemadef. 
       
        RUN web\api\databaseschema.p (OUTPUT DATASET-HANDLE hDataset). 
        hDataset:WRITE-JSON("longchar",lBody, TRUE).
         
      /*  
        oschemadef = NEW web.api.graphql.schemadef(). 
        lBody = "~{"  + oSchemaDef:getSchema() +  "~}". 
      */
      
      /*
        hDataset = oSchemaDef:getDataSet(). 
        hDataset:WRITE-JSON("longchar",lBody, TRUE).
      */
        oBody = NEW OpenEdge.Core.String(lbody).   
             
        ASSIGN 
            oResponse:Entity        = oBody
            oResponse:ContentType   = 'text/plain':u
            oResponse:ContentLength = oBody:Size
            .
        
        ASSIGN 
            oWriter = NEW WebResponseWriter(oResponse).
        oWriter:Open().
        
        oWriter:Close().
        RETURN 0.
        
    END METHOD.
  
    
    
    METHOD OVERRIDE PROTECTED INTEGER HandlePost(INPUT poRequest AS OpenEdge.Web.IWebRequest):
        LOG-MANAGER:WRITE-MESSAGE("Method=" + quoter(poRequest:Method),"REQUEST").
        UNDO, THROW NEW Progress.Lang.AppError("METHOD NOT IMPLEMENTED").
    END. 
    
    /* PUT - save */
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


/*

  /*
        def var cDatbasetables as char. 
        FOR EACH _file WHERE _hidden = FALSE:
           cDatbasetables =  cDatbasetables + "," + _file-name. 
        END.
        
        oBody = NEW OpenEdge.Core.String(
                             'databasetables:'  + cDatbasetables
                           + '~r~n':u   /*CRLF */
                           ).
        
        */
 
 /*------------------------------------------------------------------------
    File        : apiHandler
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Curt
    Created     : Mon Mar 18 11:15:47 CET 2024
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OpenEdge.Web.WebResponseWriter.
USING OpenEdge.Net.HTTP.StatusCodeEnum.
USING OpenEdge.Web.WebHandler.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS apiHandler INHERITS WebHandler: 

    
        
    /*------------------------------------------------------------------------------
            Purpose: Handler for unsupported methods. The request being serviced and
                     an optional status code is returned. A zero or null value means 
                     this method will deal with all errors.                                                               
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    METHOD OVERRIDE PROTECTED INTEGER HandleNotAllowedMethod( INPUT poRequest AS OpenEdge.Web.IWebRequest ):
    
        /* Throwing an error from this method results in a 500/Internal Server Error response. 
        The web handler will attempt to log this exception.
        
        See the HandleGet method's comments on choosing a value to return from this method. */
            
        UNDO, THROW NEW Progress.Lang.AppError("METHOD NOT IMPLEMENTED").
    END METHOD.


    /*------------------------------------------------------------------------------
            Purpose: Handler for unknown methods. The request being serviced and an 
                     optional status code is returned. A zero or null value means 
                     this method will deal with all errors.                                                               
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    METHOD OVERRIDE PROTECTED INTEGER HandleNotImplemented( INPUT poRequest AS OpenEdge.Web.IWebRequest ):
    
        /* Throwing an error from this method results in a 500/Internal Server Error response. 
        The web handler will attempt to log this exception.
        
        See the HandleGet method's comments on choosing a value to return from this method. */  
        UNDO, THROW NEW Progress.Lang.AppError("METHOD NOT IMPLEMENTED").
    END METHOD.
    
    
    /*------------------------------------------------------------------------------
            Purpose: Default handler for the HTTP GET method. The request being 
                     serviced and an optional status code is returned. A zero or 
                     null value means this method will deal with all errors.                                                               
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    METHOD OVERRIDE PROTECTED INTEGER HandleGet( INPUT poRequest AS OpenEdge.Web.IWebRequest ):
    
    
        DEFINE VARIABLE oResponse AS OpenEdge.Net.HTTP.IHttpResponse NO-UNDO.
        DEFINE VARIABLE oWriter   AS OpenEdge.Web.WebResponseWriter  NO-UNDO.
        DEFINE VARIABLE oBody     AS OpenEdge.Core.String            NO-UNDO.
            
        /* The WebResponse body is a wrapper around an entire HTTP response message.
           It contains a status code and reason; headers; cookies and a message body.
           
           API-level doc for this and related classes can be found at
           https://documentation.progress.com/output/oehttpclient/      */
        ASSIGN 
            oResponse            = NEW OpenEdge.Web.WebResponse()
            oResponse:StatusCode = INTEGER(StatusCodeEnum:OK)
            .
            
            
            
        /* This body object can be a string or something else (JsonObject for instance) */               
        ASSIGN 
            oBody = NEW OpenEdge.Core.String(
                             'Hello Curt'
                           + '~r~n':u   /*CRLF */
                           + 'This message was returned by HandleGet in apiHandler.'
                           ).
        
        DEFINE VARIABLE employeeid AS INT      NO-UNDO. 
        DEFINE VARIABLE hDataset   AS HANDLE   NO-UNDO. 
        DEFINE VARIABLE lBody      AS LONGCHAR NO-UNDO. 
        RUN employee.p (employeeid, OUTPUT DATASET-HANDLE hDataset). 
        hDataset:WRITE-JSON("longchar",lBody, TRUE).
      
        oBody = NEW OpenEdge.Core.String(lbody).
             
        ASSIGN 
            oResponse:Entity        = oBody
            /* HTTP messages require a content type */
            oResponse:ContentType   = 'text/plain':u
            /* ContentLength is good too */
            oResponse:ContentLength = oBody:Size
            .
        
        /* The WebResponseWriter ensures that the status line and
           all headers are writted out before the message body/entity. */
        ASSIGN 
            oWriter = NEW WebResponseWriter(oResponse).
        oWriter:Open().
        
        /* Finish writing the response message */
        oWriter:Close().
        
        /* A response of 0 means that this handler will build the entire response;
           a non-zero value is mapped to a static handler in the webapp's /static/error folder.
           The mappings are maintained in the webapps's WEB-INF/web.xml 
           A predefined set of HTTP status codes is provided in the OpenEdge.Net.HTTP.StatusCodeEnum 
           enumeration */
        RETURN 0.
        
    END METHOD. 
    
    
    
    
END CLASS.
*/