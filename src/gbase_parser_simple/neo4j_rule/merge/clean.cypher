MATCH (MergeIntoStatementContext:Node)-[:Children]->(e:EndNode)
WHERE MergeIntoStatementContext.message = "MergeIntoStatementContext"
SET e.delete = TRUE
;