MATCH p=(TableReferenceContext:Node)
  -[:table_link *0..]->(SingleTableContext:Node)
where TableReferenceContext.message = "TableReferenceContext"
  and SingleTableContext.message = "SingleTableContext"
MERGE (table:TABLE {
    type: "ref",
    alias_name: SingleTableContext.alias_name,
    ref_name: SingleTableContext.ref_name,
    ref_namespace: SingleTableContext.ref_namespace
})<-[:Deduce]-(TableReferenceContext)
MERGE (table)<-[:Deduce]-(SingleTableContext)
;

MATCH p=(TableReferenceListContext:Node)
  -[c:Children]->(TableReferenceContext:Node)
where TableReferenceContext.message = "TableReferenceContext"
  and TableReferenceListContext.message = "TableReferenceListContext"
OPTIONAL MATCH (TableReferenceContext)
  -[:Deduce]->(table:TABLE)
MERGE (TableReferenceListContext)
  -[:Deduce]->(tables:TABLES)
  -[:Children]->(table)
SET table.order = c.order
;


MATCH (:TABLES)<-[:Deduce]-(:Node)-[:Children]->(c:Node)
OPTIONAL MATCH p=(c)-[:Children *0..]->(:EndNode)
FOREACH (n in nodes(p) | SET n.delete=True)
;