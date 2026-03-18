

type Customer {
  CustNum: ID!
  Name: String!
  Address: String
  City: String
  State: String
  PostalCode: String
  Country: String
  Phone: String
  SalesRep: SalesRep!  # Tilknyttet selger
  Orders: [Order!]     # Alle ordre fra kunden
}

type Order {
  OrderNum: ID!
  OrderDate: String!   # ISO-dato (f.eks. "2023-10-01")
  CustNum: Customer!   # Kunden som la ordren
  SalesRep: SalesRep!  # Selgeren som håndterte ordren
  OrderStatus: String! # F.eks. "Plassert", "Levert", "Avbrutt"
  OrderLines: [OrderLine!] # Alle ordrelinjer
}

type OrderLine {
  OrderNum: Order!     # Ordren linjen tilhører
  LineNum: Int!
  Item: Item!          # Produktet på linjen
  Quantity: Int!
  Price: Float!        # Pris per enhet
}

type Item {
  ItemNum: ID!
  ItemName: String!
  Category: Category!  # Produktkategori
  Price: Float!
  Weight: Float
  InStock: Int!        # Lagerbeholdning
}

type SalesRep {
  RepID: ID!           # Primærnøkkel (tilsvarer SalesRep i Customer)
  RepName: String!
  Region: String
  Email: String
  Phone: String
  Customers: [Customer!] # Alle kunder tilknyttet selgeren
}

type Category {
  CategoryID: ID!
  Description: String!
  Items: [Item!]       # Alle produkter i kategorien
}

# Query-definisjoner
type Query {
  # Hent alle kunder
  customers: [Customer!]
  
  # Hent en spesifikk kunde
  customer(id: ID!): Customer
  
  # Hent alle ordre
  orders(status: String): [Order!] 
  
  # Hent alle produkter
  items(category: ID): [Item!]
  
  # Hent alle kategorier
  categories: [Category!]
  
  # Hent selgere
  salesReps(region: String): [SalesRep!]
}

# Mutations for å opprette/oppdatere data
type Mutation {
  createCustomer(input: CreateCustomerInput!): Customer
  updateCustomer(id: ID!, input: UpdateCustomerInput!): Customer
  deleteCustomer(id: ID!): Boolean

  # Tilsvarende for Order, Item, osv.
}

# Input-typer for mutations
input CreateCustomerInput {
  Name: String!
  Address: String
  City: String
  State: String
  PostalCode: String
  Country: String
  Phone: String
  SalesRep: ID! # RepID
}

input UpdateCustomerInput {
  Name: String
  Address: String
  City: String
  # ... andre felter
}
