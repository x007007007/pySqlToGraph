MATCH (DerivedTableContext:Node)
        -[:Children]->(TableAliasContext:Node)
        -[:Children]->(IdentifierContext:Node)
WHERE DerivedTableContext.message = "DerivedTableContext"
  and TableAliasContext.message = "TableAliasContext"
  and IdentifierContext.message = "IdentifierContext"
SET DerivedTableContext.alias_name = IdentifierContext.value
;

MATCH (TableReferenceListContext:Node)
  -[:Children]->(TableReferenceContext:Node)
  -[:table_link *..]->(table_end:Node)
  -[:Children]->(DerivedTableContext:Node)
  -[:Children]->(SubqueryContext:Node)
WHERE TableReferenceListContext.message = "TableReferenceListContext"
  and TableReferenceContext.message = "TableReferenceContext"
  and DerivedTableContext.message = "DerivedTableContext"
  and SubqueryContext.message = "SubqueryContext"
MERGE (table:TABLE {
  type: "subquery"
})<-[:Deduce]-(TableReferenceContext)
MERGE (table)-[:Shortcut]->(SubqueryContext)
set table.alias_name = DerivedTableContext.alias_name
set DerivedTableContext.delete = TRUE
;

MATCH (table:TABLE)
  -[:Shortcut]->(SubqueryContext:Node)
  -[:Deduce]->(select:ACTION)
WHERE SubqueryContext.message = "SubqueryContext"
  and select.type = "select"
MERGE (table)-[:subquery]->(select)
;
