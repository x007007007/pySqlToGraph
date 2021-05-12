import re


class BridgeOfLexerAndParserStatus:
    NoMode = 0
    AnsiQuotes = 1 << 0
    HighNotPrecedence = 1 << 1
    PipesAsConcat = 1 << 2
    IgnoreSpace = 1 << 3
    NoBackslashEscapes = 1 << 4

    serverVersion = 99999
    _sqlMode = NoMode
    _inVersionComment = False
    support_gbase = True

    def __init__(self):
        self._sqlMode = self.AnsiQuotes | self.PipesAsConcat | self.HighNotPrecedence |self.IgnoreSpace

    @property
    def sqlMode(self):
        return self._sqlMode

    @sqlMode.setter
    def sqlMode(self, v):
        print(f"sqlMode set: {v}")
        self._sqlMode = v

    @property
    def inVersionComment(self):
        return self._inVersionComment

    @inVersionComment.setter
    def inVersionComment(self, status):
        print("version comment")
        self._inVersionComment = status


    def isSqlModeActive(self, mode):
        res = (self.sqlMode & mode) != 0
        print(f"isSqlModeActive, {mode}, {res}")
        return res

    def LOGICAL_OR_OPERATOR(self, CONCAT_PIPES_SYMBOL, OGICAL_OR_OPERATOR):
        print("LOGICAL_OR_OPERATOR")
        if self.setType(self.isSqlModeActive(self.PipesAsConcat)):
            return CONCAT_PIPES_SYMBOL
        return OGICAL_OR_OPERATOR

    def NOT_SYMBOL(self, NOT2_SYMBOL, NOT_SYMBOL):
        print("NOT_SYMBOL")
        if self.setType(self.isSqlModeActive(self.HighNotPrecedence)):
            return NOT2_SYMBOL
        return NOT_SYMBOL


status = BridgeOfLexerAndParserStatus()

