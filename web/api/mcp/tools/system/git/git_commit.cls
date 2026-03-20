USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS web.api.mcp.tools.system.git.git_commit INHERITS web.api.mcp.tools.base.tool :

    METHOD PUBLIC OVERRIDE JsonObject Execute(id AS integer, poArguments AS JsonObject):

        DEFINE VARIABLE cRepo    AS CHARACTER                            NO-UNDO INITIAL "C:\projects\mcp\mcp".
        DEFINE VARIABLE cMessage AS CHARACTER                            NO-UNDO INITIAL "Auto commit via MCP".
        DEFINE VARIABLE cAction  AS CHARACTER                            NO-UNDO INITIAL "status".
        DEFINE VARIABLE cBranch  AS CHARACTER                            NO-UNDO INITIAL "".
        DEFINE VARIABLE cGit     AS CHARACTER                            NO-UNDO INITIAL "C:\Program Files\Git\bin\git.exe".
        DEFINE VARIABLE cTmpOut  AS CHARACTER                            NO-UNDO INITIAL "C:\temp\git_out.txt".
        DEFINE VARIABLE cCmd     AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cOutput  AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE hFile    AS LONGCHAR                             NO-UNDO.
        DEFINE VARIABLE oResult  AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
        DEFINE VARIABLE cGitCmd  AS CHARACTER                            NO-UNDO.

        IF poArguments:Has("repo")    THEN 
        DO: 
            cRepo    = poArguments:GetCharacter("repo").    
            IF cRepo = ? OR cRepo = "" THEN cRepo = "C:\projects\mcp\mcp". 
        END.
        IF poArguments:Has("message") THEN 
        DO: 
            cMessage = poArguments:GetCharacter("message"). 
            IF cMessage = ? OR cMessage = "" THEN cMessage = "Auto commit via MCP". 
        END.
        IF poArguments:Has("action")  THEN 
        DO: 
            cAction  = poArguments:GetCharacter("action").  
            IF cAction = ? OR cAction = "" THEN cAction = "status". 
        END.
        IF poArguments:Has("branch")  THEN 
        DO: 
            cBranch  = poArguments:GetCharacter("branch").  
            IF cBranch = ? THEN cBranch = "". 
        END.

        /* Full path to git so PASOE PATH doesnt matter */
        cGitCmd = CHR(34) + cGit + CHR(34).

        oResult = NEW Progress.Json.ObjectModel.JsonObject().
        oResult:Add("action",    cAction).
        oResult:Add("repo",      cRepo).
        oResult:Add("timestamp", STRING(NOW)).

        CASE cAction:
            WHEN "status" THEN
                cCmd = "cmd /c cd /d " + CHR(34) + cRepo + CHR(34) + " && " + cGitCmd + " status".
            WHEN "add" THEN
                cCmd = "cmd /c cd /d " + CHR(34) + cRepo + CHR(34) + " && " + cGitCmd + " add -A".
            WHEN "commit" THEN
                cCmd = "cmd /c cd /d " + CHR(34) + cRepo + CHR(34) + " && " + cGitCmd + " add -A && " + cGitCmd + " commit -m " + CHR(34) + cMessage + CHR(34).
            WHEN "push" THEN
                cCmd = "cmd /c cd /d " + CHR(34) + cRepo + CHR(34) + " && " + cGitCmd + " push".
            WHEN "pull" THEN
                cCmd = "cmd /c cd /d " + CHR(34) + cRepo + CHR(34) + " && " + cGitCmd + " pull".
            WHEN "log" THEN
                cCmd = "cmd /c cd /d " + CHR(34) + cRepo + CHR(34) + " && " + cGitCmd + " log --oneline -20".
            WHEN "diff" THEN
                cCmd = "cmd /c cd /d " + CHR(34) + cRepo + CHR(34) + " && " + cGitCmd + " diff --stat".
            WHEN "branch" THEN
                cCmd = "cmd /c cd /d " + CHR(34) + cRepo + CHR(34) + " && " + cGitCmd + " branch -a".
            WHEN "checkout" THEN
                cCmd = "cmd /c cd /d " + CHR(34) + cRepo + CHR(34) + " && " + cGitCmd + " checkout " + cBranch.
            WHEN "full_checkin" THEN
                cCmd = "cmd /c cd /d " + CHR(34) + cRepo + CHR(34) + " && " + cGitCmd + " add -A && " + cGitCmd + " commit -m " + CHR(34) + cMessage + CHR(34) + " && " + cGitCmd + " push".
            OTHERWISE
            cCmd = "cmd /c cd /d " + CHR(34) + cRepo + CHR(34) + " && " + cGitCmd + " status".
        END CASE.

        oResult:Add("command", cAction + " on " + cRepo).
        OS-COMMAND SILENT VALUE(cCmd + " 1> " + CHR(34) + cTmpOut + CHR(34) + " 2>&1").

        IF SEARCH(cTmpOut) <> ? THEN 
        DO:
            COPY-LOB FROM FILE cTmpOut TO hFile.
            cOutput = TRIM(STRING(hFile)).
            OS-DELETE VALUE(cTmpOut).
        END.
        ELSE
            cOutput = "(no output captured)".

        IF LENGTH(cOutput) > 3000 THEN
            cOutput = SUBSTRING(cOutput, 1, 3000) + "...(truncated)".

        oResult:Add("output",    cOutput).
        oResult:Add("exit_code", OS-ERROR).
        oResult:Add("status",    IF OS-ERROR = 0 THEN "success" ELSE "error").

        RETURN CreateMcpResponseJson(id, oResult, false).

    END.

END CLASS.
