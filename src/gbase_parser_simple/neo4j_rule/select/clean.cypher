MATCH (parent:Node)
  -[:Children]->(QueryExpressionParensContext:Node)
  -[:Children]->(QueryExpressionContext:Node)
WHERE QueryExpressionParensContext.message = 'QueryExpressionParensContext'
  and QueryExpressionContext.message = "QueryExpressionContext"
MERGE (parent)-[:Children]->(QueryExpressionContext)
DETACH DELETE QueryExpressionParensContext
;


