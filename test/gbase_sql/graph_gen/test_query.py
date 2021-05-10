import itertools
import pytest
import glob
import chardet
import os

from gbase_parser_simple.test_help import read_sql, delimiter_parse


@pytest.mark.parametrize("pth", glob.glob(f"{os.path.dirname(os.path.dirname(__file__))}/sql/*.sql"))
def test_product_query(pth):
    with open(pth, "rb") as fp:
        result = chardet.detect(fp.read())
    with open(pth, encoding=result['encoding']) as fp:
        for context in delimiter_parse(fp.read()):
            if context:
                parser = read_sql(context)
                tree = parser.root()


