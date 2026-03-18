

USING Progress.Lang.*.
USING web.*. 

CLASS web.api.graphql.entity.CustomerEntity IMPLEMENTS web.api.graphql.entity.Ibusinessentity INHERITS web.api.graphql.entity.base: 

    CONSTRUCTOR  CustomerEntity(INPUT DATASET-HANDLE hDS):
        SUPER (DATASET-HANDLE hDS). 
    END CONSTRUCTOR.
 
    METHOD VOID SchemaDefinition (): 
        //DEF VAR FromDateToDate AS CHAR EXTENT 2 INIT ["FromDate","ToDate"].
        RelationField('Customer','CustNum','CustNum'). 
        RelationField('salesrep','repNum','repNum'). 
        RelationField('billto','CustNum','BillToId'). 
        RelationField('shipto','CustNum','ShipToId'). 
        RelationField('OrderLine','OrderNum','OrderNum'). 
        RelationField('InventoryTrans','OrderNum','OrderNum'). 
        FilterOptionMapping('ID','integer','custnum = @1').
        // CalculatedField('totalAmount') .  
    END.
    
    METHOD CHARACTER Id(icstring AS CHARACTER, OUTPUT cQuery AS CHARACTER):
        return "custnum = " + icstring.
    END. 
 
    METHOD CHARACTER Customerid(icstring AS CHARACTER, OUTPUT cQuery AS CHARACTER):
        return "custnum = " + icstring.
    END. 
    
    METHOD CHARACTER REGION(icRegion AS CHARACTER, OUTPUT cQuery AS CHARACTER):
        IF icRegion = "international" THEN RETURN " ( country ne 'usa' ) ".
        IF icRegion = "NORTH" THEN 
            RETURN " ( country = 'norway' or country = 'finland' or country = 'sweden' or country = 'denmark' ) ".
        IF icRegion = "USA" THEN  RETURN " ( country = 'USA' ) ".  
        RETURN "".   
    END.  
   
    METHOD CHARACTER _ilike(icString AS CHARACTER, OUTPUT cQuery AS CHARACTER):
        DEFINE VARIABLE creturn AS CHARACTER. 
        icString = REPLACE(icString,"%","*").
        creturn = " ( name matches " + quoter(icString) + ')' .
        RETURN cReturn.       
    END. 
  
    METHOD CHARACTER hasOrders(icString AS CHARACTER, OUTPUT cQuery AS CHARACTER):
        DEFINE VARIABLE creturn AS CHARACTER. 
        RETURN creturn.       
    END. 
  
    
    METHOD CHARACTER primaryKey():
         return "CustNum".
    END. 

END. 

/*
Benefits:
  Vacation OF Benefits (EmpNum)
  TimeSheet OF Benefits (EmpNum)
  Family OF Benefits (EmpNum)
  Employee OF Benefits (EmpNum)
  Benefits OF Employee (EmpNum)

BillTo:
  Order OF BillTo (CustNum,BillToID)
  BillTo OF State (State)
  BillTo OF Customer (CustNum)

Bin:
  InventoryTrans OF Bin (BinNum)
  Bin OF Warehouse (WarehouseNum)
  Bin OF Item (ItemNum)

Customer:
  ShipTo OF Customer (CustNum)
  RefCall OF Customer (CustNum)
  Order OF Customer (CustNum)
  Invoice OF Customer (CustNum)
  BillTo OF Customer (CustNum)
  Customer OF State (State)
  Customer OF SalesRep (SalesRep)

Department:
  Employee OF Department (DeptCode)

Employee:
  Vacation OF Employee (EmpNum)
  TimeSheet OF Employee (EmpNum)
  Family OF Employee (EmpNum)
  Benefits OF Employee (EmpNum)
  Employee OF Vacation (EmpNum,StartDate)
  Employee OF State (State)
  Employee OF Department (DeptCode)
  Employee OF Benefits (EmpNum)

Family:
  Family OF Employee (EmpNum)
  Family OF Benefits (EmpNum)

Feedback:
   No relations found for this file.

InventoryTrans:
  InventoryTrans OF Warehouse (WarehouseNum)
  InventoryTrans OF PurchaseOrder (PONum)
  InventoryTrans OF Order (OrderNum)
  InventoryTrans OF Item (ItemNum)
  InventoryTrans OF Bin (BinNum)

Invoice:
  Invoice OF Customer (CustNum)

Item:
  SupplierItemXref OF Item (ItemNum)
  OrderLine OF Item (ItemNum)
  POLine OF Item (ItemNum)
  InventoryTrans OF Item (ItemNum)
  Bin OF Item (ItemNum)

LocalDefault:
   No relations found for this file.

Order:
  OrderLine OF Order (OrderNum)
  InventoryTrans OF Order (OrderNum)
  Order OF Warehouse (WarehouseNum)
  Order OF ShipTo (CustNum,ShipToID)
  Order OF SalesRep (SalesRep)
  Order OF Customer (CustNum)
  Order OF BillTo (CustNum,BillToID)

OrderLine:
  OrderLine OF Order (OrderNum)
  OrderLine OF Item (ItemNum)

POLine:
  POLine OF PurchaseOrder (PONum)
  POLine OF Item (ItemNum)

PurchaseOrder:
  POLine OF PurchaseOrder (PONum)
  InventoryTrans OF PurchaseOrder (PONum)
  PurchaseOrder OF Supplier (SupplierIDNum)

RefCall:
  RefCall OF SalesRep (SalesRep)
  RefCall OF Customer (CustNum)

SalesRep:
  RefCall OF SalesRep (SalesRep)
  Order OF SalesRep (SalesRep)
  Customer OF SalesRep (SalesRep)

ShipTo:
  Order OF ShipTo (CustNum,ShipToID)
  ShipTo OF State (State)
  ShipTo OF Customer (CustNum)

State:
  Warehouse OF State (State)
  ShipTo OF State (State)
  Supplier OF State (State)
  Employee OF State (State)
  Customer OF State (State)
  BillTo OF State (State)

Supplier:
  SupplierItemXref OF Supplier (SupplierIDNum)
  PurchaseOrder OF Supplier (SupplierIDNum)
  Supplier OF State (State)

SupplierItemXref:
  SupplierItemXref OF Supplier (SupplierIDNum)
  SupplierItemXref OF Item (ItemNum)

TimeSheet:
  TimeSheet OF Employee (EmpNum)
  TimeSheet OF Benefits (EmpNum)

Vacation:
  Employee OF Vacation (EmpNum,StartDate)
  Vacation OF Employee (EmpNum)
  Vacation OF Benefits (EmpNum)

Warehouse:
  Order OF Warehouse (WarehouseNum)
  InventoryTrans OF Warehouse (WarehouseNum)
  Bin OF Warehouse (WarehouseNum)
  Warehouse OF State (State)


*/