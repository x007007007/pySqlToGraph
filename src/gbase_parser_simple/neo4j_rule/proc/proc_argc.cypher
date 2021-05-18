MATCH (CreateProcedureContext:Node)
  -[:Children]->(syms:EndNode)
set syms.delete = TRUE
;

MATCH (CreateProcedureContext:Node)
  -[:Children]->(ProcedureParameterContext:Node)
  -[:Children]->(QualifiedIdentifierContext:Node)
where CreateProcedureContext.message = "CreateProcedureContext"
  and ProcedureParameterContext.message = "ProcedureParameterContext"
  and QualifiedIdentifierContext.message = "QualifiedIdentifierContext"
MERGE
  (argu:Argument {name: QualifiedIdentifierContext.name})<-[:Reduce]-(ProcedureParameterContext)
set QualifiedIdentifierContext.delete = true
set ProcedureParameterContext.delete = true
;

MATCH (CreateProcedureContext:Node)
  -[:Children]->(ProcedureParameterContext:Node)
  -[:Children]->(FunctionParameterContext:Node)
  -[:Children]->(ParameterNameContext:Node)
  -[:Children]->(IdentifierContext:Node)
where CreateProcedureContext.message = "CreateProcedureContext"
  and ProcedureParameterContext.message = "ProcedureParameterContext"
  and FunctionParameterContext.message = "FunctionParameterContext"
  and ParameterNameContext.message = "ParameterNameContext"
  and IdentifierContext.message = "IdentifierContext"
MERGE
  (argu:Argument {name: IdentifierContext.value})<-[:Reduce]-(ProcedureParameterContext)
set ProcedureParameterContext.delete = true
set FunctionParameterContext.delete = true
set ParameterNameContext.delete = true
set IdentifierContext.delete = true
;


MATCH (argv:Argument)
  <-[:Reduce]-(ProcedureParameterContext:Node)
  -[:Children]->(in_or_out:EndNode)
where ProcedureParameterContext.message = "ProcedureParameterContext"
set argv.directive = toLower(in_or_out.text)
;


