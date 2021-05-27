MATCH (InsertStatementContext:Node)
  -[:Children]->(InsertQueryExpressionContext:Node)
  -[:Children]->(FieldsContext:Node)
  -[r:Children]->(InsertIdentifierContext:Node)
  -[:Children]->(ColumnRefContext:Node)
WHERE (InsertStatementContext.message = "InsertStatementContext"
    or
    InsertStatementContext.message = "MergeInsertClauseContext"
  )
  AND (
    InsertQueryExpressionContext.message = 'InsertQueryExpressionContext'
    OR InsertQueryExpressionContext.message = 'InsertFromConstructorContext'
  )
  AND FieldsContext.message = 'FieldsContext'
  AND InsertIdentifierContext.message = 'InsertIdentifierContext'
  AND ColumnRefContext.message = 'ColumnRefContext'
OPTIONAL MATCH (InsertStatementContext)
  -[:Deduce]->(insert:ACTION)
  -[:Children]->(table:TABLE)
WHERE insert.type = 'insert'
MERGE (field: FIELD {
  order: r.order / 2 ,
  ref_name: ColumnRefContext.name,
  ref_namespace: ColumnRefContext.namespace
}) <-[:Deduce]-(InsertIdentifierContext)
MERGE (table)-[:Children]->(field)
SET InsertIdentifierContext.delete = true
SET ColumnRefContext.delete = true
;