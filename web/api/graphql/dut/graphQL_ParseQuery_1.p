

DEF VAR oGraph AS web.api.graphql.parsequery. 

DEF VAR s AS CHAR NO-UNDO. 
S = '
~{
  user~(id: $userId) ~{
    id
    name
    email
    posts(filter: ~{ category: "electronics" ~}, sort: ~{ price: ASC ~}) ~{
      id
      title
      content
      comments ~{
        id
        text
        author(filter: ~{ 
    location: "New York",
    eventDate: ~{ lt: "2025-06-01" ~}
  ~})~{
          id
          name
        ~}
      ~}
    ~}
  ~}
~}' .

s = '~{ customers ~{ id name orders(dateFrom: \"2023-10-04T00:00:00Z\", dateTo: \"2023-10-04T23:59:59Z\") ~{ edges ~{ node ~{ id orderNum orderDate totalAmount status ~}~} ~} ~} ~}'.


oGraph = NEW web.api.graphql.parsequery().
oGraph:ParseGraphQL(s).
oGraph:hQueryDataset:WRITE-JSON("FILE","C:\temp\dataset.txt", TRUE).

oGraph:BuildResultDataset(). 

