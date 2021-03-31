import itertools
import pytest
from gbase_parser_simple.test_help import read_sql


@pytest.mark.parametrize("sql,entry_name", itertools.product([
    "update `table` set a = 1",
], [
    'updateStatement',
    'simpleStatement'
]))
def test_base_update_1(sql, entry_name):
    parser = read_sql(sql)
    tree = getattr(parser, entry_name)()
