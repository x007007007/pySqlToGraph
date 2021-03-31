import itertools
import pytest
from gbase_parser_simple.test_help import read_sql


@pytest.mark.parametrize("sql,entry_name", itertools.product([
    """
        CREATE DEFINER="aaa"@"%" PROCEDURE "proc1"(
                         out  a int,
                         IN b VARCHAR,
                         IN c VARCHAR
        ) begin
            declare x      VARCHAR(8); -- xxx
            declare y      VARCHAR(5); -- yyy
            
            set x = 1;
            
            select a ;

 	    END;
    """,
], [
    'root',
]))
def test_base_proc(sql, entry_name):
    parser = read_sql(sql)
    tree = getattr(parser, entry_name)()
