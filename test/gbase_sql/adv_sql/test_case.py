import itertools
import pytest
from gbase_parser_simple.test_help import read_sql


@pytest.mark.parametrize("sql,entry_name", itertools.product([
    """
    SELECT OrderID, Quantity,
    CASE
        WHEN Quantity > 30 THEN 'The quantity is greater than 30'
        WHEN Quantity = 30 THEN 'The quantity is 30'
        ELSE 'The quantity is under 30'
    END AS QuantityText
    FROM OrderDetails; 
    """,
    """
    SELECT CustomerName, City, Country
    FROM Customers
    ORDER BY
    (CASE
        WHEN City IS NULL THEN Country
        ELSE City
    END); 
    """
], [
    'root',
]))
def test_case(sql, entry_name):
    parser = read_sql(sql)
    tree = getattr(parser, entry_name)()
