


DEFINE VARIABLE lAttachment AS MEMPTR NO-UNDO. 
   
COPY-LOB FROM FILE "c:\temp\test.pptx" TO lAttachment NO-CONVERT. 
 
RUN web/api/sendmailwithattachment.p ("","","",lAttachment,"test.pptx").
