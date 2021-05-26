MATCH (insert:ACTION)
  <-[:Deduce]-(InsertStatementContext:Node)
  -[:Children]->(InsertQueryExpressionContext:Node)
  -[:Deduce]->(select:ACTION)
WHERE insert.type = "insert"
  and select.type = 'select'
  and InsertStatementContext.message = "InsertStatementContext"
  and InsertQueryExpressionContext.message = "InsertQueryExpressionContext"
MERGE (insert)-[:Children]->(select)
SET InsertQueryExpressionContext.delete = TRUE
;
