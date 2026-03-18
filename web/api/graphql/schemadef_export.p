
BLOCK-LEVEL ON ERROR UNDO, THROW.

def var oSchemaDef AS web.api.graphql.schemadef. 
def var hDataset as handle. 
def var lBody AS LONGCHAR. 

oschemadef = NEW web.api.graphql.schemadef(). 
// hDataset = oSchemaDef:getDataSet(). 

lBody = oSchemaDef:getSchema(). 
               
// hDataset:WRITE-JSON("longchar",lBody, TRUE).
COPY-LOB lBody TO FILE "C:\temp\dump.json". 
  
