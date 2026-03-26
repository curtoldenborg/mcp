DEFINE VARIABLE hSocket AS HANDLE NO-UNDO.

/* 1. Create and Connect */
CREATE SOCKET hSocket.
hSocket:SET-READ-RESPONSE-PROCEDURE("HandleNotification", THIS-PROCEDURE).

/* Use -H for Host (localhost) and -S for Service/Port */
hSocket:CONNECT("-H localhost -S 7999") NO-ERROR.

IF NOT hSocket:CONNECTED() THEN DO:
    MESSAGE "Could not connect to notify server." VIEW-AS ALERT-BOX.
    RETURN.
END.


   
    DEF VAR cmsg AS CHAR INIT "ping". 
     DEFINE VARIABLE cL AS MEMPTR NO-UNDO.
     DEF VAR iLength AS INT NO-UNDO. 
  
    iLength = LENGTH(cmsg). 
    SET-SIZE(cl) = iLength. 
    PUT-STRING(cl,1,iLength) = cmsg. 
    hSocket:WRITE(cL, 1, iLength) NO-ERROR.

//    MESSAGE "Connected! Waiting for notifications..." VIEW-AS ALERT-BOX.
  
   
/* 2. Wait for data from the server */
WAIT-FOR READ-RESPONSE OF hSocket.

/* 3. Cleanup */
hSocket:DISCONNECT().
DELETE OBJECT hSocket.

/* --- Procedure to handle incoming messages --- */
PROCEDURE HandleNotification:
    DEFINE VARIABLE cMsg AS LONGCHAR NO-UNDO.
    
    /* Read the incoming JSON broadcast */
    IF hSocket:GET-BYTES-AVAILABLE() > 0 THEN DO:
//        hSocket:READ(cMsg, 0).
        MESSAGE "Received:" STRING(cMsg) VIEW-AS ALERT-BOX.
    END.
END PROCEDURE.
