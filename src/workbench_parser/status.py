
class Status:
    NoMode = 0,
    AnsiQuotes = 1 << 0,
    HighNotPrecedence = 1 << 1,
    PipesAsConcat = 1 << 2,
    IgnoreSpace = 1 << 3,
    NoBackslashEscapes = 1 << 4

    serverVersion = 81000
    sqlMode = NoMode
    inVersionComment = False

    def determineNumericType(self, text):
        print(text)

    def isSqlModeActive(self, mode):
        return self.sqlMode and mode == 0

    def LOGICAL_OR_OPERATOR(self, CONCAT_PIPES_SYMBOL, OGICAL_OR_OPERATOR):
        if self.setType(self.isSqlModeActive(self.PipesAsConcat)):
            return CONCAT_PIPES_SYMBOL
        return OGICAL_OR_OPERATOR

    def NOT_SYMBOL(self, NOT2_SYMBOL, NOT_SYMBOL):
        if self.setType(self.isSqlModeActive(self.HighNotPrecedence)):
            return NOT2_SYMBOL
        return NOT_SYMBOL

    def determineFunction(self, POSITION_SYMBOL):
        pass


status = Status()
