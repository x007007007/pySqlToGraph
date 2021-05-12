MATCH p=(dotIdentifierContext:Node)
  -[:Children]->(identifierContext:Node)
  -[:Children]->(pureIdentifierContext:Node)
  -[:Children]->(terminalNodeImpl:EndNode)
  where dotIdentifierContext.message = "DotIdentifierContext"
  and identifierContext.message = "IdentifierContext"
  and pureIdentifierContext.message = "PureIdentifierContext"
Set dotIdentifierContext.value = terminalNodeImpl.text
FOREACH (n IN nodes(p) | SET n.delete = true)
set dotIdentifierContext.delete = false
