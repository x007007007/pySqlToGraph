MATCH p=(FromClauseContext:Node)
  -[:Children]->(TableReferenceListContext:Node)
  -[c:Children]->(TableReferenceContext:Node)
  -[:Children]->(JoinedTableContext:Node)
  -[:Children]->(TableReferenceContext1:Node)
  -[:Children]->(TableFactorContext:Node)
  -[:Children]->(SingleTableContext:Node)
WHERE
  FromClauseContext.message = "FromClauseContext"
  and TableReferenceListContext.message = "TableReferenceListContext"
  and TableReferenceContext.message = "TableReferenceContext"
  and JoinedTableContext.message = "JoinedTableContext"
  and TableReferenceContext1.message = "TableReferenceContext"
  and TableFactorContext.message = "TableFactorContext"
  and SingleTableContext.message = "SingleTableContext"
OPTIONAL MATCH (JoinedTableContext)
  -[:Children]->(TableReferenceContext:Node)
  -[:Children]->(TableFactorContext:Node)
  -[:Children]->(SingleTableContext:Node)
OPTIONAL MATCH (JoinedTableContext)-[:Children]->(join_end_node:EndNode)
WHERE TableReferenceContext.message = "TableReferenceContext"
  and TableFactorContext.message = "TableFactorContext"
  and SingleTableContext.message = "SingleTableContext"
OPTIONAL MATCH where_join=(JoinedTableContext)-[:Children]->(ExprIsContext:Node)
  -[:Children *]->(end:EndNode)
MERGE (FromClauseContext)
  -[:Deduce]->(inputs:INPUTs)
MERGE (inputs)
  -[:Children]->(:INPUT {
    ref_name: SingleTableContext.ref_name,
    ref_namespace: SingleTableContext.ref_namespace,
    alias_name: SingleTableContext.alias_name
  })<-[:Deduce]-(JoinedTableContext)
FOREACH (n in nodes(where_join) | set n.delete=true)
set join_end_node.delete = TRUE
