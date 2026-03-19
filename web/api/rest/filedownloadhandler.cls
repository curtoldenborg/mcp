BLOCK-LEVEL ON ERROR UNDO, THROW.

USING Progress.Lang.*.
USING OpenEdge.Web.WebResponseWriter.
USING OpenEdge.Web.WebHandler.
USING OpenEdge.Net.HTTP.StatusCodeEnum.
USING OpenEdge.Web.WebResponse.

CLASS web.api.rest.filedownloadhandler INHERITS OpenEdge.Web.WebHandler:

    METHOD OVERRIDE PROTECTED INTEGER HandleGet(INPUT poRequest AS OpenEdge.Web.IWebRequest):
        DEFINE VARIABLE oResponse AS OpenEdge.Net.HTTP.IHttpResponse NO-UNDO.
        DEFINE VARIABLE oWriter   AS OpenEdge.Web.WebResponseWriter NO-UNDO.
        DEFINE VARIABLE mFile     AS MEMPTR                         NO-UNDO.
        DEFINE VARIABLE cFileName AS CHARACTER                      NO-UNDO.
        DEFINE VARIABLE cFilePath AS CHARACTER                      NO-UNDO.
        DEFINE VARIABLE oDispositionHeader AS OpenEdge.Net.HTTP.HttpHeader NO-UNDO.

        /* 1. Get the filename from the URI query parameter (?file=...) */
        ASSIGN 
           cFileName = poRequest:URI:GetQueryValue("file").
            /* IMPORTANT: Sanitize this path in production to prevent directory traversal! */
            cFilePath = system.config:projectpath + "resources\documents\" + cFileName.

        /* 2. Check if file exists */
        FILE-INFO:FILE-NAME = cFilePath.
        IF FILE-INFO:FULL-PATHNAME = ? THEN 
        DO:
            ASSIGN 
                oResponse = NEW WebResponse().
            oResponse:StatusCode = INTEGER(StatusCodeEnum:NotFound).
            oResponse:Entity     = NEW OpenEdge.Core.String("File not found.").
        END.
        ELSE 
        DO:
            /* 3. Load file into a MEMPTR */
            COPY-LOB FROM FILE cFilePath TO mFile.

            /* 4. Prepare the Binary Response */
            ASSIGN 
                oResponse             = NEW WebResponse()
                oResponse:StatusCode  = INTEGER(StatusCodeEnum:OK)
                oResponse:ContentType = "application/vnd.openxmlformats-officedocument.presentationml.presentation"
                oResponse:Entity      = NEW OpenEdge.Core.Memptr(mFile).

            /* 5. Tell the browser/client to treat it as a download */

            /* 1. Create the header object with the name */
            oDispositionHeader = NEW OpenEdge.Net.HTTP.HttpHeader("Content-Disposition").
            
            /* 2. Set the value (no QUOTER, just the string) */
            oDispositionHeader:Value = "attachment; filename=" + cFileName.
            
            /* 3. Pass the object to SetHeader */
            oResponse:SetHeader(oDispositionHeader).

        END.

        /* 6. Write and Close the Stream */
        ASSIGN 
            oWriter = NEW WebResponseWriter(oResponse).
            
        oWriter:Open().
        oWriter:Close().

        /* 7. Clean up memory immediately */
        IF GET-SIZE(mFile) > 0 THEN SET-SIZE(mFile) = 0.

        RETURN 0.
    END METHOD.
    
    METHOD OVERRIDE PROTECTED INTEGER HandlePost(INPUT poRequest AS OpenEdge.Web.IWebRequest):
        LOG-MANAGER:WRITE-MESSAGE("Method=" + quoter(poRequest:Method),"REQUEST").
        UNDO, THROW NEW Progress.Lang.AppError("METHOD NOT IMPLEMENTED").
    END. 
    
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
