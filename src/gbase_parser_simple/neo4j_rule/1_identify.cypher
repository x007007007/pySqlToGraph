MATCH p=(start:Node)-[:Children]->(dot:Node)-[:Children*3..3]->(finish:EndNode)
  where start.message = "QualifiedIdentifierContext"
  and dot.message = "DotIdentifierContext"
Merge (finish)-[:Shortcut]->(ident:Identifier) -[:Shortcut] ->(start)
Set ident.dot_name = finish.text
FOREACH (n IN nodes(p) | SET n.shortcut = true)
set start.shortcut = false
set finish.shortcut = false
;

MATCH p=(start:Node)-[:Children]->(ident1)-[:Children*]->(finish:EndNode)
  WHERE start.message = "QualifiedIdentifierContext"
  and ident1.message = "IdentifierContext"
MERGE (ident:Identifier) -[:Shortcut] ->(start)
MERGE (finish) -[:Shortcut]-> (ident)
set ident.row_name = finish.text
FOREACH (n IN nodes(p) | SET n.shortcut = true)
set start.shortcut = false
set finish.shortcut = false
;

MATCH (i:Identifier)
  WHERE exists(i.row_name) and exists(i.dot_name)
SET i.ns_name = i.row_name
SET i.name = i.dot_name
SET i.message = i.row_name + '.' + i.name
REMOVE i.row_name
REMOVE i.dot_name
;

MATCH (i:Identifier)
  WHERE exists(i.row_name) and not exists(i.dot_name)
SET i.name = i.row_name
SET i.ns = null
SET i.message = i.row_name
REMOVE i.row_name
;

MATCH p=(start:Node)-[:Children]->(finish:EndNode)
  where start.message = "IdentifierContext"
Merge (finish)-[:Shortcut]->(ident:Identifier) -[:Shortcut] ->(start)
Set ident.name = finish.text
FOREACH (n IN nodes(p) | SET n.shortcut = true)
set start.shortcut = false
set finish.shortcut = false
;