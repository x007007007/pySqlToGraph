MATCH p=(insert:ACTION)
  <-[:Deduce]-(InsertStatementContext:Node)
  -[:Children]->(InsertFromConstructorContext:Node)
  -[:Children]->(InsertValuesContext:Node)
  -[line:Children]->(ValueListContext:Node)
  -[col:Children]->(ValuesContext:Node)
  -[:Children]->(subNode:Node)
  -[:expr_link *..]->(:Node)
  -[:Children]->(cared:Node)
  -[:Deduce]->(select:ACTION)
OPTIONAL MATCH pp1=(InsertStatementContext)
  -[:Children]->(InsertFromConstructorContext:Node)
  -[:Children]->(InsertValuesContext:Node)
  -[line:Children]->(ValueListContext:Node)
  -[col:Children]->(ValuesContext:Node)
  -[:Children]->(subNode:Node)
  -[:expr_link *..]->(:Node)
  -[:Children]->(cared:Node)
WHERE (InsertStatementContext.message = "InsertStatementContext"
  or
  InsertStatementContext.message = "MergeInsertClauseContext"
)
  and InsertFromConstructorContext.message = "InsertFromConstructorContext"
  and InsertValuesContext.message = "InsertValuesContext"
  and ValueListContext.message = "ValueListContext"
  and ValuesContext.message = "ValuesContext"
  and cared.message = "SubqueryContext"
MERGE (input:INPUTs)<-[:Deduce]-(InsertValuesContext)
MERGE (row:ROW {order: line.order})<-[:Deduce]-(ValueListContext)
MERGE (cell:CELL {order: col.order})<-[:Deduce]-(ValuesContext)
MERGE (input)-[:Children]->(row)
MERGE (cell)-[:IN]->(select)
MERGE (row)-[:Children]->(cell)
MERGE (insert)-[:Children]->(input)
FOREACH (n in nodes(pp1) | set n.delete = TRUE)

;