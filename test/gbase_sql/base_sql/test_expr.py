import itertools
import pytest
from gbase_parser_simple.test_help import read_sql


@pytest.mark.parametrize("sql,entry_name", itertools.product([
    "1.12",
    "1",
    "+99999",
    "-99999.99",
    '"ssss"',
], [
    'simpleExpr',
    'bitExpr',
    'exprTestEntry',
]))
def test_base_sample_expr(sql: str, entry_name):
    parser = read_sql(sql)
    tree = getattr(parser, entry_name)()


@pytest.mark.parametrize("sql,entry_name", itertools.product([
    "a = 1",
    "a = 1 and b = 1",
    "a = 1 or b = 1",
    "a = 1 or b = 1 and c = d",
    "a = 1 or (b = 1 and c = d)",
    " not 2 = 3",
    "3 xor 4",
], [
    'bitExpr',
    'predicate',
    'expr'
]))
def test_base_expr_1(sql: str, entry_name):
    parser = read_sql(sql)
    tree = getattr(parser, entry_name)()


