MATCH (proc:PRODUCE)
  <-[:Deduce]-(CreateStatementContext:Node)
  -[:Children]->(CreateProcedureContext:Node)
  -[:Children]->(CompoundStatementContext:Node)
  -[:Children]->(UnlabeledBlockContext:Node)
  -[:Children]->(BeginEndBlockContext:Node)
  -[:Children]->(CompoundStatementListContext:Node)
  -[:Deduce]->(actions:ACTIONS)
where CreateStatementContext.message = "CreateStatementContext"
  and CreateProcedureContext.message = "CreateProcedureContext"
  and CompoundStatementContext.message = "CompoundStatementContext"
  and UnlabeledBlockContext.message = "UnlabeledBlockContext"
  and BeginEndBlockContext.message = "BeginEndBlockContext"
  and CompoundStatementListContext.message = "CompoundStatementListContext"
MERGE (proc)-[:Children]->(actions)
;


