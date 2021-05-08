MATCH p=(start:Node)-[:Children]->(alias_child:Node)-[:Children*]->(finish:EndNode)
  where start.message = "SingleTableContext"
  and alias_child.message = "TableAliasContext"
MERGE (finish)-[:Shortcut]->(alias:Alias)
MERGE (alias)-[:Shortcut] ->(start)
SET finish.alias_name = finish.text
FOREACH (n IN nodes(p) | SET n.shortcut = true)
set start.shortcut = false
set finish.shortcut = false
;


MATCH p=(start:Node)-[:Children]->(table_ref_child:Node)-[:Children*]->(finish:EndNode)
  where start.message = "SingleTableContext"
  and table_ref_child.message = "TableRefContext"
MERGE (finish)-[:Shortcut]->(alias:Alias)
MERGE (alias)-[:Shortcut] ->(start)
Set finish.alias_name = finish.text
FOREACH (n IN nodes(p) | SET n.shortcut = true)
set start.shortcut = false
set finish.shortcut = false
;
