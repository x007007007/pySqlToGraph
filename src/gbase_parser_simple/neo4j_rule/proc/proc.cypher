MATCH (CreateStatementContext:Node)
  -[:Children]->(CreateProcedureContext:Node)
  -[:Children]->(ProcedureNameContext:Node)
  -[:Children]->(QualifiedIdentifierContext:Node)
where CreateStatementContext.message = "CreateStatementContext"
  and ProcedureNameContext.message = "ProcedureNameContext"
  and QualifiedIdentifierContext.message = "QualifiedIdentifierContext"
OPTIONAL MATCH (CreateProcedureContext)
  -[:Children]->(ProcedureParameterContext:Node)
  -[:Reduce]->(argv:Argument)
where ProcedureParameterContext.message = "ProcedureParameterContext"
MERGE (CreateStatementContext)
  -[:Reduce]->(func:Func {
    name: QualifiedIdentifierContext.name,
    namespace: QualifiedIdentifierContext.namespace
  })
MERGE (func)-[:Children]->(argv)
set QualifiedIdentifierContext.delete = true
set ProcedureNameContext.delete = true
set QualifiedIdentifierContext.delete = true
set ProcedureParameterContext.delete = true
;


