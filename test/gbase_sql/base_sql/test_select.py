import itertools
import pytest
from gbase_parser_simple.test_help import read_sql


@pytest.mark.parametrize("sql,entry_name", itertools.product([
    "select * from a;",
    "select b, c from a;",
    "select b as c, d e from a;",
    "select b c, d as e from a;",
    "select b c, d e from a as f;",
    "select b c, d e from a f, e as g;",
    "select b c, d e from a f, e g;",
    "select b c, d e from a f, (select x as b, y c from z a) as g;",
    "select a.c1 ,a.c2 ,a.c3 as x from (select c, d from x) as b;"
    "select `b`, c from a;",
    "select b as c, `d` e from `a`;",
    'select b "c", d as e from a;',
    "select a.b c, d e from a as f;",
    "select a.b as c, d.x  e from a as f;",
    # "select `f`.`b` c, d e from a f, e as g;",
    # 'select "f"."b" c, d e from a `f`, e g;',
    # "select b c, d e from a f, (select x as b, y c from z a) as g;"
], [
    'selectStatement',
    # 'simpleStatement'
]))
def test_base_select_1(sql, entry_name):
    parser = read_sql(sql)
    tree = getattr(parser, entry_name)()
