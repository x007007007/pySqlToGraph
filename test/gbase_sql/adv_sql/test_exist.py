import itertools
import pytest
from gbase_parser_simple.test_help import read_sql


@pytest.mark.parametrize("sql,entry_name", itertools.product([
    """
        SELECT SupplierName
        FROM Suppliers
        WHERE EXISTS (SELECT ProductName FROM Products WHERE Products.SupplierID = Suppliers.supplierID AND Price = 22); 
    """,
], [
    'root',
]))
def test_exist(sql, entry_name):
    parser = read_sql(sql)
    tree = getattr(parser, entry_name)()
