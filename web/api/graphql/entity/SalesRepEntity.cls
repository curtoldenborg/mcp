

USING Progress.Lang.*.
USING web.*. 

CLASS web.api.graphql.entity.salesrepentity IMPLEMENTS web.api.graphql.entity.Ibusinessentity INHERITS web.api.graphql.entity.base: 

    CONSTRUCTOR  salesrepentity(INPUT DATASET-HANDLE hDS):
        SUPER (DATASET-HANDLE hDS). 
    END CONSTRUCTOR.
 
    METHOD VOID SchemaDefinition (): 
        
        RelationField('Customer','CustNum','CustNum'). 
        RelationField('salesrep','repNum','repNum'). 
        RelationField('billto','CustNum','BillToId'). 
        RelationField('shipto','CustNum','ShipToId'). 
        RelationField('OrderLine','OrderNum','OrderNum'). 
        RelationField('InventoryTrans','OrderNum','OrderNum'). 
        FilterOptionMapping('ID','integer','custnum = @1').
    END.
    
    METHOD CHAR REGION(icRegion as char, OUTPUT cQuery as char):
        
         IF icRegion = "international" THEN 
           return " ( country ne 'usa' ) ".
        
         IF icRegion = "NORTH" THEN 
           return " ( country = 'norway' or country = 'finland' or country = 'sweden' or country = 'denmark' ) ".
         
             IF icRegion = "USA" THEN 
           return " ( country = 'USA' ) ".  
         
         return "".   
    END.  
   
    METHOD CHAR _ilike(icString as char, OUTPUT cQuery as char):
        def var creturn as char. 
        icString = replace(icString,"%","*").
        creturn = " ( name matches " + quoter(icString) + ')' .
      
          return cReturn.       
    end. 
   
    METHOD CHARACTER primaryKey():
         return "SalesRep".
    END. 
    
END. 

