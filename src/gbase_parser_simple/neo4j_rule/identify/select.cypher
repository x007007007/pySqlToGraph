MATCH (SelectItemListContext:Node)-[:Children]->(comma:EndNode)
where comma.text = ','
set comma.delete = true
;