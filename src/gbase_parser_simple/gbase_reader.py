import re
import functools

import chardet

from antlr4 import InputStream, CommonTokenStream, ParseTreeWalker, ParserRuleContext

from gbase_parser_simple.pygram.GBaseParser import GBaseParser as GBaseSQLParser
from gbase_parser_simple.pygram.GBaseParserListener import GBaseParserListener as SpecSQLListener
from gbase_parser_simple.pygram.GBaseLexer import GBaseLexer as GBaseSQLLexer


class CustomMySQLParserListener(SpecSQLListener):

    def enterEveryRule(self, ctx:ParserRuleContext):
        print("enterEveryRule")
        print(ctx.getText())


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
    lexer = GBaseSQLLexer(input_stream)
    print(lexer)
    stream = CommonTokenStream(lexer)
    parser = GBaseSQLParser(stream)
    tree = parser.root()
    print(tree)
    printer = CustomMySQLParserListener()
    print(printer)
    walker = ParseTreeWalker()
    walker.walk(printer, tree)


if __name__ == "__main__":

    import glob, os
    for pth in glob.glob("/home/xxc-dev-machine/workspace/bocwm/pySqlToGraph/test/gbase_sql/test_sql/*.sql"):
        with open(pth, "rb") as fp:
            result = chardet.detect(fp.read())
        with open(pth, encoding=result['encoding']) as fp:
            for context in delimiter_parse(fp.read()):
            # if context := fp.read():
                if context:
                    print("===========================start===============================")
                    print(context)
                    print("===========================end===============================")
                    generate_tree(context)
        # break
