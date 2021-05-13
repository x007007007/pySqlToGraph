MATCH p=(QualifiedIdentifier:Node)
  -[:Children]->(IdentifierContext:Node)
  where QualifiedIdentifier.message = "QualifiedIdentifierContext"
  and IdentifierContext.message = "IdentifierContext"
Set QualifiedIdentifier.name = IdentifierContext.value
Set QualifiedIdentifier.namespace = ""
set IdentifierContext.delete = true
;

MATCH p=(QualifiedIdentifier:Node)
  -[:Children]->(DotIdentifierContext:Node)
  where QualifiedIdentifier.message = "QualifiedIdentifierContext"
  and DotIdentifierContext.message = "DotIdentifierContext"
Set QualifiedIdentifier.namespace = (
  case exists(QualifiedIdentifier.name)
    when true then QualifiedIdentifier.name
    when false then ""
  end
)
Set QualifiedIdentifier.name = DotIdentifierContext.value
set DotIdentifierContext.delete = true