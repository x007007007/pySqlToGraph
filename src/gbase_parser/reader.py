import re
import functools

import chardet

from antlr4 import InputStream, CommonTokenStream, ParseTreeWalker

from gbase_parser.antlr.GBaseSQLParser import GBaseSQLParser
from gbase_parser.antlr.GBaseSQLListener import GBaseSQLListener as SpecSQLListener
from gbase_parser.antlr.GBaseSQLToken import GBaseSQLToken


class CustomMySQLParserListener(SpecSQLListener):

    def default_enter(self, name, ctx):
        print(name)

    def __getattribute__(self, item):
        print(item)
        #
        if item.startswith("enter"):
            return functools.partial(SpecSQLListener.__getattribute__(self, 'default_enter'), item)
        return SpecSQLListener.__getattribute__(self, item)


def delimiter_parse(container):
    head, *body_and_foots = re.split(r"DELIMITER\s+", container, flags=re.I | re.M | re.S)
    yield head.strip()
    for fragment in body_and_foots:
        if frag_res := re.match("^(?P<DELI>.+?)\s*\n(.*)", fragment, re.I | re.S | re.S):
            split_token, context = frag_res.groups()
            body, foot = context.split(split_token)
            yield body.strip()
            yield foot.strip()
        else:
            raise RuntimeError


def generate_tree(context):
    input_stream = InputStream(context)
    lexer = GBaseSQLToken(input_stream)
    stream = CommonTokenStream(lexer)
    parser = GBaseSQLParser(stream)
    tree = parser.sqls_list()

    printer = CustomMySQLParserListener()
    walker = ParseTreeWalker()
    walker.walk(printer, tree)


if __name__ == "__main__":

    import glob, os
    for pth in glob.glob("/home/xxc-dev-machine/workspace/bocwm/pySqlToGraph/test/gbase_sql/test_sql/*.sql"):
        with open(pth, "rb") as fp:
            result = chardet.detect(fp.read())
        print(result)
        with open(pth, encoding=result['encoding']) as fp:
            for context in delimiter_parse(fp.read()):
                if context:
                    generate_tree(context)
        break
