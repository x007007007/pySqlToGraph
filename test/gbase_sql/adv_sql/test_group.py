import itertools
import pytest
from gbase_parser_simple.test_help import read_sql


@pytest.mark.parametrize("sql,entry_name", itertools.product([
    """
        SELECT COUNT(CustomerID), Country
        FROM Customers
        GROUP BY Country
        ORDER BY COUNT(CustomerID) DESC;
    """,
    """
        SELECT COUNT(CustomerID), Country
        FROM Customers
        GROUP BY Country
        HAVING COUNT(CustomerID) > 5
        ORDER BY COUNT(CustomerID) DESC;
    """
], [
    'root',
]))
def test_group(sql, entry_name):
    parser = read_sql(sql)
    tree = getattr(parser, entry_name)()
