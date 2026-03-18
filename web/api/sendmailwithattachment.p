

USING System.Net.*.
USING System.Net.Mail.*.
USING System.IO.*.
USING System.Text.*.

/* Define your input parameters */
DEFINE INPUT PARAMETER cToEmail     AS CHAR      NO-UNDO.
DEFINE INPUT PARAMETER cSubject     AS CHAR      NO-UNDO. 
DEFINE INPUT PARAMETER cBody        AS CHAR      NO-UNDO. 

// DEFINE INPUT PARAMETER lcFileContent AS LONGCHAR NO-UNDO.
DEFINE INPUT PARAMETER mData        AS MEMPTR    NO-UNDO. /* The file content */
DEFINE INPUT PARAMETER cFileName    AS CHAR      NO-UNDO. /* e.g., "report.txt" */

DEFINE VARIABLE oSmtpClient AS SmtpClient  NO-UNDO. 
DEFINE VARIABLE oMessage    AS MailMessage NO-UNDO. 
DEFINE VARIABLE oAttachment AS Attachment  NO-UNDO. 
DEFINE VARIABLE oStream     AS MemoryStream NO-UNDO.
DEFINE VARIABLE oEncoding   AS Encoding     NO-UNDO.
//DEFINE VARIABLE mData       AS MEMPTR       NO-UNDO.


/* 0. Defalut */

cToEmail = IF cToEmail = "" THEN "curt@proventus.no" ELSE cToEmail.  
cSubject = IF cSubject = "" THEN "Testing" ELSE cSubject. 
cBody    = IF cBody    = "" THEN "TestBody" ELSE cBody. 

/* 1. Setup Connection */
ServicePointManager:SecurityProtocol = SecurityProtocolType:Tls12.
oSmtpClient = NEW SmtpClient("smtp.gmail.com", 587).
oSmtpClient:UseDefaultCredentials = FALSE.
oSmtpClient:EnableSsl = TRUE.
oSmtpClient:Credentials = NEW NetworkCredential("coldenborg@gmail.com", "xyfi jaav ongb fitu").

/* 2. Setup Message */
oMessage = NEW MailMessage().
oMessage:From = NEW MailAddress("coldenborg@gmail.com").
oMessage:TO:Add(NEW MailAddress(cToEmail)). 
oMessage:Subject = cSubject.
oMessage:Body = cBody.


/* 3. Process LONGCHAR into Attachment */
// IF LENGTH(lcFileContent) > 0 THEN DO:
IF GET-SIZE(mData) > 0 THEN DO: 
    /* Convert LONGCHAR to MEMPTR for byte-handling */
    // COPY-LOB FROM lcFileContent TO mData.
    
    /* Create a .NET MemoryStream from the MEMPTR */
    oStream = NEW MemoryStream(integer(GET-SIZE(mData))).

   /* FIX: Loop through MEMPTR and write each byte to the stream */
    DEFINE VARIABLE iLoop AS INTEGER NO-UNDO.
    DO iLoop = 1 TO GET-SIZE(mData):
        oStream:WriteByte(GET-BYTE(mData, iLoop)).
    END.  
 
    oStream:Position = 0. /* Reset stream position for the Attachment reader */

    /* Create attachment from stream */
    oAttachment = NEW Attachment(oStream, cFileName).
    
    oMessage:Attachments:Add(oAttachment).
END.

/* 4. Send and Cleanup */
oSmtpClient:Send(oMessage).

/* CRITICAL: Disposal closes the stream and releases memory */
IF VALID-OBJECT(oAttachment) THEN oAttachment:Dispose().
IF VALID-OBJECT(oStream)     THEN oStream:Dispose().
oMessage:Dispose(). 
oSmtpClient:Dispose().
SET-SIZE(mData) = 0. /* Free Progress memory */



/*
USING System.Net.* FROM ASSEMBLY.
USING System.Net.Mail.* FROM ASSEMBLY .


DEFINE INPUT PARAMETER cToEmail AS CHAR NO-UNDO.
define input parameter cSubject as char no-undo. 
DEFINE INPUT PARAMETER cBody AS CHAR NO-UNDO. 

DEFINE VARIABLE oSmtpClient AS SmtpClient NO-UNDO. 
DEFINE VARIABLE oMessage AS MailMessage NO-UNDO . 
 
ServicePointManager:SecurityProtocol = SecurityProtocolType:Tls12 .
oSmtpClient = NEW SmtpClient ("smtp.gmail.com", 587).
oMessage = NEW MailMessage ().
oSmtpClient:UseDefaultCredentials = FALSE .
oSmtpClient:EnableSsl = TRUE .
oSmtpClient:Credentials = NEW NetworkCredential ("coldenborg@gmail.com","xyfi jaav ongb fitu") .
oMessage:From = NEW MailAddress ("coldenborg@gmail.com") .
oMessage:TO:Add (NEW MailAddress (cToEmail)) . 
oMessage:Subject = cSubject.
oMessage:Body = cBody.
oSmtpClient:Send (oMessage) .
 
*/