MATCH (DerivedTableContext:Node)
        -[:Children]->(TableAliasContext:Node)
        -[:Children]->(IdentifierContext:Node)
WHERE DerivedTableContext.message = "DerivedTableContext"
  and TableAliasContext.message = "TableAliasContext"
  and IdentifierContext.message = "IdentifierContext"
SET DerivedTableContext.alias_name = IdentifierContext.value
;

MATCH (TableReferenceContext:Node)
  -[:table_link *..]->(table_end:Node)
  -[:Children]->(DerivedTableContext:Node)
  -[:Children]->(SubqueryContext:Node)
WHERE TableReferenceContext.message = "TableReferenceContext"
  and DerivedTableContext.message = "DerivedTableContext"
  and SubqueryContext.message = "SubqueryContext"
MERGE (table:TABLE {
  type: "subquery"
})<-[:Deduce]-(TableReferenceContext)
set table.alias_name = DerivedTableContext.alias_name
;


