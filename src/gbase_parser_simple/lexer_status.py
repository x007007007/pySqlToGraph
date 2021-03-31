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

    def __init__(self):
        self._sqlMode = self.AnsiQuotes | self.PipesAsConcat | self.HighNotPrecedence

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
        """
          static const char *long_str = "2147483647";
          static const unsigned long_len = 10;
          static const char *signed_long_str = "-2147483648";
          static const char *longlong_str = "9223372036854775807";
          static const unsigned longlong_len = 19;
          static const char *signed_longlong_str = "-9223372036854775808";
          static const unsigned signed_longlong_len = 19;
          static const char *unsigned_longlong_str = "18446744073709551615";
          static const unsigned unsigned_longlong_len = 20;

          // The original code checks for leading +/- but actually that can never happen, neither in the
          // server parser (as a digit is used to trigger processing in the lexer) nor in our parser
          // as our rules are defined without signs. But we do it anyway for maximum compatibility.
          unsigned length = (unsigned)text.size() - 1;
          const char *str = text.c_str();
          if (length < long_len) // quick normal case
            return MySQLLexer::INT_NUMBER;
          unsigned negative = 0;

          if (*str == '+') // Remove sign and pre-zeros
          {
            str++;
            length--;
          } else if (*str == '-') {
            str++;
            length--;
            negative = 1;
          }

          while (*str == '0' && length) {
            str++;
            length--;
          }

          if (length < long_len)
            return MySQLLexer::INT_NUMBER;

          unsigned smaller, bigger;
          const char *cmp;
          if (negative) {
            if (length == long_len) {
              cmp = signed_long_str + 1;
              smaller = MySQLLexer::INT_NUMBER; // If <= signed_long_str
              bigger = MySQLLexer::LONG_NUMBER; // If >= signed_long_str
            } else if (length < signed_longlong_len)
              return MySQLLexer::LONG_NUMBER;
            else if (length > signed_longlong_len)
              return MySQLLexer::DECIMAL_NUMBER;
            else {
              cmp = signed_longlong_str + 1;
              smaller = MySQLLexer::LONG_NUMBER; // If <= signed_longlong_str
              bigger = MySQLLexer::DECIMAL_NUMBER;
            }
          } else {
            if (length == long_len) {
              cmp = long_str;
              smaller = MySQLLexer::INT_NUMBER;
              bigger = MySQLLexer::LONG_NUMBER;
            } else if (length < longlong_len)
              return MySQLLexer::LONG_NUMBER;
            else if (length > longlong_len) {
              if (length > unsigned_longlong_len)
                return MySQLLexer::DECIMAL_NUMBER;
              cmp = unsigned_longlong_str;
              smaller = MySQLLexer::ULONGLONG_NUMBER;
              bigger = MySQLLexer::DECIMAL_NUMBER;
            } else {
              cmp = longlong_str;
              smaller = MySQLLexer::LONG_NUMBER;
              bigger = MySQLLexer::ULONGLONG_NUMBER;
            }
          }

          while (*cmp && *cmp++ == *str++)
            ;

          return ((unsigned char)str[-1] <= (unsigned char)cmp[-1]) ? smaller : bigger;
        :param text:
        :return:
        """
        from gbase_parser_simple.pygram.GBaseLexer import GBaseLexer

        if re.match(r"^\d+$", text):
            return GBaseLexer.INT_NUMBER
        elif re.match(r"^\d+\.\d+$"):
            return GBaseLexer.FLOAT_NUMBER
        else:
            print(text)
            raise SyntaxError

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

    def determineFunction(self, POSITION_SYMBOL):
        print("determineFunction")
        pass


status = Status()

