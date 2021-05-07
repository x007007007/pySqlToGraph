import itertools
import pytest
from gbase_parser_simple.test_help import read_sql

"""
INSERT INTO table_name (column1, column2, column3, ...)
VALUES (value1, value2, value3, ...); 
"""

@pytest.mark.parametrize("sql,entry_name", itertools.product([
    "insert into t1 (c1, c2, c3) values (v1, v2, v3);",
    "insert t1 (c1, c2, c3) values (v1, v2, v3);",
    "insert db.`t1` (c2) values (v2);",
    "insert db.`t1` (c2) values (v2);",
    'insert "db"."t1" (c2) values (v2);',
    'insert "db"."t1" (c2) values (v2, 1 + 3 * 3, @dd);',
], [
    'insertStatement',
]))
def test_base_insert_statement_1(sql: str, entry_name):
    parser = read_sql(sql)
    tree = getattr(parser, entry_name)()
