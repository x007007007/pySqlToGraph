import re
import functools

import chardet

from antlr4 import InputStream, CommonTokenStream, ParseTreeWalker, ParserRuleContext

from example.antlr.HelloParser import HelloParser as SpecParser
from example.antlr.HelloListener import HelloListener as SpecListener
from example.antlr.HelloLexer import HelloLexer as SpecLexer


class HelloPrintListener(SpecListener):
    def enterEveryRule(self, ctx:ParserRuleContext):
        print(ctx.getText())

    def enterR(self, ctx):
        print("Hello: %s" % ctx.ID())
        return ctx.ID()

def generate_tree():
    input_stream = InputStream("""
     SELECT hello, hi
    """)
    lexer = SpecLexer(input_stream)
    stream = CommonTokenStream(lexer)
    parser = SpecParser(stream)
    tree = parser.select()
    print(tree)
    printer = HelloPrintListener()
    walker = ParseTreeWalker()
    walker.walk(printer, tree)


if __name__ == '__main__':
    generate_tree()
