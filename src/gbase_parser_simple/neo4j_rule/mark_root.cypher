MATCH (root:Node)-[r:Children]->(sub:Node)
where root.message =~ "RootContext"
MERGE (:Root {message: "root"})-[:Children]->(sub)
DETACH DELETE root,r
;