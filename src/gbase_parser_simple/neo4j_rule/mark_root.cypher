MATCH (root:Node)-[r:Children]->(sub:Node)
where root.message =~ "RootContext"
MERGE (root_node:Root {message: "root"})
MERGE (root_node)-[:Children]->(sub)
DETACH DELETE root,r
;