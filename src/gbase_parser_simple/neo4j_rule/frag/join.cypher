MATCH (table:Table)
  <-[:Deduce]-(tableRef:Node)
  -[jo_link:Children]->(JoinedTableContext:Node)
  -[:Children]->(TableReferenceContext:Node)
  -[:Children]->(TableFactorContext:Node)
  -[:Children]->(SingleTableContext:Node)
WHERE tableRef.message = "TableFactorContext"
  and JoinedTableContext.message = "JoinedTableContext"
  and TableFactorContext.message = "TableFactorContext"
  and SingleTableContext.message = "SingleTableContext"
MERGE (jo:JOIN)<-[:Deduce]-(JoinedTableContext)
MERGE (jo)<-[:Children {order: jo_link.order}]-(table)
set jo.alias_name = SingleTableContext.alias_name
set jo.ref_name = SingleTableContext.ref_name
set jo.ref_namespace = SingleTableContext.ref_namespace
set SingleTableContext.delete = true
set TableFactorContext.delete = true
set TableReferenceContext.delete = ture
set JoinedTableContext.delete = ture
;


