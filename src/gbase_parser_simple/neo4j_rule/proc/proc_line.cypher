MATCH (CompoundStatementListContext:Node)
  -[:Children]->(CompoundStatementContext:Node)
  -[:Children]->(SimpleStatementContext:Node)
  -[:Children]->(end:Node)
  -[:Deduce]->(action:ACTION)
WHERE CompoundStatementListContext.message = "CompoundStatementListContext"
  and CompoundStatementContext.message = "CompoundStatementContext"
  and SimpleStatementContext.message = "SimpleStatementContext"
MERGE (actions:ACTIONS)<-[:Deduce]-(CompoundStatementListContext)
MERGE (actions)-[:Children]->(action)
set CompoundStatementContext.delete = TRUE
set SimpleStatementContext.delete = TRUE
set end.delete = TRUE
;



