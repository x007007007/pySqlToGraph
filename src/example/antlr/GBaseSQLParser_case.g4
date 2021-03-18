parser grammar GBaseSQLParser_case;

import
    GBaseSQLParser_base1,
    GBaseSQLParser_base
;

options {
    tokenVocab=GBaseSQLLexer;
}

case_when_statement:
    case_when_statement1 | case_when_statement2
;
case_when_statement1:
    K_CASE
    case_when1_when+
    case_else?
    K_END
;
case_when1_when:
	K_WHEN expression K_THEN bit_expr
;
case_when_statement2:
        K_CASE bit_expr
        case_when2_when+
        case_else ?
        K_END
;
case_when2_when:
	K_WHEN bit_expr K_THEN bit_expr
;
case_else:
	K_ELSE bit_expr
;