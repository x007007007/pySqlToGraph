MATCH (table:TABLE)
  -[:Shortcut]->(SubqueryContext:Node)
  -[:Deduce]->(select:ACTION)
WHERE SubqueryContext.message = "SubqueryContext"
  and select.type = "select"
MERGE (table)-[:subquery]->(select)
;
