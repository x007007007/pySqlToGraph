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
    -[:Children *1..3]->()
    -[:Deduce]->(action:ACTION)
WHERE root.message <> "QueriesContext"
  and QueriesContext.message = "QueriesContext"
  and QueryContext.message = "QueryContext"
  and QueryContextEnd.message = "QueryContext"
OPtional MATCH p2=(QueryContext)
    <-[:next *..]-(QueryContextEnd)
MERGE (root)
  -[:Deduce]->(actions:ACTIONS)
MERGE (actions)
  -[:Children {
    order: -length(p2)
  }]->(action)