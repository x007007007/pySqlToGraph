MATCH (InsertStatementContext:Node)
  -[:Children]->(TableRefContext:Node)
  -[:Children]->(QualifiedIdentifierContext:Node)
WHERE InsertStatementContext.message = "InsertStatementContext"
  and TableRefContext.message = "TableRefContext"
  and QualifiedIdentifierContext.message = "QualifiedIdentifierContext"
MERGE (InsertStatementContext)
  -[:Deduce]->(:ACTION {type: 'insert'})
  -[:Children]->(table:TABLE {
  ref_namespace: QualifiedIdentifierContext.namespace,
  ref_name: QualifiedIdentifierContext.name
})<-[:Deduce]-(TableRefContext)
SET QualifiedIdentifierContext.delete = TRUE
;



