MATCH (FromClauseContext:Node)-[:Children]->(TableReferenceListContext:Node)
  -[c:Children]->(TableReferenceContext:Node)
  -[:Deduce]->(table:TABLE)
where FromClauseContext.message = "FromClauseContext"
  and TableReferenceListContext.message = "TableReferenceListContext"
  and TableReferenceContext.message = "TableReferenceContext"
MERGE (FromClauseContext)-[:Deduce]->(inputs:INPUTs)
MERGE (inputs)-[:Children {order: c.order}]->(table)
set TableReferenceListContext.delete = True
set TableReferenceContext.delete = True
;