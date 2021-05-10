import itertools
import pytest
from gbase_parser_simple.test_help import read_sql


@pytest.mark.parametrize("sql,entry_name", itertools.product([
    """
        INSERT INTO Customers (CustomerName, City, Country)
        SELECT SupplierName, City, Country FROM Suppliers
        WHERE Country='Germany';
    """,
    """
    SELECT Customers.CustomerName, Orders.OrderID
    INTO CustomersOrderBackup2017
    FROM Customers
    LEFT JOIN Orders ON Customers.CustomerID = Orders.CustomerID; 
    """,
    """
    SELECT * INTO CustomersGermany
    FROM Customers
    WHERE Country = 'Germany'; 
    """,
    """
    SELECT * INTO newtable
    FROM oldtable
    WHERE 1 = 0; 
    """
], [
    'root',
]))
def test_select_top(sql, entry_name):
    parser = read_sql(sql)
    tree = getattr(parser, entry_name)()