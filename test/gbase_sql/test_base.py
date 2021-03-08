import os
import glob
from workbench.logic import generate_tree


def test_base_sql():
    for sql_file in glob.glob(f"{os.path.dirname(__file__)}/test_sql/*.sql"):
        generate_tree(sql_file)
    raise False
