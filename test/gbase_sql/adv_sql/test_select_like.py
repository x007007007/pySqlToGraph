import itertools
import pytest
from gbase_parser_simple.test_help import read_sql


@pytest.mark.parametrize("sql,entry_name", itertools.product([
    """
    SELECT * FROM Customers
    WHERE ContactName LIKE 'a%o'; 
    """,
], [
    'root',
]))
def test_select_like(sql, entry_name):
    parser = read_sql(sql)
    tree = getattr(parser, entry_name)()