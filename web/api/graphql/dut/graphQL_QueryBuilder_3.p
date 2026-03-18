


DEF VAR oGraph AS web.api.graphql.parsequery. 
DEF VAR oQueryBuilder AS web.api.graphql.querybuilder. 

 LOG-MANAGER:LOGFILE-NAME = "C:\temp\log2.txt".   
  
DEF VAR s AS CHAR NO-UNDO. 

s = '~{ customers ~{ id name orders(dateFrom: \"2023-10-04T00:00:00Z\", dateTo: \"2023-10-04T23:59:59Z\") ~{ edges ~{ node ~{ id orderNum orderDate totalAmount status ~}~} ~} ~} ~}'.
s = '~{ customers(filter: ~{ hasOrders: true ~})~{  id name orders(dateFrom: \"2023-10-04T00:00:00Z\", dateTo: \"2023-10-04T23:59:59Z\") ~{ edges ~{ node ~{ id orderNum orderDate totalAmount status ~}~} ~} ~} ~}'.

// s = "~{ customers ~{ edges ~{ node ~{ id custNum name address city state postalCode country phone createdAt updatedAt ~} ~} ~} ~}".
// s = '~{ customers(region: NORTH , name: "u*", country: "finland") ~{ edges ~{ node ~{ name ~}~}~}~}'.
// s = '~{ customers(region: north , country: "finland" , name: "u*") ~{ edges ~{ node ~{ name ~}~}~}~}'.
// s = '~{ customers(_ilike: "%Kempeleen Intersport%") ~{ edges ~{ node ~{ name ~}~}~}~}'.
// s = '~{ schema_customers_filter(where: ~{name: ~{ _ilike: "%Kempeleen Intersport%"~}~}) ~{ name address state postal_code contact_person phone ~} ~}'.
// s = '~{ customers(where: ~{name: ~{ _ilike: "%Kempeleen Intersport%"~}~}) ~{ name address state postal_code contact_person phone ~} ~}'.
// s = '~{ customers(country: "France", city: "Paris") ~{ edges ~{ node ~{ id name address city state postalCode phone salesRep ~{ name ~} createdAt updatedAt ~}~}~}~}'.
// s = '~{ customers(country: "France", city: "Paris") ~{ edges ~{ node ~{ id name address city state postalCode phone salesRep ~{ name ~}~}~}~}~}'.

//      { orders { id orderNum orderDate status totalAmount customer { id name email } } }


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
            
            
