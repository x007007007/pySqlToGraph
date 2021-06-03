MATCH (CreateProcedureContext:Node)
  -[:Children]->(end:EndNode)
WHERE CreateProcedureContext.message = "CreateProcedureContext"
set CreateProcedureContext.delete = TRUE
set end.delete = TRUE;



MATCH (proc:ACTION)
  <-[:Deduce]-(CreateStatementContext:Node)
  -[:Children *..]->(CompoundStatementListContext:Node)
  -[:Deduce]->(:ACTIONS)
WHERE CreateStatementContext.message = "CreateStatementContext"
  and CompoundStatementListContext.message = "CompoundStatementListContext"
  and proc.type = "create_procduce"
MATCH p1=(CreateStatementContext)-[:Children *..]->(CompoundStatementListContext)
FOREACH (n in nodes(p1) | set n.delete = TRUE)


