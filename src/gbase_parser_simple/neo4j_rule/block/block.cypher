MATCH (BeginEndBlockContext:Node)
  -[:Children]->(CompoundStatementListContext:Node)
  -[r2:Children]->(CompoundStatementContext:Node)
  -[:Children *1..3]->()
  -[:Deduce]->(action:ACTION)
WHERE BeginEndBlockContext.message = "BeginEndBlockContext"
  and CompoundStatementListContext.message = "CompoundStatementListContext"
MERGE (block:Block)
  <-[:Deduce]-[BeginEndBlockContext]
MERGE (block)-[:Children]->(action)
set action.order = r2.action / 2
;


