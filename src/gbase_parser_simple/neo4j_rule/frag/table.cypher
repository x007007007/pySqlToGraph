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

MATCH p=(TableReferenceListContext:Node)
  -[c:Children]->(TableReferenceContext:Node)
  -[:Deduce]->(table:TABLE)
where TableReferenceContext.message = "TableReferenceContext"
  and TableReferenceListContext.message = "TableReferenceListContext"
MERGE (TableReferenceListContext)
  -[:Deduce]->(tables:TABLES)
  -[:Children]->(table)
SET table.order = c.order
;


MATCH (:TABLES)<-[:Deduce]-(:Node)-[:Children]->(c:Node)
OPTIONAL MATCH p=(c)-[:Children *0..]->(:EndNode)
FOREACH (n in nodes(p) | SET n.delete=True)
;