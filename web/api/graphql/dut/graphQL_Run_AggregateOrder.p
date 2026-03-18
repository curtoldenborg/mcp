
    
USING Progress.Lang.Class.*.

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
 s = '~{ customers(country: "France", city: "Paris") ~{ edges ~{ node ~{ id name address city state postalCode phone salesRep ~{ name ~}~}~}~}~}'.

//    { orders { id orderNum orderDate status totalAmount customer { id name email } } }
//    { customers(country: \"Finland\") { edges { node { id custNum name address city state postalCode country phone }} pageInfo { hasNextPage endCursor } } }
//    { customer(id: 3370) { orders { edges { node { orderNum orderDate status totalAmount orderLines { lineNum item { name description price } quantity } notes } } } } }
//    { schema: { orders: { edges: [ { node: { order_id } } ] } } }

s = "~{ customers (filter: ~{ hasOrders: true ~}) ~{ edges ~{ node ~{ id custNum name address city state postalCode country phone createdAt updatedAt totalSales: order_aggregate ~{ aggregate ~{ sum ~{ total_amount ~}~}~}~} ~} ~} ~}".
s = " ~{ aggregateOrder ~{ count avgTotal ~} ~} ".
s = "~{ customers (filter: ~{ hasOrders: true ~}) ~{ edges ~{ node ~{ id custNum name address city state postalCode country phone createdAt updatedAt totalSales: aggregateOrder ~{ count avgTotal ~}  ~} ~} ~} ~}".
 
   // sum / avg 

DEF VAR hs AS HANDLE. 
RUN web/api/graphql/graphqlquery.p (s, OUTPUT DATASET-HANDLE hs BY-REFERENCE). 
     
