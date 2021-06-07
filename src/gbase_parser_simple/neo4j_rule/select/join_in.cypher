MATCH p=(FromClauseContext:Node)
  -[:Children]->(TableReferenceListContext:Node)
  -[c:Children]->(TableReferenceContext:Node)
  -[:Children]->(JoinedTableContext:Node)
  -[:Children]->(TableReferenceContext1:Node)
  -[:Deduce]->(table:TABLE)
  <-[:Children]-(tables:TABLES)
WHERE
  FromClauseContext.message = "FromClauseContext"
  and TableReferenceListContext.message = "TableReferenceListContext"
  and TableReferenceContext.message = "TableReferenceContext"
  and JoinedTableContext.message = "JoinedTableContext"
  and TableReferenceContext1.message = "TableReferenceContext"
OPTIONAL MATCH (JoinedTableContext)
  -[:Children]->(TableReferenceContext:Node)
OPTIONAL MATCH (JoinedTableContext)-[:Children]->(join_end_node:EndNode)
OPTIONAL MATCH where_join=(JoinedTableContext)-[:Children]->(ExprIsContext:Node)
  -[:Children *]->(end:EndNode)
MERGE (FromClauseContext)
  -[:Deduce]->(tables)
MERGE (table)<-[:Deduce]-(JoinedTableContext)
FOREACH (n in nodes(where_join) | set n.delete=true)
set join_end_node.delete = TRUE
