MATCH p1=(UpdateElementContext:Node)
  -[:Children]->(ExprIsContext:Node)
  -[:expr_link *0..]->(expr_end:Node)
  -[:Children]->(ColumnRefContext:Node)
WHERE UpdateElementContext.message = "UpdateElementContext"
  and ExprIsContext.message = "ExprIsContext"
  and ColumnRefContext.message = "ColumnRefContext"
OPTIONAL MATCH p2=(UpdateElementContext)
  -[:Children]->(ColumnRefContextNew:Node)
WHERE ColumnRefContextNew.message = "ColumnRefContext"
MERGE (update_field:FIELD {
      ref_name: ColumnRefContextNew.name,
      ref_namespace: ColumnRefContextNew.namespace
    }
  )<-[:Deduce]-(UpdateElementContext)
MERGE (update_field)
  <-[:effect]-(effect_field:FIELD {
      ref_name: ColumnRefContext.name,
      ref_namespace: ColumnRefContext.namespace
    }
  )
  <-[:Deduce]-(ColumnRefContext)
FOREACH (
  n in nodes(p1) |
  SET n.delete = FALSE
)
FOREACH (
  n in nodes(p2) |
  SET n.delete = FALSE
)
;


MATCH (UpdateStatementContext:Node)
  -[:Children]->(UpdateListContext:Node)
  -[:Children]->(UpdateElementContext:Node)
  -[:Deduce]->(update_field:FIELD)
WHERE UpdateStatementContext.message = "UpdateStatementContext"
  and UpdateListContext.message = "UpdateListContext"
  and UpdateElementContext.message = "UpdateElementContext"
OPTIONAL MATCH (UpdateStatementContext)
  -[:Children]->(TableReferenceListContext:Node)
  -[:Deduce]->(tables:TABLES)
WHERE TableReferenceListContext.message = "TableReferenceListContext"
MERGE (update:UPDATE)<-[:Deduce]-(UpdateStatementContext)
MERGE (write:WRITE)<-[:Deduce]-(UpdateListContext)
MERGE (write)-[:Children]->(update_field)
MERGE (update)-[:Children]->(write)
MERGE (update)-[:Children]->(tables)
;

