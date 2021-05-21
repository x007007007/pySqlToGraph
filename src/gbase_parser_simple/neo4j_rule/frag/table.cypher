MATCH p=(TableReferenceListContext:Node)
  -[c:Children]->(TableReferenceContext:Node)
  -[:table_link *0..]->(SingleTableContext:Node)
where SingleTableContext.message = "SingleTableContext"
  and TableReferenceListContext.message = "TableReferenceListContext"
MERGE (TableReferenceListContext)-[:Deduce]->(tables:TABLES)
MERGE (SingleTableContext)-[:Deduce]->(table:TABLE {
        alias_name: SingleTableContext.alias_name,
        ref_name: SingleTableContext.ref_name,
        ref_namespace: SingleTableContext.ref_namespace,
        order: c.order
    })
    <-[:Children]-(tables)

;


MATCH (:TABLES)<-[:Deduce]-(:Node)-[:Children]->(c:Node)
OPTIONAL MATCH p=(c)-[:Children *0..]->(:EndNode)
FOREACH (n in nodes(p) | SET n.delete=True)
;