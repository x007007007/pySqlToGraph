MATCH p=(QualifiedIdentifier:Node)
  -[:Children]->(IdentifierContext:Node)
  where QualifiedIdentifier.message = "QualifiedIdentifier"
  and pureIdentifierContext.message = "IdentifierContext"
Set QualifiedIdentifier.value = IdentifierContext.value
set IdentifierContext.delete = true
;


MATCH p=(QualifiedIdentifier:Node)
  -[:Children]->(IdentifierContext:Node)
  where QualifiedIdentifier.message = "QualifiedIdentifier"
  and pureIdentifierContext.message = "IdentifierContext"
Set QualifiedIdentifier.value = IdentifierContext.value
set IdentifierContext.delete = true

