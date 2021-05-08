import itertools
import pytest
from gbase_parser_simple.test_help import read_sql

"""
example of delete

    :: DELETE FROM table_name WHERE condition; 

"""

@pytest.mark.parametrize("sql,entry_name", itertools.product([
    """
    MERGE INTO employees e
    USING hr_records h
        ON (e.id = h.emp_id)
      WHEN MATCHED THEN
        UPDATE SET e.address = h.address
      WHEN NOT MATCHED THEN
        INSERT (id, address)
        VALUES (h.emp_id, h.address);
    """
], [
    'mergeIntoStatement',
]))
def test_base_merge_into_statement(sql: str, entry_name):
    parser = read_sql(sql)
    tree = getattr(parser, entry_name)()

