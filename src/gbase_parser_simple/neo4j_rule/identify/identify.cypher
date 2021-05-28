MATCH p=(IdentifierContext:Node)
  -[:Children]->(pureIdentifierContext:Node)
  -[:Children]->(terminalNodeImpl:EndNode)
  where IdentifierContext.message = "IdentifierContext"
  and pureIdentifierContext.message = "PureIdentifierContext"
Set IdentifierContext.value = terminalNodeImpl.text
set pureIdentifierContext.delete = true
set terminalNodeImpl.delete = true
;

MATCH p=(IdentifierContext:Node)
  -[:Children]->(IdentifierKeywordContext:Node)
  -[:Children *..]->(terminalNodeImpl:EndNode)
where IdentifierContext.message = "IdentifierContext"
  and IdentifierKeywordContext.message = "IdentifierKeywordContext"
Set IdentifierContext.value = terminalNodeImpl.text
FOREACH (n in nodes(p) | set n.delete = true)
set IdentifierContext.delete = false
;