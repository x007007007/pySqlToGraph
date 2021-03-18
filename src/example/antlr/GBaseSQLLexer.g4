lexer grammar GBaseSQLLexer;
import GBaseSQLLexer_frag,
       GBaseSQLLexer_keyword,
       GBaseSQLLexer_symbol;


IDENTIFIER
    : '"' (~'"' | '""')* '"'
    | '`' (~'`' | '``')* '`'
    | '[' ~']'* ']'
    | [a-zA-Z_] [a-zA-Z_0-9]* // TODO check: needs more chars in set
;

DEFINER:
	IDENTIFIER'@'IDENTIFIER
;

NUMERIC_LITERAL:
    DIGIT+ ( '.' DIGIT* )? ( E [-+]? DIGIT+ )?
    | '.' DIGIT+ ( E [-+]? DIGIT+ )?
;

NUM0X:
	[0] [x] [0-9a-f]+
;

BIND_PARAMETER:
    '?' DIGIT*
    | [:@$] IDENTIFIER
;

//2015-06-26 a='\'char\'' 支持对应 modify by tzm
STRING_LITERAL:
    // : '\'' ( ~'\'' | '\'\'' |'\\\'' )* '\''
    '\''(ESC_SEQ | ~('\\'|'\''))* '\''
;

//20151009 应对select concat('a','\\','b');不能解析的问题
ESC_SEQ:
    '\\'('b'|'t'|'n'|'f'|'r'|'"'|'\''|'\\')
;

//2015-06-26 a='\'char\'' 支持对应 modify by tzm
BLOB_LITERAL:
    X STRING_LITERAL
;

SINGLE_LINE_COMMENT:
    '--' ~[\r\n]* -> channel(HIDDEN)
;

MULTILINE_COMMENT:
    '/*' .*? ( '*/' | EOF ) -> channel(HIDDEN)
;

SPACES:
    [ \u000B\t\r\n] -> channel(HIDDEN)
;

UNEXPECTED_CHAR: .
;

ZW:
	(ZH_CHAR | [0-9])+
;

CHERACTOR_STAR:
    IDENTIFIER'\''AT'\''
;