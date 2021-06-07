MATCH p=(TableReferenceContext:Node)
  -[:table_link *0..]->(SingleTableContext:Node)
where TableReferenceContext.message = "TableReferenceContext"
  and SingleTableContext.message = "SingleTableContext"
MERGE (table:TABLE {
    type: "ref",
    alias_name: SingleTableContext.alias_name,
    ref_name: SingleTableContext.ref_name,
    ref_namespace: SingleTableContext.ref_namespace,
    alias_name_frag: SingleTableContext.alias_name
})<-[:Deduce]-(TableReferenceContext)
MERGE (table)<-[:Deduce]-(SingleTableContext)
FOREACH (n in nodes(p)|set n.delete = TRUE)
set TableReferenceContext.delete = FALSE
;



