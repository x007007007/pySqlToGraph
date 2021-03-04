from antlr4 import FileStream, CommonTokenStream, ParseTreeWalker
from workbench.MySQLLexer import MySQLLexer
from workbench.MySQLParserListener import MySQLParserListener
from workbench.MySQLParser import MySQLParser
import sys


class KeyPrinter(MySQLParserListener):
    def exitKey(self, ctx):
        print("Oh, a key!")



class HelloPrintListener(MySQLParserListener):
    def enterHi(self, ctx):
        print("Hello: %s" % ctx.ID())


def generate_tree(sql_path):
    input_stream = FileStream(sql_path)
    lexer = MySQLLexer(input_stream)
    stream = CommonTokenStream(lexer)
    parser = MySQLParser(stream)
    tree = parser.query()

    printer = HelloPrintListener()
    walker = ParseTreeWalker()
    walker.walk(printer, tree)

