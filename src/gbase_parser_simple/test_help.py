import re

from antlr4 import InputStream, CommonTokenStream, ParseTreeWalker, ParserRuleContext

from gbase_parser_simple.pygram.GBaseParser import GBaseParser as GBaseSQLParser
from gbase_parser_simple.pygram.GBaseParserListener import GBaseParserListener as SpecSQLListener
from gbase_parser_simple.pygram.GBaseLexer import GBaseLexer as GBaseSQLLexer
from antlr4.error.ErrorListener import ErrorListener
import warnings


class MyErrorListener(ErrorListener):

    def __init__(self):
        super(MyErrorListener, self).__init__()

    def syntaxError(self, recognizer, offendingSymbol, line, column, msg, e):
        raise SyntaxError(f"Oh no!! {line} {column} {msg}")

    def reportAmbiguity(self, recognizer, dfa, startIndex, stopIndex, exact, ambigAlts, configs):
        # raise Exception("Oh no!! reportAmbiguity")
        warnings.warn("Oh no!! reportAmbiguity")

    def reportAttemptingFullContext(self, recognizer, dfa, startIndex, stopIndex, conflictingAlts, configs):
        # raise Exception("Oh no!! reportAttemptingFullContext")
        warnings.warn("Oh no!! reportAttemptingFullContext")
        pass

    def reportContextSensitivity(self, recognizer, dfa, startIndex, stopIndex, prediction, configs):
        # raise Exception("Oh no!! reportContextSensitivity")
        warnings.warn("Oh no!! reportContextSensitivity")


def read_sql(sql_str):
    input_stream = InputStream(sql_str)
    lexer = GBaseSQLLexer(input_stream)
    stream = CommonTokenStream(lexer)
    parser = GBaseSQLParser(stream)
    parser.addErrorListener(MyErrorListener())
    return parser


def delimiter_parse(container):
    head, *body_and_foots = re.split(r"DELIMITER\s+", container, flags=re.I | re.M | re.S)
    yield f"{head.strip()};"
    for fragment in body_and_foots:
        if frag_res := re.match("^(?P<DELI>.+?)\s*\n(.*)", fragment, re.I | re.S | re.S):
            split_token, context = frag_res.groups()
            body, foot = context.split(split_token)
            yield f"{body.strip()};"
            yield f"{foot.strip()};"
        else:
            raise RuntimeError