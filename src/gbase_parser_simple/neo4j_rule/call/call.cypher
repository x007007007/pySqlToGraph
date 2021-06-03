MATCH (CallStatementContext:Node)
  -[:Children]->(ProcedureRefContext:Node)
  -[:Children]->(QualifiedIdentifierContext:Node)
where CallStatementContext.message = "CallStatementContext"
  and ProcedureRefContext.message = "ProcedureRefContext"
  and QualifiedIdentifierContext.message = "QualifiedIdentifierContext"
OPTIONAL MATCH p=(ProcedureRefContext)-[:Children *..]->(:EndNode)
MERGE (call:ACTION {type:"call"})<-[:Deduce]-(CallStatementContext)
MERGE (call)-[:Children]->(QualifiedIdentifierContext)
FOREACH (n in nodes(p)| set n.delete = TRUE)

;