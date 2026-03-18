VAR HANDLE hBuffer.
VAR HANDLE hQuery.

CREATE BUFFER hBuffer FOR TABLE "Customer".

CREATE QUERY hQuery.
hQuery:SET-BUFFERS(hBuffer).
hQuery:QUERY-PREPARE("FOR EACH " + hBuffer:NAME).
hQuery:QUERY-OPEN().
hQuery:GET-FIRST().

OUTPUT TO VALUE(hBuffer:NAME + ".d").

DO WHILE NOT hQuery:QUERY-OFF-END:
  hBuffer:BUFFER-EXPORT().
  hQuery:GET-NEXT().
END.

OUTPUT CLOSE.

hQuery:QUERY-CLOSE().
DELETE OBJECT hQuery.
DELETE OBJECT hBuffer.
This example shows how you can use a named stream:
DEFINE STREAM s1.
OUTPUT STREAM s1 TO "order.d".
...
hBuffer:BUFFER-EXPORT(STREAM s1:HANDLE).
...