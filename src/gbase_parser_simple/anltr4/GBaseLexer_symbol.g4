lexer grammar GBaseLexer_symbol;



options {
//    superClass = MySQLBaseLexer;
    tokenVocab = predefined; // Keyword tokens in a predefined order for simpler checks.
    exportMacro = PARSERS_PUBLIC_TYPE;
}



//-------------------------------------------------------------------------------------------------

// Operators
EQUAL_OPERATOR:            '='; // Also assign.
ASSIGN_OPERATOR:           ':=';
NULL_SAFE_EQUAL_OPERATOR:  '<=>';
GREATER_OR_EQUAL_OPERATOR: '>=';
GREATER_THAN_OPERATOR:     '>';
LESS_OR_EQUAL_OPERATOR:    '<=';
LESS_THAN_OPERATOR:        '<';
NOT_EQUAL_OPERATOR:        '!=';
NOT_EQUAL2_OPERATOR:       '<>' -> type(NOT_EQUAL_OPERATOR);

PLUS_OPERATOR:  '+';
MINUS_OPERATOR: '-';
MULT_OPERATOR:  '*';
DIV_OPERATOR:   '/';

MOD_OPERATOR: '%';

LOGICAL_NOT_OPERATOR: '!';
BITWISE_NOT_OPERATOR: '~';

SHIFT_LEFT_OPERATOR:  '<<';
SHIFT_RIGHT_OPERATOR: '>>';

LOGICAL_AND_OPERATOR: '&&';
BITWISE_AND_OPERATOR: '&';

BITWISE_XOR_OPERATOR: '^';

LOGICAL_OR_OPERATOR:
    '||' {self.type = self.CONCAT_PIPES_SYMBOL if status.isSqlModeActive(status.PipesAsConcat) else self.LOGICAL_OR_OPERATOR
    }
;
BITWISE_OR_OPERATOR: '|';

DOT_SYMBOL:         '.';
COMMA_SYMBOL:       ',';
SEMICOLON_SYMBOL:   ';';
COLON_SYMBOL:       ':';
OPEN_PAR_SYMBOL:    '(';
CLOSE_PAR_SYMBOL:   ')';
OPEN_CURLY_SYMBOL:  '{';
CLOSE_CURLY_SYMBOL: '}';
UNDERLINE_SYMBOL:   '_';

JSON_SEPARATOR_SYMBOL:          '->' {status.serverVersion >= 50708}?;  // MYSQL
JSON_UNQUOTED_SEPARATOR_SYMBOL: '->>' {status.serverVersion >= 50713}?; // MYSQL

// The MySQL server parser uses custom code in its lexer to allow base alphanum chars (and ._$) as variable name.
// For this it handles user variables in 2 different ways and we have to model this to match that behavior.
AT_SIGN_SYMBOL: '@';
AT_TEXT_SUFFIX: '@' SIMPLE_IDENTIFIER;

AT_AT_SIGN_SYMBOL: '@@';

NULL2_SYMBOL: '\\N';
PARAM_MARKER: '?';