MATCH (merge:ACTION {type: 'merge'})
  <-[:Deduce]-(MergeIntoStatementContext:Node)
  -[:Children]->(MergeUpdateClauseContext:Node)
  -[:Deduce]->(update:ACTION {type:"update"})
WHERE MergeIntoStatementContext.message = "MergeIntoStatementContext"
  and MergeUpdateClauseContext.message = "MergeUpdateClauseContext"
MERGE (merge)-[:update]->(update)
;


MATCH (merge:ACTION {type: 'merge'})
  <-[:Deduce]-(MergeIntoStatementContext:Node)
  -[use_link:Children]->(TableReferenceContext:Node)
  -[:Deduce]->(table:TABLE)
WHERE use_link.order = 4
  and MergeIntoStatementContext.message = "MergeIntoStatementContext"
  and TableReferenceContext.message = "TableReferenceContext"
MERGE (merge)-[:use]->(table)
;
