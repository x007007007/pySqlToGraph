import itertools
import pytest
from gbase_parser_simple.test_help import read_sql


@pytest.mark.parametrize("sql,entry_name", itertools.product([
    """
    
    """,
    """--      """,
    """/*
    
    ""
    
    * */
    select 1;
    """,
    r'select "1";',
    r"""select '"';"""
    r'select "\"";'
], [
    'root',
    # 'simpleStatement'
]))
def test_base_select_1(sql, entry_name):
    parser = read_sql(sql)
    tree = getattr(parser, entry_name)()
