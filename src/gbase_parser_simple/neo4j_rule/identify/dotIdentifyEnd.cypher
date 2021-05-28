MATCH p=(dotIdentifierContext:Node)
  -[:Children]->(terminalNodeImpl:EndNode)
  where dotIdentifierContext.message = "DotIdentifierContext"
  and terminalNodeImpl.text = "."
set terminalNodeImpl.delete = true
;

MATCH p=(DotIdentifierContext:Node)
  -[:Children]->(IdentifierContext:Node)
  where DotIdentifierContext.message = "DotIdentifierContext"
  and IdentifierContext.message = "IdentifierContext"
set IdentifierContext.delete = true
set DotIdentifierContext.value = IdentifierContext.value
;

