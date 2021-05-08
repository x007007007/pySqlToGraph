import itertools
import pytest
from gbase_parser_simple.test_help import read_sql

"""
example of delete

    :: DELETE FROM table_name WHERE condition; 

"""

@pytest.mark.parametrize("sql,entry_name", itertools.product([
    "Delete from t1 where t1 = 1;",
    "Delete from t1 where t1 = @aa;",
    "Delete from t1 where t1 = @@aa",
], [
    'deleteStatement',
]))
def test_base_delete_statement(sql: str, entry_name):
    parser = read_sql(sql)
    tree = getattr(parser, entry_name)()
