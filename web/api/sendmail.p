


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
 