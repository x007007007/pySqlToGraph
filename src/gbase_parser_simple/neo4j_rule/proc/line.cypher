MATCH (x:Node)
  <-[:Children]-(a:Node)
  -[:Children]->(b:Node)
  -[:Children]->(c:Node)
WHERE a.message = "QueriesContext"
  and b.message = "QueriesContext"
  and c.message = "QueryContext"
  and x.message = "QueryContext"
MERGE (c)-[:next]->(x)
;

MATCH p=(root)
    -[:Children]->(QueriesContext:Node)
    -[:Children]->(QueryContext:Node)
    <-[:next *..]-(QueryContextEnd:Node)
    -[:Children]->(SimpleStatementContext:Node)
    -[:Children]->(something:Node)
    -[:Deduce]->(action:ACTION)
WHERE root.message = "root"
  and QueriesContext.message = "QueriesContext"
  and QueryContext.message = "QueryContext"
  and QueryContextEnd.message = "QueryContext"
  and SimpleStatementContext.message = "SimpleStatementContext"
OPTIONAL MATCH p1=(QueryContext)
    <-[:next *..]-(QueryContextEnd)
MERGE (root)
  -[:Deduce]->(actions:ACTIONS)
MERGE (actions)
  -[:Children {
    order: -length(p1)
  }]->(action)