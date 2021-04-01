select kk, d.a, f.b b1 from c as d, f;
select (e + 1), (f + h.c) as e1, f from g.h h;
update table1 set a = '1', b = '1' where d = '5';
update (select c.a as a, d.b b from c, d where c.x = d.y)
    set b = a, c.a = 1;
exec "sssss"