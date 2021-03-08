from antlr4 import FileStream, CommonTokenStream, ParseTreeWalker
from gbase_grammer.MySqlLexer import MySqlLexer
from gbase_grammer.MySqlParserListener import MySqlParserListener
from gbase_grammer.MySqlParser import MySqlParser
import sys


class KeyPrinter(MySqlParserListener):
    def exitKey(self, ctx):
        print("Oh, a key!")



class HelloPrintListener(MySqlParserListener):
    def enterHi(self, ctx):
        print("Hello: %s" % ctx.ID())


def generate_tree(sql_path):
    input_stream = FileStream(sql_path)
    lexer = MySqlLexer(input_stream)
    stream = CommonTokenStream(lexer)
    parser = MySqlParser(stream)
    tree = parser.root()

    printer = HelloPrintListener()
    walker = ParseTreeWalker()
    walker.walk(printer, tree)

