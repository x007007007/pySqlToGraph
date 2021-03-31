# Generated from GBaseLexer.g4 by ANTLR 4.9.1
import logging
from antlr4 import *
import re
from io import StringIO
from typing.io import TextIO
import sys


from gbase_parser_simple.lexer_status import status


LOGGER = logging.getLogger(__name__)


class GBaseBaseLexer(Lexer):

    def dotEmit(self):
        """
          _pendingTokens.emplace_back(_factory->create({this, _input}, self.DOT_SYMBOL, _text, channel,
                                               tokenStartCharIndex, tokenStartCharIndex, tokenStartLine,
                                               tokenStartCharPositionInLine));
            ++tokenStartCharIndex;
        :return:
        """
        cpos = self.column
        lpos = self.line
        dot = self._factory.create(self._tokenFactorySourcePair, self.DOT_SYMBOL, self._text, self._channel,
                                   self._tokenStartCharIndex,
                                   self._tokenStartCharIndex, lpos, cpos)
        dot.column = self.column - self.getCharIndex() + self._tokenStartCharIndex + 1
        self.emitToken(dot)
        self._input.seek(self._tokenStartCharIndex+1)

    def nextToken(self):
        """
          // First respond with pending tokens to the next token request, if there are any.
          if (!_pendingTokens.empty()) {
            auto pending = std::move(_pendingTokens.front());
            _pendingTokens.pop_front();
            return pending;
          }

          // Let the main lexer class run the next token recognition.
          // This might create additional tokens again.
          auto next = Lexer::nextToken();
          if (!_pendingTokens.empty()) {
            auto pending = std::move(_pendingTokens.front());
            _pendingTokens.pop_front();
            _pendingTokens.push_back(std::move(next));
            return pending;
          }
          return next;

        :return:
        """
        nextToken = super(GBaseBaseLexer, self).nextToken()
        print(f"default: {nextToken}")
        return nextToken

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
            return self.INT_NUMBER;
          unsigned negative = 0;

          if (*str == '+') // Remove sign and pre-zeros
          {
            str++;
            length--;
          } elif (*str == '-') {
            str++;
            length--;
            negative = 1;
          }

          while (*str == '0' && length) {
            str++;
            length--;
          }

          if (length < long_len)
            return self.INT_NUMBER;

          unsigned smaller, bigger;
          const char *cmp;
          if (negative) {
            if (length == long_len) {
              cmp = signed_long_str + 1;
              smaller = self.INT_NUMBER; // If <= signed_long_str
              bigger = self.LONG_NUMBER; // If >= signed_long_str
            } elif (length < signed_longlong_len)
              return self.LONG_NUMBER;
            elif (length > signed_longlong_len)
              return self.DECIMAL_NUMBER;
            else {
              cmp = signed_longlong_str + 1;
              smaller = self.LONG_NUMBER; // If <= signed_longlong_str
              bigger = self.DECIMAL_NUMBER;
            }
          } else {
            if (length == long_len) {
              cmp = long_str;
              smaller = self.INT_NUMBER;
              bigger = self.LONG_NUMBER;
            } elif (length < longlong_len)
              return self.LONG_NUMBER;
            elif (length > longlong_len) {
              if (length > unsigned_longlong_len)
                return self.DECIMAL_NUMBER;
              cmp = unsigned_longlong_str;
              smaller = self.ULONGLONG_NUMBER;
              bigger = self.DECIMAL_NUMBER;
            } else {
              cmp = longlong_str;
              smaller = self.LONG_NUMBER;
              bigger = self.ULONGLONG_NUMBER;
            }
          }

          while (*cmp && *cmp++ == *str++)
            ;

          return ((unsigned char)str[-1] <= (unsigned char)cmp[-1]) ? smaller : bigger;
        :param text:
        :return:
        """
        print(f"determineNumber: {text}")
        long_str = "2147483647"
        long_len = 10
        signed_long_str = "-2147483648"
        longlong_str = "9223372036854775807"
        longlong_len = 19
        signed_longlong_str = "-9223372036854775808"
        signed_longlong_len = 19
        unsigned_longlong_str = "18446744073709551615"
        unsigned_longlong_len = 20
        negative = False
        if text.startswith("+"):
            text = text[1:]
        elif text.startswith("-"):
            negative = True
            text = text[1:]
        text = text.lstrip("0")

        length = len(text)
        if negative:
            if length == long_len:
                cmp = signed_long_str[:1]
                smaller = self.INT_NUMBER   # If <= signed_long_str
                bigger = self.LONG_NUMBER   # If >= signed_long_str
            elif length < signed_longlong_len:
                return self.LONG_NUMBER
            elif length > signed_longlong_len:
                return self.DECIMAL_NUMBER
            else:
                cmp = signed_longlong_str[:1]
                smaller = self.LONG_NUMBER  # If <= signed_longlong_str
                bigger = self.DECIMAL_NUMBER
        else:
            if length == long_len:
                cmp = long_str
                smaller = self.INT_NUMBER
                bigger = self.LONG_NUMBER
            elif length < longlong_len:
                return self.LONG_NUMBER
            elif length > longlong_len:
                if length > unsigned_longlong_len:
                    return self.DECIMAL_NUMBER
                cmp = unsigned_longlong_str
                smaller = self.ULONGLONG_NUMBER
                bigger = self.DECIMAL_NUMBER
            else:
                cmp = longlong_str
                smaller = self.LONG_NUMBER
                bigger = self.ULONGLONG_NUMBER

            if int(cmp) > int(text):
                return smaller
            else:
                return bigger
