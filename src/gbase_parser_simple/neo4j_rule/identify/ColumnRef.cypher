MATCH (ColumnRefContext:Node)
  -[:Children]->(FieldIdentifierContext:Node)
  -[:Children]->(QualifiedIdentifierContext:Node)
WHERE ColumnRefContext.message = "ColumnRefContext"
  and FieldIdentifierContext.message = "FieldIdentifierContext"
  and QualifiedIdentifierContext.message = "QualifiedIdentifierContext"
set QualifiedIdentifierContext.delete = TRUE
set FieldIdentifierContext.delete = TRUE
set ColumnRefContext.name = QualifiedIdentifierContext.name
set ColumnRefContext.namespace = QualifiedIdentifierContext.namespace
;