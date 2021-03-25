lexer grammar GBaseLexer;
import GBaseLexer_symbol,
       GBaseLexer_keyword;


options {
    superClass = GBaseBaseLexer;
    tokenVocab = predefined; // Keyword tokens in a predefined order for simpler checks.
    exportMacro = PARSERS_PUBLIC_TYPE;
}

@header {
from gbase_parser_simple.lexer_status import status
}


tokens {
    NOT2_SYMBOL,        // find_keyword mysql
    CONCAT_PIPES_SYMBOL,

    // Tokens assigned in NUMBER rule.
    INT_NUMBER, // NUM in sql_yacc.yy
    LONG_NUMBER,
    ULONGLONG_NUMBER
}

// There are 3 types of block comments:
// /* ... */ - The standard multi line comment.
// /*! ... */ - A comment used to mask code for other clients. In MySQL the content is handled as normal code.
// /*!12345 ... */ - Same as the previous one except code is only used when the given number is lower
//                   than the current server version (specifying so the minimum server version the code can run with).
VERSION_COMMENT_START: ('/*!' DIGITS) (
        {checkVersion(getText())}? // Will set inVersionComment if the number matches.
        | .*? '*/'
    ) -> channel(HIDDEN)
;

// inVersionComment is a variable in the base lexer.
// TODO: use a lexer mode instead of a member variable.
MYSQL_COMMENT_START: '/*!' {status.inVersionComment = true}                     -> channel(HIDDEN);
VERSION_COMMENT_END: '*/' {status.inVersionComment}? {status.inVersionComment = false} -> channel(HIDDEN);
BLOCK_COMMENT:       ( '/**/' | '/*' ~[!] .*? '*/')                         -> channel(HIDDEN);

POUND_COMMENT:    '#' ~([\n\r])*                                   -> channel(HIDDEN);
DASHDASH_COMMENT: DOUBLE_DASH ([ \t] (~[\n\r])* | LINEBREAK | EOF) -> channel(HIDDEN);

fragment DOUBLE_DASH: '--';
fragment LINEBREAK:   [\n\r];

fragment SIMPLE_IDENTIFIER: (DIGIT | [a-zA-Z_$] | DOT_SYMBOL)+;

fragment ML_COMMENT_HEAD: '/*';
fragment ML_COMMENT_END:  '*/';

// As defined in https://dev.mysql.com/doc/refman/8.0/en/identifiers.html.
fragment LETTER_WHEN_UNQUOTED: DIGIT | LETTER_WHEN_UNQUOTED_NO_DIGIT;

fragment LETTER_WHEN_UNQUOTED_NO_DIGIT: [a-zA-Z_$\u0080-\uffff];

// Any letter but without e/E and digits (which are used to match a decimal number).
fragment LETTER_WITHOUT_FLOAT_PART: [a-df-zA-DF-Z_$\u0080-\uffff];
