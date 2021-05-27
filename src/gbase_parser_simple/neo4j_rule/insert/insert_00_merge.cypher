MATCH (MergeInsertClauseContext:Node)
  <-[:Children]->(MergeIntoStatementContext:Node)
  -[table_link:Children]->(TableReferenceContext:Node)
  -[:Deduce]->(table:TABLE)
WHERE MergeInsertClauseContext.message = "MergeInsertClauseContext"
  and MergeIntoStatementContext.message = "MergeIntoStatementContext"
  and TableReferenceContext.message = "TableReferenceContext"
  and table_link.order = 2
MERGE (MergeInsertClauseContext)
  -[:Deduce]->(:ACTION {type: 'insert'})
  -[:Children]->(table)
;



