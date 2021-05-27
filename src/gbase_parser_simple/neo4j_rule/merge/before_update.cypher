MATCH p=(MergeIntoStatementContext:Node)
        -[:Children]->(MergeUpdateClauseContext:Node)
WHERE MergeIntoStatementContext.message = "MergeIntoStatementContext"
  and MergeUpdateClauseContext.message = "MergeUpdateClauseContext"
OPTIONAL MATCH p1=(MergeIntoStatementContext)
  -[link:Children]->(TableReferenceContext:Node)
  -[:table_link *..]->(SingleTableContext:Node)
WHERE link.order = 2
  and TableReferenceContext.message = "TableReferenceContext"
  and SingleTableContext.message = "SingleTableContext"
MERGE (MergeIntoStatementContext)
  -[:Deduce]->(table:TABLE {
    alias_name: SingleTableContext.alias_name,
    ref_name: SingleTableContext.ref_name,
    ref_namespace: SingleTableContext.ref_namespace
  })
  <-[:Children]-(tables:TABLES)
  <-[:Deduce]-(MergeIntoStatementContext)
FOREACH (n in nodes(p1) | set n.delete = TRUE)
set MergeIntoStatementContext.delete = FALSE
;