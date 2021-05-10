import itertools
import pytest
from gbase_parser_simple.test_help import read_sql


@pytest.mark.parametrize("sql,entry_name", itertools.product([
    """
    SELECT Orders.OrderID, Customers.CustomerName, Orders.OrderDate
    FROM Orders
    INNER JOIN Customers ON Orders.CustomerID=Customers.CustomerID;
    """,
    """
    SELECT column_name(s)
    FROM table1
    INNER JOIN table2
    ON table1.column_name = table2.column_name;
    """,
    """
    SELECT column_name(s)
    FROM table1
    LEFT JOIN table2
    ON table1.column_name = table2.column_name;
    """,
    """
    SELECT column_name(s)
    FROM table1
    RIGHT JOIN table2
    ON table1.column_name = table2.column_name;
    """,
    # """
    #     SELECT Customers.CustomerName, Orders.OrderID
    #     FROM Customers
    #     FULL OUTER JOIN Orders ON Customers.CustomerID=Orders.CustomerID
    #     ORDER BY Customers.CustomerName;
    # """,
    # # mysql don't support
    """
        SELECT A.CustomerName AS CustomerName1, B.CustomerName AS CustomerName2, A.City
        FROM Customers A, Customers B
        WHERE A.CustomerID <> B.CustomerID
        AND A.City = B.City
        ORDER BY A.City;
    """
], [
    'root',
]))
def test_join(sql, entry_name):
    parser = read_sql(sql)
    tree = getattr(parser, entry_name)()
