from antlr4 import InputStream, CommonTokenStream, ParseTreeWalker
from workbench.MySQLLexer import MySQLLexer
from workbench.MySQLParserListener import MySQLParserListener
from workbench.MySQLParser import MySQLParser
import re
import sys
import chardet


class KeyPrinter(MySQLParserListener):
    def exitKey(self, ctx):
        print("Oh, a key!")


class CustomMySQLParserListener(MySQLParserListener):

    def enterRoot(self, ctx:MySQLParser.RootContext):
        print("root")
        print(ctx)

    def enterQuery(self, ctx:MySQLParser.QueryContext):
        print("entry query")
        print(ctx)

    def exitQuery(self, ctx:MySQLParser.QueryContext):
        print('exit query')
        print(ctx)

    def exitSelectStatement(self, ctx:MySQLParser.SelectStatementContext):
        print(f"exit select {ctx}")


def delimiter_parse(container):
    head, *body_and_foots = re.split(r"DELIMITER\s+", container, flags=re.I | re.M | re.S)
    yield head
    for fragment in body_and_foots:
        if frag_res := re.match("^(?P<DELI>.+?)\s*\n(.*)", fragment, re.I | re.S | re.S):
            split_token, context = frag_res.groups()
            body, foot = context.split(split_token)
            yield body
            yield foot
        else:
            print(fragment)
            raise RuntimeError


def generate_tree(context):
    input_stream = InputStream(context)
    lexer = MySQLLexer(input_stream)
    stream = CommonTokenStream(lexer)
    parser = MySQLParser(stream)
    tree = parser.query()

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
                print(context)
                generate_tree(context)
