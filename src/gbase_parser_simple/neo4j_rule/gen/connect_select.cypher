MATCH
  (outs:OUTS)
  <-[:Deduce]-(SelectItemListContext:Node)
  <-[:Children]-(QuerySpecificationContext:Node)
  -[:Children]->(FromClauseContext:Node)
  -[:Deduce]->(inputs:INPUTs)
OPTIONAL MATCH
  (QuerySpecificationContext)-[]->(select_sym:EndNode)
WHERE SelectItemListContext.message = 'SelectItemListContext'
  and QuerySpecificationContext.message = 'QuerySpecificationContext'
  and FromClauseContext.message = 'FromClauseContext'
MERGE (inputs)-[:Effect]-(outs)
set select_sym.delete = TRUE
;