

BLOCK-LEVEL ON ERROR UNDO, THROW.


    DEFINE INPUT PARAMETER cQuery AS CHARACTER NO-UNDO. 
    DEFINE OUTPUT PARAMETER DATASET-HANDLE hDataset.
    
    DEF VAR oGraph AS web.api.graphql.parsequery. 
    DEF VAR oQueryBuilder AS web.api.graphql.querybuilder. 
    def var hds as handle no-undo.
    
    oGraph = NEW web.api.graphql.parsequery().
    oGraph:ParseGraphQL(cQuery).
    oGraph:hQueryDataset:WRITE-JSON("FILE","C:\temp\n8n-dataset-query.txt", TRUE).
    
   // oGraph:BuildResultDataset(). 
    hds = oGraph:hQueryDataset.
     
    oQueryBuilder = NEW web.api.graphql.querybuilder(DATASET-HANDLE hds BY-REFERENCE).
    oQueryBuilder:hQueryResultDataSet:WRITE-JSON("FILE","C:\temp\dataset-result.txt", TRUE).
    oQueryBuilder:log-query(). 
     
    hDataset = oQueryBuilder:hQueryResultDataSet.
     
    delete object oGraph no-error. 
    delete object oQueryBuilder no-error. 

