# Scalar for dato/tid (kan implementeres i backend)
scalar DateTime

# Enums for kontrollerte verdier
enum OrderStatus {
  PLACED
  PROCESSING
  SHIPPED
  DELIVERED
  CANCELLED
}

enum Region {
  NORTH
  SOUTH
  EAST
  WEST
  INTERNATIONAL
}

# Grunnleggende grensesnitt for globale ID-er (Relay-kompatibilitet)
interface Node {
  id: ID!
}

# Typer
type Customer implements Node {
  id: ID!
  custNum: Int!
  name: String!
  address: String
  city: String
  state: String
  postalCode: String
  country: String!
  phone: String
  salesRep: SalesRep!
  orders(
    status: OrderStatus
    first: Int
    after: String
  ): OrderConnection!
  createdAt: DateTime!
  updatedAt: DateTime!
}

type Order implements Node {
  id: ID!
  orderNum: Int!
  orderDate: DateTime!
  customer: Customer!
  salesRep: SalesRep!
  status: OrderStatus!
  totalAmount: Float!  # Beregnet felt
  orderLines: [OrderLine!]!
  notes: String
}

 type OrderAggregate {
    count: Int
    avgTotal: Float
  }


type OrderLine {
  id: ID!
  order: Order!
  lineNum: Int!
  item: Item!
  quantity: Int!
  price: Float!
  discount: Float @deprecated(reason: "Bruk promo-codes i stedet")
}

 type OrderLineAggregate {
    count: Int
    avgQuantity: Float
    avgPrice: Float
  }


type Item implements Node {
  id: ID!
  itemNum: Int!
  name: String!
  description: String
  category: Category!
  price: Float!
  costPrice: Float!  # Kun tilgjengelig for admin
  weight: Float
  inStock: Int!
  reorderThreshold: Int!
  supplier: Supplier
  reviews: [Review!]!
}

type Category implements Node {
  id: ID!
  name: String!
  description: String
  items(first: Int, after: String): ItemConnection!
}

type SalesRep implements Node {
  id: ID!
  repNum: Int!
  name: String!
  region: Region!
  email: String!
  phone: String
  customers: [Customer!]!
  salesTarget: Float!
  commissionRate: Float!
}

type Supplier {
  id: ID!
  name: String!
  contactEmail: String!
  itemsSupplied: [Item!]!
}

type Review {
  id: ID!
  item: Item!
  customer: Customer!
  rating: Int! (1-5)
  comment: String
  createdAt: DateTime!
}

# Pagineringsstøtte (Cursor-based)
type OrderConnection {
  edges: [OrderEdge!]!
  pageInfo: PageInfo!
}

type OrderEdge {
  cursor: String!
  node: Order!
}

type ItemConnection {
  edges: [ItemEdge!]!
  pageInfo: PageInfo!
}

type ItemEdge {
  cursor: String!
  node: Item!
}

type PageInfo {
  hasNextPage: Boolean!
  endCursor: String
}

# Query-definisjoner
type Query {
  node(id: ID!): Node  # Relay-style global ID lookup
  
  customer(id: ID!): Customer
  customers(
    region: Region
    country: String
    name: String
    first: Int = 10
    after: String
  ): CustomerConnection!
  
  order(id: ID!): Order
  orders(
    status: OrderStatus
    dateFrom: DateTime
    dateTo: DateTime
  ): [Order!]!
  
  item(id: ID!): Item
  searchItems(
    query: String!
    category: ID
    inStock: Boolean
  ): [Item!]!

  aggregateOrder: OrderAggregate
 
  aggregateOrderLine: OrderLineAggregate
  
  salesRepLeaderboard(region: Region): [SalesRep!]!
}

# Mutations
type Mutation {
  createOrder(input: CreateOrderInput!): OrderPayload!
  updateOrderStatus(id: ID!, status: OrderStatus!): OrderPayload!
  addItemToStock(itemNum: Int!, quantity: Int!): ItemPayload!
  createCustomerReview(input: ReviewInput!): ReviewPayload!
  
  # Admin-only operasjoner
  updatePricing(itemNum: Int!, newPrice: Float!): ItemPayload!
    @auth(requires: ADMIN)
}

# Input-typer
input CreateOrderInput {
  custNum: Int!
  items: [OrderItemInput!]!
  notes: String
}

input OrderItemInput {
  itemNum: Int!
  quantity: Int!
}

input ReviewInput {
  itemNum: Int!
  custNum: Int!
  rating: Int!
  comment: String
}

# Response-typer med feilhåndtering
type OrderPayload {
  order: Order
  errors: [Error!]
}

type ItemPayload {
  item: Item
  errors: [Error!]
}

type Error {
  code: String!
  message: String!
  field: String
}
