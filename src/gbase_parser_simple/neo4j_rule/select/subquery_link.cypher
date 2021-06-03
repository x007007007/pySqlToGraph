MATCH (table:TABLE)<-[:Deduce]-(TableReferenceContext)
  -[:table_link]->(TableFactorContext:Node)
  -[:Children]->(DerivedTableContext:Node)
  -[:Children]->(SubqueryContext:Node)
  -[:Deduce]->(select:ACTION)
WHERE
  TableReferenceContext.message = "TableReferenceContext"
  and TableFactorContext.message = "TableFactorContext"
  and DerivedTableContext.message = "DerivedTableContext"
  and SubqueryContext.message = "SubqueryContext"
  and select.type = "select"
MERGE (table)-[:subquery]->(select)
;