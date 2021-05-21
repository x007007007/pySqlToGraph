MATCH (TableReferenceContext:Node)-[:Children]->(sub:Node)
WHERE (
  TableReferenceContext.message = 'TableReferenceContext'
    or
  TableReferenceContext.message = "EscapedTableReferenceContext"
    or
  TableReferenceContext.message = 'JoinedTableContext'
) AND (
    sub.message = 'TableFactorContext'
      OR
    sub.message = 'JoinedTableContext'
      OR
    sub.message = 'EscapedTableReferenceContext'
          OR
    sub.message = 'TableReferenceContext'
  )
MERGE (TableReferenceContext)-[:table_link]->(sub)
;

MATCH (TableFactorContext:Node)-[:Children]->(sub:Node)
WHERE (
  TableFactorContext.message = 'TableFactorContext'
    or
  TableFactorContext.message = 'SingleTableParensContext'
    or
  TableFactorContext.message = 'TableReferenceListParensContext'
) AND (
    sub.message = 'SingleTableContext'
      OR
    sub.message = 'SingleTableParensContext'
      OR
    sub.message = 'TableReferenceListParensContext'
  )
MERGE (TableFactorContext)-[:table_link]->(sub)
;

MATCH (JoinedTableContext:Node)-[:Children]->(sub:Node)
WHERE (
  JoinedTableContext.message = 'JoinedTableContext'
) AND (
    sub.message = 'TableReferenceContext'
      or
    sub.message = "TableFactorContext"
  )
MERGE (JoinedTableContext)-[:table_link]->(sub)
;

