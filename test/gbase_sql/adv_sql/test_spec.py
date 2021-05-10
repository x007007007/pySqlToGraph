import itertools
import pytest
from gbase_parser_simple.test_help import read_sql


@pytest.mark.parametrize("sql,entry_name", itertools.product([
    """
        SELECT ProductName, UnitPrice * (UnitsInStock + IFNULL(UnitsOnOrder, 0))
        FROM Products; 
    """,
], [
    'root',
]))
def test_select_spec(sql, entry_name):
    parser = read_sql(sql)
    tree = getattr(parser, entry_name)()