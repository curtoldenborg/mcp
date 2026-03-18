
/*------------------------------------------------------------------------
    File        : web.api.graphql.entity.IBusinessEntity
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.

INTERFACE web.api.graphql.entity.IBusinessEntity:  
    
    METHOD PUBLIC CHARACTER getQuery(INPUT hTable AS HANDLE):
    METHOD CHARACTER PrimaryKey():
       
END INTERFACE.