MATCH p=(TableReferenceListContext:Node)
  -[c:Children]->(TableReferenceContext:Node)
  -[:Deduce]->(table:TABLE)
where TableReferenceContext.message = "TableReferenceContext"
  and TableReferenceListContext.message = "TableReferenceListContext"
MERGE (TableReferenceListContext)
  -[:Deduce]->(tables:TABLES)
MERGE (tables)
  -[:Children]->(table)
SET table.order = c.order
;

MATCH (:TABLES)<-[:Deduce]-(:Node)-[:Children]->(c:Node)
OPTIONAL MATCH p=(c)-[:Children *0..]->(:EndNode)
FOREACH (n in nodes(p) | SET n.delete=True)
;