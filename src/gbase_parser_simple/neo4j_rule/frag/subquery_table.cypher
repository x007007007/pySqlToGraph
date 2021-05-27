MATCH (TableReferenceContext:Node)
  -[:table_link *..]->(table_end:Node)
  -[:Children]->(DerivedTableContext:Node)
  -[:Children]->(SubqueryContext:Node)
//  -[:Deduce]->(subquery:ACTION)
WHERE TableReferenceContext.message = "TableReferenceContext"
  and DerivedTableContext.message = "DerivedTableContext"
  and SubqueryContext.message = "SubqueryContext"
MERGE (table:TABLE {
  type: "subquery"
})<-[:Deduce]-(TableReferenceContext)
;


MATCH (table:TABLE)<-[:Deduce]-(TableReferenceContext:Node)
  -[:table_link *..]->(table_end:Node)
  -[:Children]->(DerivedTableContext:Node)
  -[:Children]->(TableAliasContext:Node)
  -[:Children]->(IdentifierContext:Node)
WHERE TableReferenceContext.message = "TableReferenceContext"
  and DerivedTableContext.message = "DerivedTableContext"
  and TableAliasContext.message = "TableAliasContext"
  and IdentifierContext.message = "IdentifierContext"
SET table.alias_name = IdentifierContext.value
;