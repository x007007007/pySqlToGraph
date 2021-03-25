# Generated from GBaseLexer.g4 by ANTLR 4.9.1
from antlr4 import *
from io import StringIO
from typing.io import TextIO
import sys


from gbase_parser_simple.lexer_status import status


class GBaseBaseLexer(Lexer):

    def __init__(self, *args, **kwargs):
        super(GBaseBaseLexer, self).__init__(*args, **kwargs)
        self._pendingTokens = []

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
        eof = self._factory.create(self._tokenFactorySourcePair, self.DOT_SYMBOL, None, Token.DEFAULT_CHANNEL, self._input.index,
                                   self._input.index-1, lpos, cpos)
        self.emitToken(eof)
        self._pendingTokens.append(eof)
        return eof

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
        if len(self._pendingTokens) > 0:
            return self._pendingTokens.pop()

        nextToken = super(GBaseBaseLexer, self).nextToken()
        if len(self._pendingTokens) > 0:
            res = self._pendingTokens.pop()
            self._pendingTokens.append(nextToken)
            return res
        return nextToken



