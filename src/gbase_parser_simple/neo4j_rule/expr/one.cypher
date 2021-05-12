MATCH (p:Node)-[:Children]->(c)
WITH p,count(c) AS rels, collect(c) AS children
SET p.children_num  = rels;

//MATCH (p:Node {children_num: 1})-[r:Children]->(c)
//SET r.parent_children_num=1;

Match ()-[r:Children]->()
where not exists(r.skip_list)
set r.skip_list = ""
;

MATCH (n1:Node {children_num: 1})
        -[r1:Children]->(n2 {children_num: 1})
        -[r2:Children]->(n3 {children_num: 1})
        -[r3:Children]->(n4 {children_num: 1})
        -[r4:Children]->(n5 {children_num: 1})
        -[r5:Children]->(n6 {children_num: 1})
        -[r6:Children]->(n7 {children_num: 1})
        -[r7:Children]->(finish)
WHERE finish.children_num > 1 or not exists(finish.children_num)
MERGE (n1)-[:Children {
  children_num:1,
  skip_list:
    n2.message + "," +
    n3.message + "," +
    n4.message + "," +
    n5.message + "," +
    n6.message + "," +
    n7.message
}]-> (finish)
DETACH DELETE n7, n6, n5, n4, n3, n2;


MATCH (n1:Node {children_num: 1})
        -[r1:Children]->(n2 {children_num: 1})
        -[r2:Children]->(n3 {children_num: 1})
        -[r3:Children]->(n4 {children_num: 1})
        -[r4:Children]->(finish)
WHERE finish.children_num > 1 or not exists(finish.children_num)
MERGE (n1)-[:Children {
  children_num:1,
  skip_list:
    n2.message + "," + r2.skip_list + "," +
    n3.message + "," + r3.skip_list + "," +
    n4.message + "," + r4.skip_list
}]-> (finish)
DETACH DELETE n4, n3, n2;

MATCH (n1:Node {children_num: 1})
        -[r1:Children]->(n2 {children_num: 1})
        -[r2:Children]->(finish)
WHERE finish.children_num > 1 or not exists(finish.children_num)
MERGE (n1)-[:Children {
  children_num:1,
  skip_list:
    n2.message + "," + r2.skip_list
}]-> (finish)
DETACH DELETE n2;