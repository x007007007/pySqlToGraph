MATCH (FromClauseContext:Node)-[:Children]->(TableReferenceListContext:Node)
  -[c:Children]->(TableReferenceContext:Node)
  -[:Children]->(TableFactorContext:Node)
  -[:Children]->(SingleTableContext:Node)
where FromClauseContext.message = "FromClauseContext"
  and TableReferenceListContext.message = "TableReferenceListContext"
  and TableReferenceContext.message = "TableReferenceContext"
  and TableFactorContext.message = "TableFactorContext"
  and SingleTableContext.message = "SingleTableContext"
MERGE (FromClauseContext)-[:Deduce]->(inputs:INPUTs)
MERGE (TableReferenceContext)-[:Deduce]->(input:INPUT {
    order: c.order / 2,
    ref_namespace: SingleTableContext.ref_namespace,
    ref_name:  SingleTableContext.ref_name,
    alias_name: SingleTableContext.alias_name
})
MERGE (inputs)-[:Children {order: c.order}]->(input)
set TableReferenceListContext.delete = True
set TableReferenceContext.delete = True
set TableFactorContext.delete = True
set SingleTableContext.delete = True
;