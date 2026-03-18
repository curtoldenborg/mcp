

DEF VAR oGraph AS web.api.graphql.parsequery. 

DEF VAR s AS CHAR NO-UNDO. 

s = '~{ customers ~{ id name orders(dateFrom: \"2023-10-04T00:00:00Z\", dateTo: \"2023-10-04T23:59:59Z\") ~{ edges ~{ node ~{ id orderNum orderDate totalAmount status ~}~} ~} ~} ~}'.
s = "~{ customers ~{ edges ~{ node ~{ id custNum name address city state postalCode country phone createdAt updatedAt ~} ~} ~} ~}".

oGraph = NEW web.api.graphql.parsequery().
oGraph:ParseGraphQL(s).
oGraph:hQueryDataset:WRITE-JSON("FILE","C:\temp\dataset.txt", TRUE).

oGraph:BuildResultDataset(). 

