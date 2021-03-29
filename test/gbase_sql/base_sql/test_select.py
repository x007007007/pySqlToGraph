import itertools
import pytest
from gbase_parser_simple.test_help import read_sql


@pytest.mark.parametrize("sql,entry_name", itertools.product([
    "select * from a;",
    "select b, c from a;",
    "select b as c, d e from a.b;",
    "select b c, d as e from a;",
    "select b c, d e from a as f;",
    "select b c, d e from a f, e as g;",
    "select b c, d e from a f, e g;",
    "select b c, d e from a f, (select x as b, y c from z a) as g;",
    "select a_11.c1 ,a.c2 ,a.c3 as x from (select c, d from x) as b;",
    "select `b`, c from a;",
    "select b as c, `d` e from `a`;",
    'select b `error`, d as `error1` from a;',
    "select a.b c, d e from a as f;",
    "select a.b as c, d.x  e from a as f;",
    "select b c, d e from a f, (select x as b, y c from z a) as g;",
    "select `feer`.`b` c, d e from a f, e as g;",
    'select "feer"."b" c, d e from a `f`, e g;',
], [
    'selectStatement',
    # 'simpleStatement'
]))
def test_base_select_1(sql: str, entry_name):
    parser = read_sql(sql)
    tree = getattr(parser, entry_name)()


@pytest.mark.parametrize("sql,entry_name", itertools.product([
    "select b ,e from a where b = 1;",
], [
    'selectStatement',
    # 'simpleStatement'
]))
def test_base_select_2(sql, entry_name):
    parser = read_sql(sql)
    tree = getattr(parser, entry_name)()


@pytest.mark.parametrize("sql,entry_name", itertools.product([
    "where b = 1   and a < 1;",
    "where b >= 1",
    "where b <= 1",
    "where b <> 1",
], [
    'whereClause',
    # 'simpleStatement'
]))
def test_base_select_where_clause(sql, entry_name):
    parser = read_sql(sql)
    tree = getattr(parser, entry_name)()


