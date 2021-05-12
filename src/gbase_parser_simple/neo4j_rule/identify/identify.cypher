MATCH p=(IdentifierContext:Node)
  -[:Children]->(pureIdentifierContext:Node)
  -[:Children]->(terminalNodeImpl:EndNode)
  where IdentifierContext.message = "IdentifierContext"
  and pureIdentifierContext.message = "PureIdentifierContext"
Set IdentifierContext.value = terminalNodeImpl.text
set pureIdentifierContext.delete = true
set terminalNodeImpl.delete = true

