MATCH p=(dotIdentifierContext:Node)
  -[:Children]->(terminalNodeImpl:EndNode)
  where dotIdentifierContext.message = "DotIdentifierContext"
  and terminalNodeImpl.text = "."
set terminalNodeImpl.delete = true
