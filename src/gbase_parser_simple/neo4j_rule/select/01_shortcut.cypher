MATCH (QueryExpressionParensContext:Node)
  -[:Children]->(QueryExpressionParensContextN:Node)
WHERE (
    QueryExpressionParensContext.message = "SelectStatementContext"
    OR QueryExpressionParensContext.message = "SubqueryContext"
    OR QueryExpressionParensContext.message = 'QueryExpressionParensContext'
    OR QueryExpressionParensContext.message = 'QueryExpressionOrParensContext'
    OR QueryExpressionParensContext.message = 'QueryExpressionContext'
  ) AND (
    QueryExpressionParensContextN.message = 'QueryExpressionParensContext'
    OR QueryExpressionParensContextN.message =  'QueryExpressionContext'
  )
MERGE (QueryExpressionParensContext)-[:link_query]->(QueryExpressionParensContextN)
;

MATCH (QueryExpressionParensContext:Node)
  -[:Children]->(QueryExpressionParensContextN:Node)
WHERE QueryExpressionParensContext.message = "InsertQueryExpressionContext"
  and QueryExpressionParensContextN.message = "QueryExpressionOrParensContext"
MERGE (QueryExpressionParensContext)-[:link_query]->(QueryExpressionParensContextN)
;