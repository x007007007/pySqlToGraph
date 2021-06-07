MATCH p=(SingleTableContext:Node)
  -[:Children]->(TableRefContext:Node)
  -[:Children]->(QualifiedIdentifierContext:Node)
  where SingleTableContext.message = "SingleTableContext"
  and TableRefContext.message = "TableRefContext"
  and QualifiedIdentifierContext.message = "QualifiedIdentifierContext"
Set SingleTableContext.ref_name = QualifiedIdentifierContext.name
Set SingleTableContext.ref_namespace = QualifiedIdentifierContext.namespace
Set SingleTableContext.alias_name = (
  case size(QualifiedIdentifierContext.namespace) > 0
    when true then QualifiedIdentifierContext.namespace + "." + QualifiedIdentifierContext.name
    when false then QualifiedIdentifierContext.name
  end
)
Set SingleTableContext.alias_name_identify = SingleTableContext.alias_name
set TableRefContext.delete = true
set QualifiedIdentifierContext.delete = true
;


MATCH p=(SingleTableContext:Node)
  -[:Children]->(TableAliasContext:Node)
  -[:Children]->(IdentifierContext:Node)
  where SingleTableContext.message = "SingleTableContext"
  and TableAliasContext.message = "TableAliasContext"
  and IdentifierContext.message = "IdentifierContext"
Set SingleTableContext.alias_name = IdentifierContext.value
Set SingleTableContext.alias_name_ident = IdentifierContext.value
set TableAliasContext.delete = true
set IdentifierContext.delete = true
;

MATCH (TableAliasContext:Node)-[r:Children]->(AS_SYM:EndNode {text: 'as'})
SET AS_SYM.delete = true
;