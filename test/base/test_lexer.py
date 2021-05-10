

from antlr4 import ParseTreeWalker

from gbase_parser_simple.pygram.GBaseLexer import GBaseLexer
from gbase_parser_simple.pygram.GBaseParserListener import GBaseParserListener as SpecSQLListener


def test_lexer_int():
    assert GBaseLexer.INT_NUMBER == GBaseLexer().determineNumericType('1')

def test_lexer_long():
    assert GBaseLexer.LONG_NUMBER == GBaseLexer().determineNumericType('10000000000000')