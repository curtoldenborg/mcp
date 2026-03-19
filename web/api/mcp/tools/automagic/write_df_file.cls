USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS web.api.mcp.tools.automagic.write_df_file INHERITS web.api.mcp.tools.base.tool :

    METHOD PUBLIC OVERRIDE JsonObject Execute(id AS integer, poArguments AS JsonObject):

        DEFINE VARIABLE cContent  AS LONGCHAR                             NO-UNDO.
        DEFINE VARIABLE cFilePath AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cFileName AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cBasePath AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE oResult   AS Progress.Json.ObjectModel.JsonObject NO-UNDO.

        FIX-CODEPAGE(cContent) = "UTF-8".

        cFileName = poArguments:GetCharacter("file_name").
        cContent  = poArguments:GetCharacter("content").

        cBasePath = "C:" + CHR(92) + "projects" + CHR(92) + "mcp" + CHR(92) + "mcp" + CHR(92)
                  + "web" + CHR(92) + "api" + CHR(92) + "mcp" + CHR(92) + "tools" + CHR(92)
                  + "automagic" + CHR(92) + "df_files" + CHR(92).

        cFilePath = cBasePath + cFileName.

        oResult = NEW Progress.Json.ObjectModel.JsonObject().
        oResult:Add("file_path", cFilePath).

        COPY-LOB FROM cContent TO FILE cFilePath.

        oResult:Add("status",  "ok").
        oResult:Add("message", "File written: " + cFilePath).

        RETURN CreateMcpResponseJson(id, oResult, false).

        CATCH e AS Progress.Lang.Error:
            oResult:Add("status",  "error").
            oResult:Add("message", e:GetMessage(1)).
            RETURN CreateMcpResponseJson(id, oResult, false).
        END CATCH.

    END.

END CLASS.
