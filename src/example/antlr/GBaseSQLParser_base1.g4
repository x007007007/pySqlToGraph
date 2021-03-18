parser grammar GBaseSQLParser_base1;

options {
    tokenVocab=GBaseSQLLexer;
}

spacial_str:
      K_GROUPING K_SETS
    | K_IF
    | K_DATE
    | K_MOD
    | K_CHARSET
    | K_USER
    | K_CURRENT_DATE
    | K_INSERT
    | K_REPLACE
    | K_TRIM
    | K_RANK
    | K_DENSE_RANK
    | K_ROW_NUMBER
    | K_LEAD
    | K_LAG
    | K_REPEAT
    | K_DEFAULT
    | K_STATUS

//    keyword
//    |number_functions
//	| char_functions
//	| time_functions
//	| other_functions
//	| group_functions
;

any_name:
	  IDENTIFIER
	| STRING_LITERAL
	//@和中文
	| BIND_PARAMETER
	//_utf8'@'
	| CHERACTOR_STAR
	| BLOB_LITERAL
	| OPEN_PAR any_name CLOSE_PAR
	| G
	| M
	| spacial_str

;

exp_factor2_or:
    (K_OR | PIPE2 | K_XOR)
;

exp_factor3_and:
    (K_AND | AND)
;

exp_factor4_not: (K_NOT | NOT);

factor1_pipe: PIPE;
factor2_amp: AMP;
factor3_lg: (LT2|GT2);
factor4_pm://四则运算加减号
	(PLUS|MINUS) ;
factor5_sdmp: (STAR|(K_DIV | DIV )|(K_MOD | MOD)|POWER_OP);
factor6_pm://interval的加减号
	(PLUS|MINUS);

exp_bool_primary_all: ( K_ALL | K_ANY )?;
exp_bool_primary_notExists:((K_NOT | NOT)? K_EXISTS);


//add by tzm
simpleExprOpt://正负号
	(PLUS | MINUS | TILDE | K_BINARY|NOT)//not应对a=!(1+1)
;
//add by tzm
//factor7:
//	simple_expr (COLLATE_SYM collation_names)?;
relational_op:
	ASSIGN
	| LT
	| GT
	| NOT_EQ1
	| NOT_EQ2
	| NOT_EQ3
	| NOT_EQ4
	| LT_EQ
	| GT_EQ
	|LT_EQ_GT
;

search_modifier:
	(K_IN K_NATURAL K_LANGUAGE K_MODE_SYM)
	| (K_IN K_NATURAL K_LANGUAGE K_MODE_SYM K_WITH K_QUERY_SYM K_EXPANSION_SYM)
	| (K_IN K_BOOLEAN_SYM K_MODE_SYM)
	| (K_WITH K_QUERY_SYM K_EXPANSION_SYM)
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



join_operator:
    COMMA
    |K_INNER K_JOIN
    |K_CROSS K_JOIN
    |K_FULL K_JOIN
    |K_LEFT K_JOIN
    |K_LEFT K_OUTER K_JOIN
    |K_RIGHT K_JOIN
    |K_RIGHT K_OUTER K_JOIN
    |K_JOIN
;

literal_value:
    NUMERIC_LITERAL
    | NUM0X
    | STRING_LITERAL
    | BLOB_LITERAL
    | K_NULL
    // | time_functions
;

unary_operator:
    MINUS   // -
    | PLUS  //
    | TILDE // ~
    | K_NOT
;

export_options:
    ( K_FIELDS K_TERMINATED K_BY
    | K_FIELDS  K_ENCLOSED K_BY
    | K_FIELDS K_ESCAPED K_BY
    | K_COLUMNS K_TERMINATED K_BY
    | K_COLUMNS  K_ENCLOSED K_BY
    | K_COLUMNS K_ESCAPED K_BY
    | K_LINES K_TERMINATED K_BY
    | K_LINES K_STARTING K_BY) any_name
;

compound_operator
	: K_UNION
	| K_UNION K_ALL
	| K_UNION K_DISTINCT
	| K_INTERSECT
	| K_MINUS
;

default_value:
    any_name
    | NUMERIC_LITERAL
    // | STRING_LITERAL
    // | BLOB_LITERAL
    | K_NULL
    // | K_CURRENT_TIME
    // | K_CURRENT_DATE
    | K_CURRENT_TIMESTAMP	(K_ON K_UPDATE K_CURRENT_TIMESTAMP)?
;

transcoding_name:
	  K_LATIN1
	| K_UTF8
;

cast_data_type:
	K_BINARY (K_INTEGER_NUM)?
	| K_CHAR (K_INTEGER_NUM)?
	| K_DATE_SYM
	| K_DATETIME
	| K_DECIMAL_SYM ( K_INTEGER_NUM (COMMA K_INTEGER_NUM)? )?
	| K_SIGNED_SYM (K_INTEGER_SYM)?
	| K_TIME_SYM
	| K_UNSIGNED_SYM (K_INTEGER_SYM)?
	| K_DATE
	| K_TIME
	| K_DECIMAL
;

regexp_rlike: K_REGEXP | K_RLIKE | K_NOT K_REGEXP|K_NOT K_REGEXP
;

boolean_literal: K_TRUE | K_FALSE |K_UNKNOWN;

function_name: any_name
;

collation_name: any_name
;

column_list:
	column_name ( COMMA+column_name )*
;

column_name:
	( ( database_name DOT )? table_name DOT )? any_name ;

column_alias:
    IDENTIFIER
    | STRING_LITERAL
    | ZW//add by qiaoqian 中文
    | any_name
// | keyword  //add by chentie 别名添加关键字方法名称等
// | number_functions
// | char_functions
// | time_functions
// | other_functions
// | group_functions
;

functionList:
    any_name
    //group by grouping sets问题,grouping sets为关键字
    | spacial_str
    //解决token不能作为列名、别名等名称的问题
    //把name、status、函数名等token删除，把相应的关键字变为any_name。
    //	  number_functions
    //	| char_functions
    //	| time_functions
    //	| other_functions
;

table_name:
	any_name
	|K_DUAL
;
key_name: any_name;
name: any_name;
view_name: any_name;
table_alias: any_name;
database_name: any_name;
// | keyword // add by qiaoqian 别名添加关键字方法名称等

table_alias: any_name;
// | keyword // add by qiaoqian 别名添加关键字方法名称等
index_name: any_name;
outfile_name: any_name;

table_definition: (database_name DOT)? table_name;

group_functions: any_name
//解决token不能作为列名、别名等名称的问题
//	K_AVG | K_COUNT | K_MAX | K_MIN | K_SUM
//	| K_BIT_AND | K_BIT_OR | K_BIT_XOR
//	| K_GROUP_CONCAT
//	| K_STD | K_STDDEV | K_STDDEV_POP | K_STDDEV_SAMP
//	| K_VAR_POP | K_VAR_SAMP | K_VARIANCE
;