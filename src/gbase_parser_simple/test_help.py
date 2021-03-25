from antlr4 import InputStream, CommonTokenStream, ParseTreeWalker, ParserRuleContext

from gbase_parser_simple.pygram.GBaseParser import GBaseParser as GBaseSQLParser
from gbase_parser_simple.pygram.GBaseParserListener import GBaseParserListener as SpecSQLListener
from gbase_parser_simple.pygram.GBaseLexer import GBaseLexer as GBaseSQLLexer
from antlr4.error.ErrorListener import ErrorListener


class MyErrorListener(ErrorListener):

    def __init__(self):
        super(MyErrorListener, self).__init__()

    def syntaxError(self, recognizer, offendingSymbol, line, column, msg, e):
        raise SyntaxError(f"Oh no!! {line} {column} {msg}")

    def reportAmbiguity(self, recognizer, dfa, startIndex, stopIndex, exact, ambigAlts, configs):
        raise Exception("Oh no!! reportAmbiguity")

    def reportAttemptingFullContext(self, recognizer, dfa, startIndex, stopIndex, conflictingAlts, configs):
        raise Exception("Oh no!! reportAttemptingFullContext")

    def reportContextSensitivity(self, recognizer, dfa, startIndex, stopIndex, prediction, configs):
        raise Exception("Oh no!! reportContextSensitivity")


def read_sql(sql_str):
    input_stream = InputStream(sql_str)
    lexer = GBaseSQLLexer(input_stream)
    stream = CommonTokenStream(lexer)
    parser = GBaseSQLParser(stream)
    parser.addErrorListener(MyErrorListener())
    return parser

