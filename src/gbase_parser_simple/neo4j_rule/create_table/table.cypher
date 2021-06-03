MATCH p=(CreateStatementContext:Node)
  -[:Children]->(CreateTableContext:Node)
  -[:Children]->(DuplicateAsQueryExpressionContext:Node)
  -[:Children]->(QueryExpressionOrParensContext:Node)
  -[:Deduce]->(select:ACTION)
where CreateStatementContext.message = "CreateStatementContext"
  and CreateTableContext.message = "CreateTableContext"
  and DuplicateAsQueryExpressionContext.message = "DuplicateAsQueryExpressionContext"
  and QueryExpressionOrParensContext.message = "QueryExpressionOrParensContext"
MATCH (CreateTableContext)
  -[:Children]->(TableNameContext:Node)
  -[:Children]->(QualifiedIdentifierContext:Node)
where TableNameContext.message = "TableNameContext"
  and QualifiedIdentifierContext.message = "QualifiedIdentifierContext"
MERGE (select_create:ACTION {type:'create_table_select'})
  <-[:Deduce]-(CreateStatementContext)
MERGE (select_create)-[:Children]->(select)
set DuplicateAsQueryExpressionContext.delete = TRUE
set CreateTableContext.delete = TRUE
set TableNameContext.delete = TRUE
set QualifiedIdentifierContext.delete = TRUE
set QueryExpressionOrParensContext.delete = TRUE
;