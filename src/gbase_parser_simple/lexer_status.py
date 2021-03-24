import re

class Status:
    NoMode = 0
    AnsiQuotes = 1 << 0
    HighNotPrecedence = 1 << 1
    PipesAsConcat = 1 << 2
    IgnoreSpace = 1 << 3
    NoBackslashEscapes = 1 << 4

    serverVersion = 99999
    _sqlMode = NoMode
    _inVersionComment = False

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

    @property
    def inVersionComment(self, status):
        print("version comment")
        self._inVersionComment = status

    def determineNumericType(self, text):
        from gbase_parser_simple.pygram.GBaseLexer import GBaseLexer
        if re.match(r"^\d+$", text):
            return GBaseLexer.INT_NUMBER
        elif re.match(r"^\d+\.\d+$"):
            return GBaseLexer.FLOAT_NUMBER
        else:
            # print(text)
            raise SyntaxError

    def isSqlModeActive(self, mode):
        print(f"isSqlModeActive, {mode}")
        return self.sqlMode and mode == 0

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

    def determineFunction(self, POSITION_SYMBOL):
        print("determineFunction")
        pass


status = Status()

