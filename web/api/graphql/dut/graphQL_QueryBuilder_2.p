


DEF VAR oGraph AS web.api.graphql.parsequery. 
DEF VAR oQueryBuilder AS web.api.graphql.querybuilder. 

 LOG-MANAGER:LOGFILE-NAME = "C:\temp\log2.txt".   
  
DEF VAR s AS CHAR NO-UNDO. 

s = '~{ customers ~{ id name orders(dateFrom: \"2023-10-04T00:00:00Z\", dateTo: \"2023-10-04T23:59:59Z\") ~{ edges ~{ node ~{ id orderNum orderDate totalAmount status ~}~} ~} ~} ~}'.
s = "~{ customers ~{ edges ~{ node ~{ id custNum name address city state postalCode country phone createdAt updatedAt ~} ~} ~} ~}".
s = '~{ customers(region: NORTH , name: "u*", country: "finland") ~{ edges ~{ node ~{ name ~}~}~}~}'.
s = '~{ customers(region: north , country: "finland" , name: "u*") ~{ edges ~{ node ~{ name ~}~}~}~}'.
s = '~{ customers(_ilike: "%Kempeleen Intersport%") ~{ edges ~{ node ~{ name ~}~}~}~}'.



oGraph = NEW web.api.graphql.parsequery().
oGraph:ParseGraphQL(s).
oGraph:hQueryDataset:WRITE-JSON("FILE","C:\temp\dataset-query.txt", TRUE).
                                                             
 def VAR hds as handle. 
 hds = oGraph:hQueryDataset.
 
 oQueryBuilder = NEW web.api.graphql.querybuilder(DATASET-HANDLE hds BY-REFERENCE).
 oQueryBuilder:hQueryResultDataSet:WRITE-JSON("FILE","C:\temp\dataset-result.txt", TRUE).
 oQueryBuilder:log-query(). 
 
 LOG-MANAGER:CLOSE-LOG().
// oGraph:BuildResultDataset(). 
          /*
{
  "graphql_query": "query { customers { edges { node { id custNum name address city state postalCode country phone salesRep { id name } createdAt updatedAt } } } }"
}
            */
            
            
