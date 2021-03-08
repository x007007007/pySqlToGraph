from antlr4 import FileStream, CommonTokenStream, ParseTreeWalker
from workbench.MySQLLexer import MySQLLexer
from workbench.MySQLParserListener import MySQLParserListener
from workbench.MySQLParser import MySQLParser
import sys


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


def generate_tree(sql_path):
    input_stream = FileStream(sql_path, encoding='utf-8')
    lexer = MySQLLexer(input_stream)
    stream = CommonTokenStream(lexer)
    parser = MySQLParser(stream)
    tree = parser.query()

    printer = CustomMySQLParserListener()
    walker = ParseTreeWalker()
    walker.walk(printer, tree)
