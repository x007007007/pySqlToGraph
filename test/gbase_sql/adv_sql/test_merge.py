import itertools
import pytest
from gbase_parser_simple.test_help import read_sql


@pytest.mark.parametrize("sql,entry_name", itertools.product([
    """
    MERGE INTO pdm.dm_agr_xfar
    USING table1
    ON (g1 = g2 AND h1 = h2)
    WHEN MATCHED THEN UPDATE
        SET I1 = I.a,
            i.k = '3'
    WHEN NOT MATCHED THEN INSERT
        (I1, I2) VALUES
        (1, 2);
    """,
], [
    'root',
]))
def test_base_merge(sql, entry_name):
    parser = read_sql(sql)
    tree = getattr(parser, entry_name)()
