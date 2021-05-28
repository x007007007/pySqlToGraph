MATCH (MergeIntoStatementContext:Node)-[:Children]->(e:EndNode)
WHERE MergeIntoStatementContext.message = "MergeIntoStatementContext"
SET e.delete = TRUE
;


MATCH (merge:ACTION {type: 'merge'})
  <-[:Deduce]-(MergeIntoStatementContext:Node)
WHERE MergeIntoStatementContext.message = "MergeIntoStatementContext"
OPTIONAL MATCH p=(MergeIntoStatementContext)-[:Children *..]->(:EndNode)
FOREACH (n in nodes(p) | set n.delete = True)
;