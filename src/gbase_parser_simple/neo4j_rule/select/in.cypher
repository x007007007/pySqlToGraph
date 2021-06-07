MATCH (FromClauseContext:Node)-[:Children]->(TableReferenceListContext:Node)
  -[c:Children]->(TableReferenceContext:Node)
  -[:Deduce]->(table:TABLE)
  <-[:Children]-(tables:TABLES)
where FromClauseContext.message = "FromClauseContext"
  and TableReferenceListContext.message = "TableReferenceListContext"
  and TableReferenceContext.message = "TableReferenceContext"
MERGE (FromClauseContext)-[:Deduce]->(tables)
MERGE (tables)-[r:Children ]->(table)
SET r.order = c.order
set TableReferenceListContext.delete = True
set TableReferenceContext.delete = True
;