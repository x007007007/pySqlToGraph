MATCH (InsertStatementContext:Node)
  -[:Children]->(InsertQueryExpressionContext:Node)
  -[:Children]->(FieldsContext:Node)
  -[r:Children]->(InsertIdentifierContext:Node)
  -[:Children]->(ColumnRefContext:Node)
WHERE InsertStatementContext.message = 'InsertStatementContext'
  AND InsertQueryExpressionContext.message = 'InsertQueryExpressionContext'
  AND FieldsContext.message = 'FieldsContext'
  AND InsertIdentifierContext.message = 'InsertIdentifierContext'
  AND ColumnRefContext.message = 'ColumnRefContext'
OPTIONAL MATCH (InsertStatementContext)
  -[:Deduce]->(insert:ACTION)
  -[:Children]->(table:TABLE)
WHERE insert.type = "insert"
MERGE (table)-[:Children]->(field: FIELD {
  order: r.order / 2 ,
  ref_name: ColumnRefContext.name,
  ref_namespace: ColumnRefContext.namespace
}) <-[:Deduce]-(InsertIdentifierContext)
SET InsertIdentifierContext.delete = TRUE
SET ColumnRefContext.delete = TRUE
;

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
