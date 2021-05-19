MATCH (TableReferenceContext:Node)
  -[:Children]->(TableFactorContext:Node)
  -[:Children]->(SingleTableContext:Node)
WHERE TableReferenceContext.message = "TableReferenceContext"
  and TableFactorContext.message = "TableFactorContext"
  and SingleTableContext.message = "SingleTableContext"
MERGE (table:Table {
  alias_name: TableReferenceContext.alias_name
  ref_name: TableReferenceContext.ref_name
  ref_namespace: TableReferenceContext.ref_namespace
})<-[:Deduce]-(TableReferenceContext)
set TableFactorContext.delete = TRUE
set SingleTableContext.delete = TRUE
;