USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS web.api.mcp.tools.automagic.manage_scheduled_tasks INHERITS web.api.mcp.tools.base.tool :

    DEFINE TEMP-TABLE ttTask NO-UNDO
        FIELD task_id        AS INTEGER
        FIELD task_name      AS CHARACTER FORMAT "x(80)"
        FIELD task_type      AS CHARACTER FORMAT "x(40)"
        FIELD task_status    AS CHARACTER FORMAT "x(20)"
        FIELD scheduled_time AS CHARACTER FORMAT "x(40)"
        FIELD tool_name      AS CHARACTER FORMAT "x(80)"
        FIELD notify_email   AS CHARACTER FORMAT "x(200)"
        FIELD recurrence     AS CHARACTER FORMAT "x(20)".


    METHOD PUBLIC OVERRIDE JsonObject Execute(id AS integer, poArguments AS JsonObject):

        DEFINE VARIABLE cAction        AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cTaskName      AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cTaskType      AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cToolName      AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cToolArguments AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cChatInput     AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cScheduledTime AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cRecurrence    AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE iRecInterval   AS INTEGER                              NO-UNDO.
        DEFINE VARIABLE cNotifyEmail   AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cNotifySubject AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cEndpoint      AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE cStatus        AS CHARACTER                            NO-UNDO.
        DEFINE VARIABLE iTaskId        AS INTEGER                              NO-UNDO.
        DEFINE VARIABLE iMaxRetries    AS INTEGER                              NO-UNDO.
        DEFINE VARIABLE iNextId        AS INTEGER                              NO-UNDO.
        DEFINE VARIABLE dtScheduled    AS DATETIME-TZ                          NO-UNDO.
        DEFINE VARIABLE oResult        AS Progress.Json.ObjectModel.JsonObject NO-UNDO.
        DEFINE VARIABLE oList          AS Progress.Json.ObjectModel.JsonArray  NO-UNDO.

        
        cAction = IF poArguments:Has("action") THEN poArguments:GetCharacter("action") ELSE "list".
        oResult = NEW Progress.Json.ObjectModel.JsonObject().

        CASE cAction:

            WHEN "list" THEN
                DO:
                    cStatus = IF poArguments:Has("status") THEN poArguments:GetCharacter("status") ELSE "PENDING".
                    oList   = NEW Progress.Json.ObjectModel.JsonArray().

                    IF cStatus = "ALL" THEN
                    DO:
                        FOR EACH mcp_scheduled_task NO-LOCK BY mcp_scheduled_task.scheduled_time:
                            CREATE ttTask.
                            ASSIGN
                                ttTask.task_id        = mcp_scheduled_task.task_id
                                ttTask.task_name      = mcp_scheduled_task.task_name
                                ttTask.task_type      = mcp_scheduled_task.task_type
                                ttTask.task_status    = mcp_scheduled_task.task_status
                                ttTask.scheduled_time = STRING(mcp_scheduled_task.scheduled_time)
                                ttTask.tool_name      = mcp_scheduled_task.tool_name
                                ttTask.notify_email   = mcp_scheduled_task.notify_email
                                ttTask.recurrence     = mcp_scheduled_task.recurrence.
                        END.
                    END.
                    ELSE
                    DO:
                        FOR EACH mcp_scheduled_task NO-LOCK
                            WHERE mcp_scheduled_task.task_status = cStatus
                            BY mcp_scheduled_task.scheduled_time:
                            CREATE ttTask.
                            ASSIGN
                                ttTask.task_id        = mcp_scheduled_task.task_id
                                ttTask.task_name      = mcp_scheduled_task.task_name
                                ttTask.task_type      = mcp_scheduled_task.task_type
                                ttTask.task_status    = mcp_scheduled_task.task_status
                                ttTask.scheduled_time = STRING(mcp_scheduled_task.scheduled_time)
                                ttTask.tool_name      = mcp_scheduled_task.tool_name
                                ttTask.notify_email   = mcp_scheduled_task.notify_email
                                ttTask.recurrence     = mcp_scheduled_task.recurrence.
                        END.
                    END.

                    TEMP-TABLE ttTask:WRITE-JSON("JsonArray", oList, TRUE).
                    oResult:Add("status", "ok").
                    oResult:Add("tasks",  oList).
                END.

            WHEN "create" THEN
                DO:
                    ASSIGN
                        cTaskName      = poArguments:GetCharacter("task_name")
                        cTaskType      = IF poArguments:Has("task_type")           THEN poArguments:GetCharacter("task_type")           ELSE "execute_tool"
                        cToolName      = IF poArguments:Has("tool_name")           THEN poArguments:GetCharacter("tool_name")           ELSE ""
                        cToolArguments = IF poArguments:Has("tool_arguments")      THEN poArguments:GetCharacter("tool_arguments")      ELSE "~{~}"
                        cChatInput     = IF poArguments:Has("chat_input")          THEN poArguments:GetCharacter("chat_input")          ELSE ""
                        cScheduledTime = poArguments:GetCharacter("scheduled_time")
                        cRecurrence    = IF poArguments:Has("recurrence")          THEN poArguments:GetCharacter("recurrence")          ELSE "ONCE"
                        iRecInterval   = IF poArguments:Has("recurrence_interval") THEN poArguments:GetInteger("recurrence_interval")   ELSE 1
                        cNotifyEmail   = IF poArguments:Has("notify_email")        THEN poArguments:GetCharacter("notify_email")        ELSE ""
                        cNotifySubject = IF poArguments:Has("notify_subject")      THEN poArguments:GetCharacter("notify_subject")      ELSE "Task completed: " + cTaskName
                        cEndpoint      = IF poArguments:Has("n8n_endpoint")        THEN poArguments:GetCharacter("n8n_endpoint")        ELSE "http://localhost:5678/webhook/pasoe"
                        iMaxRetries    = IF poArguments:Has("max_retries")         THEN poArguments:GetInteger("max_retries")           ELSE 3.

                    dtScheduled = DATETIME-TZ(cScheduledTime) NO-ERROR.
                    IF dtScheduled = ? THEN
                    DO:
                        oResult:Add("status",  "error").
                        oResult:Add("message", "Invalid scheduled_time. Use ISO 8601 e.g. 2026-03-16T08:00:00+01:00").
                        RETURN CreateMcpResponseJson(id, oResult, false).
                    END.

                    iNextId = 1.
                    FOR LAST mcp_scheduled_task NO-LOCK BY mcp_scheduled_task.task_id:
                        iNextId = mcp_scheduled_task.task_id + 1.
                    END.

                    DO TRANSACTION:
                        CREATE mcp_scheduled_task.
                        ASSIGN
                            mcp_scheduled_task.task_id             = iNextId
                            mcp_scheduled_task.task_name           = cTaskName
                            mcp_scheduled_task.task_type           = cTaskType
                            mcp_scheduled_task.tool_name           = cToolName
                            mcp_scheduled_task.tool_arguments      = cToolArguments
                            mcp_scheduled_task.chat_input          = cChatInput
                            mcp_scheduled_task.task_status         = "PENDING"
                            mcp_scheduled_task.scheduled_time      = dtScheduled
                            mcp_scheduled_task.recurrence          = cRecurrence
                            mcp_scheduled_task.recurrence_interval = iRecInterval
                            mcp_scheduled_task.notify_email        = cNotifyEmail
                            mcp_scheduled_task.notify_subject      = cNotifySubject
                            mcp_scheduled_task.n8n_endpoint        = cEndpoint
                            mcp_scheduled_task.max_retries         = iMaxRetries
                            mcp_scheduled_task.retry_count         = 0
                            mcp_scheduled_task.created_by          = "claude"
                            mcp_scheduled_task.created_at          = NOW
                            mcp_scheduled_task.updated_at          = NOW.
                    END.

                    oResult:Add("status",         "ok").
                    oResult:Add("message",        "Task created successfully").
                    oResult:Add("task_id",        iNextId).
                    oResult:Add("task_name",      cTaskName).
                    oResult:Add("scheduled_time", STRING(dtScheduled)).
                    oResult:Add("recurrence",     cRecurrence).
                END.

            WHEN "cancel" THEN
                DO TRANSACTION:
                    iTaskId = poArguments:GetInteger("task_id").
                    FIND mcp_scheduled_task
                        WHERE mcp_scheduled_task.task_id = iTaskId
                        EXCLUSIVE-LOCK NO-ERROR.
                    IF AVAILABLE mcp_scheduled_task THEN
                    DO :
                        ASSIGN
                            mcp_scheduled_task.task_status = "CANCELLED"
                            mcp_scheduled_task.updated_at  = NOW.
                        oResult:Add("status",  "ok").
                        oResult:Add("message", "Task " + STRING(iTaskId) + " cancelled").
                    END.
                    ELSE
                    DO:
                        oResult:Add("status",  "error").
                        oResult:Add("message", "Task " + STRING(iTaskId) + " not found").
                    END.
                END.

            WHEN "delete" THEN
                DO TRANSACTION:
                    iTaskId = poArguments:GetInteger("task_id").
                    FIND mcp_scheduled_task
                        WHERE mcp_scheduled_task.task_id = iTaskId
                        EXCLUSIVE-LOCK NO-ERROR.
                    IF AVAILABLE mcp_scheduled_task THEN
                    DO :
                        DELETE mcp_scheduled_task.
                        oResult:Add("status",  "ok").
                        oResult:Add("message", "Task " + STRING(iTaskId) + " deleted").
                    END.
                    ELSE
                    DO:
                        oResult:Add("status",  "error").
                        oResult:Add("message", "Task " + STRING(iTaskId) + " not found").
                    END.
                END.

            OTHERWISE
            DO:
                oResult:Add("status",  "error").
                oResult:Add("message", "Unknown action. Use: list, create, cancel, delete").
            END.

        END CASE.

        RETURN CreateMcpResponseJson(id, oResult, false).


    END.

END CLASS.
