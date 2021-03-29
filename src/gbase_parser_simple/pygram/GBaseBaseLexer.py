# Generated from GBaseLexer.g4 by ANTLR 4.9.1
import logging
from antlr4 import *
from io import StringIO
from typing.io import TextIO
import sys


from gbase_parser_simple.lexer_status import status


LOGGER = logging.getLogger(__name__)


class GBaseBaseLexer(Lexer):

    def dotEmit(self):
        """
          _pendingTokens.emplace_back(_factory->create({this, _input}, MySQLLexer::DOT_SYMBOL, _text, channel,
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



