parser grammar GBaseSQLParser_base;
import GBaseSQLParser_base1;

options {
    tokenVocab=GBaseSQLLexer;
}

expression:	    exp_factor2 ( exp_factor2_or exp_factor2 )* ;
//exp_factor1:	exp_factor2 ( K_XOR exp_factor2 )* ; //8a不支持xor运算
exp_factor2:	exp_factor3 ( exp_factor3_and exp_factor3 )* ;
exp_factor3:	exp_factor4_not? exp_factor4 ;
exp_factor4:	bool_primary (exp_boolPrimary_isNot_trueFalse_null)? ;

exp_factor2_or:
    (K_OR | PIPE2 | K_XOR)
;

exp_factor3_and:
    (K_AND | AND)
;

exp_factor4_not:  (K_NOT | NOT);


bool_primary:
	   bool_primary_predicate_op_all_subquery //交换两个表达式的位置，由于all为关键字，造成解析错误
	| bool_primary_predicate_op_predicate
	| bool_primary_notExists_subquery
	| predicate
;


bool_primary_predicate_op_all_subquery:
	 predicate relational_op  exp_bool_primary_all subquery
;

bool_primary_predicate_op_predicate:
	 predicate relational_op predicate
;

bool_primary_notExists_subquery:
	exp_bool_primary_notExists subquery
;

predicate:
	 bitExprInOrNotInSubQeuryorExprList
	|bitExprInOrNotBetweenSAndEnd
	|bitExprleftLikeRight
	|bitExprleftNotLikeRightExcapeSimpleExpr
//	| ( bit_expr (K_NOT | NOT)? REGEXP bit_expr )
	|bitExprItem
;

bitExprInOrNotInSubQeuryorExprList:
	bit_expr (K_NOT | NOT)? K_IN (subquery | expression_list)
;

expression_list:
	OPEN_PAR expression ( COMMA expression )* CLOSE_PAR
;

subquery:
	OPEN_PAR dql_stmt_select CLOSE_PAR
;

bitExprInOrNotBetweenSAndEnd:
	bit_expr (K_NOT | NOT)? K_BETWEEN expression (K_AND | AND) expression
;
bitExprleftLikeRight:
	bit_expr K_LIKE expression
;
bitExprleftNotLikeRightExcapeSimpleExpr:
	bit_expr (K_NOT | NOT)? K_LIKE expression (K_ESCAPE expression)?
;
bitExprItem:
	bit_expr
;

bit_expr:
	factor1 ( factor1_pipe factor1 )? ;

factor1_pipe: PIPE;
factor1: factor2 ( factor2_amp factor2 )? ;
factor2_amp: AMP;
factor2: factor3 ( factor3_lg factor3 )? ;
factor3_lg: (LT2|GT2) ;
factor3: factor4 ( factor4_pm factor4 )* ;
factor4_pm://四则运算加减号
	(PLUS|MINUS) ;
factor4: factor5 ( factor5_sdmp factor5 )* ;
factor5_sdmp: (STAR|(K_DIV | DIV )|(K_MOD | MOD)|POWER_OP);
factor5: factor6 ( factor6_pm interval_expr )? ;
factor6_pm://interval的加减号
	(PLUS|MINUS);
factor6:  // wenti,  讨论是否可以简化为？simpleExprOpt？ simple_expr
	simpleExprOpt simple_expr
	| simple_expr ;

exp_boolPrimary_isNot_trueFalse_null: K_IS (K_NOT | NOT)? (boolean_literal|K_NULL);
exp_bool_primary_all: ( K_ALL | K_ANY )?;
exp_bool_primary_notExists:((K_NOT | NOT)? K_EXISTS);

interval_expr:
	K_INTERVAL expression interval_unit
;


//add by tzm
simpleExprOpt://正负号
	(PLUS | MINUS | TILDE | K_BINARY|NOT)//not应对a=!(1+1)
;
//add by tzm
//factor7:
//	simple_expr (COLLATE_SYM collation_names)?;

simple_expr:
	literal_value
	| function_call
	| column_name
	//| param_marker
//	| USER_VAR
//	| expression_list
	| (K_ROW? expression_list)
//	| subquery
	| K_EXISTS? subquery
	//| {identifier expression}
	| match_against_statement
	| case_when_statement
	| interval_expr
	| spacial_str
	|BIND_PARAMETER
	|K_LEVEL
;


interval_unit: any_name
//	  K_SECOND
//	| K_MINUTE
//	| K_HOUR
//	| K_DAY
//	| K_WEEK
//	| K_MONTH
//	| K_QUARTER
//	| K_YEAR
//	| K_SECOND_MICROSECOND
//	| K_MINUTE_MICROSECOND
//	| K_MINUTE_SECOND
//	| K_HOUR_MICROSECOND
//	| K_HOUR_SECOND
//	| K_HOUR_MINUTE
//	| K_DAY_MICROSECOND
//	| K_DAY_SECOND
//	| K_DAY_MINUTE
//	| K_DAY_HOUR
//	| K_YEAR_MONTH
//	| K_MICROSECOND
;


relational_op:
	ASSIGN | LT | GT | NOT_EQ1|NOT_EQ2 | NOT_EQ3 | NOT_EQ4 | LT_EQ | GT_EQ |LT_EQ_GT;
