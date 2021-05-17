MATCH p=(SelectItemListContext:Node)
  -[c:Children]->(SelectItemContext:Node)
where SelectItemListContext.message = "SelectItemListContext"
  and SelectItemContext.message = "SelectItemContext"
MERGE (SelectItemListContext)-[:Deduce]->(outs:OUTS)
MERGE (SelectItemContext)-[:Deduce]->(out:OUT {order: c.order / 2})
MERGE (outs)-[:Children {order: c.order}]->(out)
;

MATCH p=(out:OUT)<-[:Deduce]-(SelectItemContext:Node)
  -[:Children]->(SelectAliasContext:Node)
  -[:Children]->(IdentifierContext:Node)
WHERE SelectItemContext.message = "SelectItemContext"
  and SelectAliasContext.message = "SelectAliasContext"
  and IdentifierContext.message = "IdentifierContext"
SET out.name = IdentifierContext.value
SET SelectItemContext.delete = TRUE
SET SelectAliasContext.delete = TRUE
SET IdentifierContext.delete = TRUE
;

MATCH p=(out:OUT)<-[:Deduce]-(SelectItemContext:Node)
  -[:Children *]->(ColumnRefContext:Node)
  -[:Children]->(FieldIdentifierContext:Node)
  -[:Children]->(QualifiedIdentifierContext:Node)
WHERE ColumnRefContext.message = "ColumnRefContext"
  and FieldIdentifierContext.message = "FieldIdentifierContext"
  and QualifiedIdentifierContext.message = "QualifiedIdentifierContext"
MERGE (ColumnRefContext)-[:Effect]->(out)
FOREACH (n IN nodes(p) | SET n.delete = true)
SET ColumnRefContext.namespace = QualifiedIdentifierContext.namespace
SET ColumnRefContext.name = QualifiedIdentifierContext.name
REMOVE out.delete
REMOVE ColumnRefContext.delete
;
