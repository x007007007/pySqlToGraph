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

MATCH p=(SelectStatementContext:Node)
  -[:link_query *..]->(QueryExpressionContext:Node)
  -[:Children]->(QueryExpressionBodyContext:Node)
  -[:Children]->(QueryPrimaryContext:Node)
  -[:Children]->(QuerySpecificationContext:Node)
  -[:Children]->(SelectItemListContext:Node)
  -[:Deduce]->(outs:OUTS)
WHERE (SelectStatementContext.message = 'SelectStatementContext'
  or SelectStatementContext.message = 'SubqueryContext'
  or SelectStatementContext.message = "InsertQueryExpressionContext"
  or SelectStatementContext.message = "QueryExpressionOrParensContext"
)
  and QueryExpressionContext.message = 'QueryExpressionContext'
  and QueryExpressionBodyContext.message = 'QueryExpressionBodyContext'
  and QueryPrimaryContext.message = 'QueryPrimaryContext'
  and QuerySpecificationContext.message = 'QuerySpecificationContext'
  and SelectItemListContext.message = 'SelectItemListContext'
MERGE (rule:ACTION {type: "select"})
  <-[:Deduce]-(SelectStatementContext)
MERGE (rule)-[:Children]->(outs)
FOREACH (n in nodes(p)| set n.delete = TRUE)
set SelectStatementContext.delete = FALSE
remove outs.delete
;
