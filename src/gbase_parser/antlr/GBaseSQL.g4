

grammar GBaseSQL;
import GBaseSQLToken;
@header {
# header here

}

sqls_list
    :
    //	( (sqls	(delimiter+ sqls)* )
    //	|(proc_func_sqls (delimiter + proc_func_sqls)*))
    //	delimiter? EOF
    (proc_func_sqls|sqls)* EOF
;

sqls
    : ddl_stmts
	| dml_stmts
	| dql_stmts
	| dcl_stmts
;


//20150727add by qiaoqian
proc_func_sqls
    : create_proc_stmts
    | create_func_stmts
    | alter_sp
    | drop_sp
    | call_procedure
    | show_sp_status
    | show_create_sp

;

create_proc_stmts
    : K_CREATE (K_DEFINER  '=' DEFINER)? K_PROCEDURE sp_name OPEN_PAR (proc_parameters)? CLOSE_PAR
        characteristic?
        (routine_body)*
    ;

sp_name:
	(database_name DOT)?any_name
;
//begin label
begin_label:
	any_name COLON
;
//end label
end_label:
	any_name
;
//存储过程参数
proc_parameters:
proc_parameter (COMMA+ proc_parameter)*
;
//<参数方向><参数名称><参数数据类型>
proc_parameter:
proc_parameters_director?any_name data_type
;
//<参数方向>
proc_parameters_director:
K_IN|K_OUT|K_INOUT
;
characteristic
    : ((K_CONTAINS K_SQL)
        | (K_NO K_SQL)
        | (K_READS K_SQL K_DATA)
        | (K_MODIFIES K_SQL K_DATA)
        )
    | (K_SQL K_SECURITY) (K_DEFINER | K_INVOKER )
    | K_COMMENT STRING_LITERAL
;
//过程体  编号用于解析时设定的类型使用
routine_body:
	(
	routine_begin_end				//2
	|routine_select_into				//3
	|declare									//4
	|routine_set							//5
	|routine_case_when			//6
	|routine_if								//7
	|routine_iterate						//8
	|routine_leave						//9
	|routine_loop							//10
	|routine_repeat						//11
	|routine_while						//12
	|routine_return						//13
	|routine_open_cursor			//14
	|routine_close_cursor			//15
	|routine_fetch_into				//16
	|routine_prepare					//17
	|routine_execute					//18
	|routine_drop_prepare		//19
	|call_procedure						//20
	|sqls											//1
	|alter_sp									//21
	|drop_sp									//22
	|show_sp_status					//23
	|show_create_sp					//24

	) SCOL?

;
//begin...end
routine_begin_end:
	begin_label? K_BEGIN
	(routine_body)*
	K_END end_label?
;
//declare
declare:
	declare_local_variable
	|declare_handler
	|declare_cursor
	|declare_ref_cursor
;
declare_local_variable:
	K_DECLARE column_list data_type column_def_default?
;
declare_handler:
	K_DECLARE handler_type K_HANDLER K_FOR condition_values routine_body
;
declare_cursor:
	K_DECLARE any_name K_CURSOR K_FOR dql_stmt_select
;
declare_ref_cursor:
	K_DECLARE any_name K_REF K_CURSOR
;
handler_type:
	K_CONTINUE | K_EXIT | K_UNDO
;
condition_values:
	condition_value (COMMA+condition_value)*
;
condition_value:
(K_SQLSTATE K_VALUE? any_name)
| condition_name | K_SQLWARNING | (K_NOT K_FOUND) | K_SQLEXCEPTION
| gbase_error_code
;
condition_name:
	any_name
;
gbase_error_code:
	NUMERIC_LITERAL
;
//SELECT col_name [,...] INTO var_name [,...] table_expr
routine_select_into:
select select_column K_INTO var_name_list select_from? select_where?  select_groupby? select_orderby? select_limit?
;
var_name_list:
	column_alias(COMMA+column_alias)*
;
//SET var_name = expr [, var_name = expr]
routine_set:
	K_SET  routine_set_exprs
;

routine_set_exprs:
	routine_set_expr(COMMA + routine_set_expr)*
;
routine_set_expr:
	set_name ASSIGN expression
;
set_name:
	any_name
;
//cursor & ref cursor
routine_open_cursor:
	routine_cursor
	|routine_ref_cursor
;
//OPEN <游标名称>
routine_cursor:
	K_OPEN any_name
;
//OPEN <游标名称> FOR <SELECT 语句>
routine_ref_cursor:
	K_OPEN any_name K_FOR cursor_for
;
cursor_for:
	dql_stmt_select | (any_name)
;
//FETCH <游标名称> INTO <局部变量>
routine_fetch_into:
	K_FETCH any_name K_INTO 	expression ( COMMA expression )*
;

//CLOSE <游标名称>
routine_close_cursor:
	K_CLOSE any_name
;
//PREPARE stmt_name FROM open_cur_stmt
routine_prepare:
	K_PREPARE any_name K_FROM cursor_for
;
//EXECUTE stmt_name [USING @var_name [, @var_name] ...]
routine_execute:
	K_EXECUTE any_name (K_USING var_name_list)?
;
//{DEALLOCATE | DROP} PREPARE stmt_name
routine_drop_prepare:
	(K_DEALLOCATE | K_DROP) K_PREPARE any_name
;
//repeat
/*
 * REPEAT
<执行体>
UNTIL<退出条件>
END REPEAT;
 */
 routine_repeat:
 	begin_label? K_REPEAT (routine_body)* K_UNTIL expression K_END K_REPEAT end_label?
 ;

 //case
 routine_case_when:
        routine_case_when1 | routine_case_when2
;
routine_case_when1:
        K_CASE
        ( routine_case_when1_when )+
        routine_else?
        K_END K_CASE
;
routine_case_when1_when:
	K_WHEN expression K_THEN (routine_body)*
;

routine_case_when2:
        K_CASE bit_expr
        ( routine_case_when2_when )+
       routine_else?
        K_END K_CASE
;
routine_case_when2_when:
	K_WHEN bit_expr K_THEN (routine_body)*
;

//if
routine_if:
		K_IF K_NOT ? expression K_THEN (routine_body)* routine_else? K_END K_IF
;
routine_else:
	K_ELSE (routine_body)*
;

//iterate
routine_iterate:
	K_ITERATE any_name
;

//leave
routine_leave:
	K_LEAVE any_name
;

//loop
routine_loop:
	begin_label? K_LOOP (routine_body)* K_END K_LOOP end_label?
;

//while
routine_while:
	begin_label? K_WHILE expression K_DO (routine_body)* K_END K_WHILE end_label?
;

//return
routine_return:
	K_RETURN expression
;

create_func_stmts:
	K_CREATE (K_DEFINER  '=' DEFINER)? K_FUNCTION  sp_name OPEN_PAR (proc_parameters)? CLOSE_PAR
	K_RETURNS data_type (K_CHARSET transcoding_name)?
	characteristic?
	(routine_body)*
;

//alter procedure or function
alter_sp:
	K_ALTER (K_PROCEDURE | K_FUNCTION) sp_name characteristic
;

//drop procedure or function
drop_sp:
	K_DROP  (K_PROCEDURE | K_FUNCTION) if_exists? sp_name
;

//call procedure
call_procedure:
	K_CALL sp_name OPEN_PAR (expression ( COMMA expression )*)? CLOSE_PAR
;

//show procedure or function status
show_sp_status:
	K_SHOW (K_PROCEDURE | K_FUNCTION) K_STATUS
;

//show create procedure or function status
show_create_sp:
	K_SHOW K_CREATE (K_PROCEDURE | K_FUNCTION) sp_name
;
/*
 * DQL--
 */
dql_stmts:
	dql_stmt_select
	|dql_stmt_intersect
	|dql_stmt_minus
;

ddl_stmts
:
	create_database
	|drop_database
	|create_table
	|create_table_select
	|create_table_like
	|alter_table
	|rename_table
	|truncate_table
	|drop_table
	|create_view
	|alter_view
	|drop_view
	|create_index
	|drop_index
	|show_index
	//       |create_proc
	//       |create_func
;

create_database
:
K_CREATE K_DATABASE if_not_exists? database_name
;

drop_database
:
K_DROP K_DATABASE if_exists? database_name
;


if_not_exists
:
	K_IF K_NOT K_EXISTS
;

if_exists
:
 	K_IF K_EXISTS
;

create_table
:K_CREATE  table_temporary K_TABLE if_not_exists? table_definition
	OPEN_PAR columns_definition (COMMA+key_option)* (COMMA+group_definition)* CLOSE_PAR (table_options)*
;

table_temporary
:
(K_TEMPORARY)?
;

table_definition
:
	(database_name DOT)? table_name
;

columns_definition
:
 column_definition(COMMA+column_definition)*
;

column_definition
:
	column_name data_type
	column_def_nullable?
	column_def_default?
	column_def_comment?
	column_def_compress?
;

column_def_nullable
:K_NOT K_NULL | K_NULL
;

column_def_default
: K_DEFAULT default_value
;

column_def_comment
: K_COMMENT column_comment_value
;

column_def_compress
:
K_COMPRESS  OPEN_PAR column_compress_value(COMMA+column_compress_value)? CLOSE_PAR
;

key_option
:
K_KEY key_name OPEN_PAR  column_name  CLOSE_PAR index_key_size
	(K_USING K_HASH (K_GLOBAL|K_LOCAL)?)?
;

group_definition
:
K_GROUPED any_name? OPEN_PAR column_list CLOSE_PAR column_def_compress?
;


//TODO
table_options
:
column_def_compress
|(K_ENGINE ASSIGN any_name)
|(K_DEFAULT K_CHARSET  ASSIGN transcoding_name)
|(K_NOLOCK)
|(K_REPLICATED | (K_DISTRIBUTED K_BY OPEN_PAR column_name CLOSE_PAR))
|(K_COMMENT (ASSIGN)?table_comment_value)
|(K_NOCOPIES)
|(autoextend_on)
;

create_table_select
:
K_CREATE table_temporary K_TABLE table_definition column_definition_select? table_options_select? K_AS ? dql_stmt_select
;

column_definition_select
:
OPEN_PAR columns_definition  (COMMA+key_option)* (COMMA+group_definition)* CLOSE_PAR
;

table_options_select
:
K_REPLICATED | (K_DISTRIBUTED K_BY OPEN_PAR column_name CLOSE_PAR) |K_NOLOCK  |K_NOCOPIES
;

create_table_like
:
K_CREATE table_temporary K_TABLE table_definition K_LIKE table_definition
;

alter_table
:
 alter_tablename alter_specifications
;

alter_tablename
:
K_ALTER K_TABLE table_definition
;

alter_specifications
:
alter_specification(COMMA + alter_specification)*
;

alter_specification
:
add_column_one
|add_column_multi
|change_column
|modify_column
|rename_table_name
|drop_column
|drop_nocopies
|shrink_space
|autoextend_on
|autoextend_off
|compress_col
|column_def_compress
|add_grouped
|drop_grouped
|cache
|compress_table
;

add_column_one
:
K_ADD (K_COLUMN)?alter_column_definition
;

alter_column_definition
:
column_definition(K_FIRST | (K_AFTER column_name ))?
;

add_column_multi
:
K_ADD (K_COLUMN)? OPEN_PAR columns_definition CLOSE_PAR
;

change_column
:
K_CHANGE (K_COLUMN)? column_name column_definition
;

modify_column
:
K_MODIFY  (K_COLUMN)? column_definition (K_FIRST | K_AFTER column_name)
;

rename_table_name
:
K_RENAME (K_TO)? table_definition
;

drop_column
:
K_DROP  (K_COLUMN)? column_name
;

drop_nocopies
:
K_DROP K_NOCOPIES
;

shrink_space
:
K_SHRINK K_SPACE
;

autoextend_on
:
K_AUTOEXTEND K_ON K_NEXT NUMERIC_LITERAL (('M'|'m') | ('g'|'G'))?
;

autoextend_off
:
K_AUTOEXTEND K_OFF
;

compress_col
:
K_ALTER  (K_COLUMN)? column_name K_COMPRESS  OPEN_PAR column_compress_value CLOSE_PAR
;

compress_table
:
K_ALTER  K_COMPRESS  OPEN_PAR column_compress_value COMMA+column_compress_value CLOSE_PAR
;

add_grouped
:
K_ADD group_definition
;

drop_grouped
:
K_DROP K_GROUPED any_name
;

cache
:
K_CACHE OPEN_PAR column_list CLOSE_PAR
;

rename_table
:
K_RENAME K_TABLE table_definition K_TO table_definition
;

truncate_table
:
K_TRUNCATE (K_TABLE)? table_definition
;

drop_table
:
K_DROP table_temporary K_TABLE if_exists? table_definition
;

/*
 *
 */
create_view
: create_replace_view view_definition
	columns_list? K_AS dql_stmt_select
;

create_replace_view
:
K_CREATE (K_OR K_REPLACE)? (K_ALGORITHM '=' any_name K_DEFINER '='DEFINER K_SQL K_SECURITY K_DEFINER)? K_VIEW
;

columns_list
:
OPEN_PAR column_list CLOSE_PAR
;

column_list
:	column_name ( COMMA+column_name )*
;

/*
 *
 */
alter_view
: K_ALTER (K_ALGORITHM '=' any_name K_DEFINER '='DEFINER K_SQL K_SECURITY K_DEFINER)? K_VIEW view_definition
	columns_list? K_AS dql_stmt_select
;

view_definition
:
	(database_name DOT)? view_name
;

/*
 *
 */
drop_view
: K_DROP K_VIEW if_exists?  view_definition
;

/*
 *
 */
create_index
:
K_CREATE K_INDEX index_name K_ON  table_definition OPEN_PAR column_name CLOSE_PAR index_key_size index_using_hash
;

index_key_size
: (( K_KEYDCSIZE ASSIGN NUMERIC_LITERAL)
	|(K_KEYBLOCKSIZE ASSIGN NUMERIC_LITERAL ))?
;

index_using_hash
:
	(K_USING K_HASH (K_GLOBAL|K_LOCAL)?)?
;

/*
 *
 */
drop_index
: K_DROP K_INDEX index_name K_ON table_definition
;

/*
 *
 */
show_index
: K_SHOW K_INDEX K_FROM table_definition
;


/*
 * dml_stmts
 */
dml_stmts
:
	dml_stmt_insert
	|dml_stmt_update
	|dml_stmt_delete
	|dml_stmt_merge
	//|dql_stmt_select  move to dql
	|dml_stmt_insert_select
;

/*
 *
 */
dml_stmt_insert
: K_INSERT K_INTO? table_definition columns_list?
	K_VALUES insert_value_list
;
insert_value_list
:
insert_values(COMMA+insert_values)*
;

insert_values
:
	OPEN_PAR insert_value CLOSE_PAR
;

insert_value
:
expression (COMMA+expression)*
;

dml_stmt_insert_select
:
K_INSERT K_INTO? table_definition columns_list? dql_stmt_select
;

/*
 *
 */
dml_stmt_update
: K_UPDATE table_or_subquery_tablename
	K_SET set_columns_value
	select_where?
;

set_columns_value
:
	set_one_value ( COMMA set_one_value)*
;

set_one_value
:
	expression '=' expression
;

/*
 *
 */
//expression
// : literal_value
// | BIND_PARAMETER
// | column_full_name
// | unary_operator expression
// | expression '||' expression
// | expression ( '*' | '/' | '%' ) expression
// | expression ( '+' | '-' ) expression
// | expression ( '<<' | '>>' | '&' | '|' ) expression
// | expression ( '<' | '<=' | '>' | '>=' ) expression
// | expression ( '=' | '==' | '!=' | '<>' | K_IS | K_IS K_NOT | K_IN | K_LIKE | K_GLOB | K_MATCH | K_REGEXP ) expression
// | expression K_AND expression
// | expression K_OR expression
// | function_name OPEN_PAR ( K_DISTINCT? expression ( ',' expression )* | '*' )? CLOSE_PAR
// | OPEN_PAR expression CLOSE_PAR
//// | K_CAST '(' expression K_AS type_name ')'
// | expression K_COLLATE collation_name
// | expression K_NOT? ( K_LIKE | K_GLOB | K_REGEXP | K_MATCH ) expression ( K_ESCAPE expression )?
// | expression ( K_ISNULL | K_NOTNULL | K_NOT K_NULL )
// | expression K_IS K_NOT? expression
// | expression K_NOT? K_BETWEEN expression K_AND expression
// | expression K_NOT? K_IN ( OPEN_PAR ( dql_stmt_select
//                          | expression ( ',' expression )*
//                          )?
//                      CLOSE_PAR
//                    | ( database_name '.' )? table_name )
// | ( ( K_NOT )? K_EXISTS )? OPEN_PAR dql_stmt_select CLOSE_PAR
// | K_CASE expression? ( K_WHEN expression K_THEN expression )+ ( K_ELSE expression )? K_END
// //| raise_function  del by tzm 鍜变滑濂藉儚涓嶆秹鍙�// ;
//
////add by tzm start{
//column_full_name:
// 	( ( database_name '.' )? table_name '.' )? column_name
//;
////add by tzm end}

//2015-06-04 add by start{
// expression statement
exp_factor2_or:
(K_OR | PIPE2 | K_XOR)
;
exp_factor3_and:
(K_AND | AND)
;

exp_factor4_not:(K_NOT | NOT);
exp_boolPrimary_isNot_trueFalse_null: K_IS (K_NOT | NOT)? (boolean_literal|K_NULL);
exp_bool_primary_all: ( K_ALL | K_ANY )?;
exp_bool_primary_notExists:((K_NOT | NOT)? K_EXISTS);

bool_primary_predicate_op_predicate:
	 predicate relational_op predicate
;
bool_primary_predicate_op_all_subquery:
	 predicate relational_op  exp_bool_primary_all subquery
;
bool_primary_notExists_subquery:
	exp_bool_primary_notExists subquery
;
//expression:
//	expression
//;
expression:	exp_factor2 ( exp_factor2_or exp_factor2 )* ;
//exp_factor1:	exp_factor2 ( K_XOR exp_factor2 )* ; //8a不支持xor运算
exp_factor2:	exp_factor3 ( exp_factor3_and exp_factor3 )* ;
exp_factor3:	exp_factor4_not? exp_factor4 ;
exp_factor4:	bool_primary ( exp_boolPrimary_isNot_trueFalse_null)? ;
bool_primary:
	   bool_primary_predicate_op_all_subquery //交换两个表达式的位置，由于all为关键字，造成解析错误
	| bool_primary_predicate_op_predicate
	| bool_primary_notExists_subquery
	| predicate
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
factor1_pipe
:
PIPE
;
factor1:
	factor2 ( factor2_amp factor2 )? ;
factor2_amp:
	AMP;
factor2:
	factor3 ( factor3_lg factor3 )? ;
factor3_lg:
	 (LT2|GT2) ;
factor3:
	factor4 ( factor4_pm factor4 )* ;
factor4_pm://四则运算加减号
	(PLUS|MINUS) ;
factor4:
	factor5 ( factor5_sdmp factor5 )* ;
factor5_sdmp:
	(STAR|(K_DIV | DIV )|(K_MOD | MOD)|POWER_OP);
factor5:
	factor6 ( factor6_pm interval_expr )? ;
factor6_pm://interval的加减号
	(PLUS|MINUS);
factor6:  // wenti,  讨论是否可以简化为？simpleExprOpt？ simple_expr
	simpleExprOpt simple_expr
	| simple_expr ;
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

spacial_str:
K_GROUPING K_SETS
|K_IF
|K_DATE
|K_MOD
|K_CHARSET
|K_USER
|K_CURRENT_DATE
|K_INSERT
|K_REPLACE
|K_TRIM
|K_RANK
| K_DENSE_RANK
| K_ROW_NUMBER
|K_LEAD
|K_LAG
|K_REPEAT
|K_DEFAULT
|K_STATUS

//    keyword
//    |number_functions
//	| char_functions
//	| time_functions
//	| other_functions
//	| group_functions
	;
function_call:
	 function_call_list
	|function_call_str
	|function_call_cast
	|function_call_convert_comma
	|function_call_convert_using
	|function_call_trim
	|function_call_not
	|function_call_group
	|function_call_count
	|function_call_extract
	|function_call_olap_not_groupby
;
//select *
//from td
//where substr(c,1) <> some
//
//(
//select substr(c,1)
//from tr
//where tr.i = td.i
//);
//针对function（select）修改
function_call_param:
	dql_stmt_select | expression
;
function_call_list:
	 functionList ( OPEN_PAR (function_call_param (COMMA function_call_param)*)? CLOSE_PAR )
;
function_call_str:
	functionList OPEN_PAR function_call_param* CLOSE_PAR
;
function_call_cast:
	K_CAST OPEN_PAR function_call_param K_AS cast_data_type CLOSE_PAR
;
function_call_convert_comma:
	K_CONVERT OPEN_PAR function_call_param COMMA cast_data_type CLOSE_PAR
;
function_call_convert_using:
	K_CONVERT OPEN_PAR function_call_param K_USING transcoding_name CLOSE_PAR
;
function_call_trim://2015-06-24 add by chentie 添加trim函数
	K_TRIM OPEN_PAR (K_BOTH|K_LEADING|K_TRAILING) any_name K_FROM any_name CLOSE_PAR
;
function_call_not://2015-06-24 add by chentie 添加not函数
	K_NOT OPEN_PAR function_call_param K_REGEXP function_call_param CLOSE_PAR
;
function_call_group:
	group_functions OPEN_PAR ( K_ALL | K_DISTINCT )? bit_expr CLOSE_PAR
;
function_call_count://modify by tzm for select count(*) from b
//	K_COUNT OPEN_PAR STAR CLOSE_PAR
any_name OPEN_PAR STAR CLOSE_PAR
;
function_call_extract://2015-06-29 add by qiaoqian 添加extract函数
	K_EXTRACT OPEN_PAR interval_unit K_FROM any_name CLOSE_PAR
;

//2015-12-10 add by qiaoqian 添加olap函数，非group by 部分
function_call_olap_not_groupby:
	((K_RANK | K_DENSE_RANK | K_ROW_NUMBER |) OPEN_PAR  CLOSE_PAR
		|function_call_group
		| function_call_count
		|((K_LEAD|K_LAG) OPEN_PAR  function_call_param (COMMA function_call_param COMMA default_value)? CLOSE_PAR)
	)
	K_OVER  OPEN_PAR (K_PARTITION K_BY column_list)? select_orderby? CLOSE_PAR
;

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
match_against_statement:
	K_MATCH (column_name (COMMA column_name)* ) K_AGAINST (expression (search_modifier)? )
;

column_name:
	( ( database_name DOT )? table_name DOT )? any_name ;

expression_list:
	OPEN_PAR expression ( COMMA expression )* CLOSE_PAR
 ;

interval_expr:
	K_INTERVAL expression interval_unit
;

subquery:
	OPEN_PAR dql_stmt_select CLOSE_PAR
;
boolean_literal:	K_TRUE | K_FALSE |K_UNKNOWN;

relational_op:
	(ASSIGN | EMPTY) | LT | GT | (EMPTY | NOT_EQ1|NOT_EQ2 | NOT_EQ3 | NOT_EQ4) | LT_EQ | GT_EQ |LT_EQ_GT;
functionList:
any_name
//group by grouping sets问题,grouping sets为关键字
|spacial_str
//解决token不能作为列名、别名等名称的问题
//把name、status、函数名等token删除，把相应的关键字变为any_name。
//	  number_functions
//	| char_functions
//	| time_functions
//	| other_functions
;

interval_unit:
any_name
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

search_modifier:
	(K_IN K_NATURAL K_LANGUAGE K_MODE_SYM)
	| (K_IN K_NATURAL K_LANGUAGE K_MODE_SYM K_WITH K_QUERY_SYM K_EXPANSION_SYM)
	| (K_IN K_BOOLEAN_SYM K_MODE_SYM)
	| (K_WITH K_QUERY_SYM K_EXPANSION_SYM)
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
number_functions:
any_name
//解决token不能作为列名、别名等名称的问题
//把name、status、函数名等token删除，把相应的关键字变为any_name。
//	  K_ABS
//	| K_ACOS
//	| K_ASIN
//	| K_ATAN2
//	| K_ATAN
//	| K_CEIL
//	| K_CEILING
//	| K_CONV
//	| K_COS
//	| K_COT
//	| K_CRC32
//	| K_DEGREES
//	| K_EXP
//	| K_FLOOR
//	| K_LN
//	| K_LOG10
//	| K_LOG2
//	| K_LOG
//	| K_MOD
//	| K_PI
//	| K_POW
//	| K_POWER
//	| K_RADIANS
//	| K_RAND
//	| K_ROUND
//	| K_SIGN
//	| K_SIN
//	| K_SQRT
//	| K_TAN
//	| K_TRUNCATE
;

char_functions:
    any_name
//解决token不能作为列名、别名等名称的问题
//把name、status、函数名等token删除，把相应的关键字变为any_name。
//	  K_ASCII_SYM
//	| K_BIN
//	| K_BIT_LENGTH
//	| K_CHAR_LENGTH
//	| K_CHAR
//	| K_CONCAT_WS
//	| K_CONCAT
//	| K_ELT
//	| K_EXPORT_SET
//	| K_FIELD
//	| K_FIND_IN_SET
//	| K_FORMAT
//	| K_FROM_BASE64
//	| K_HEX
//	| K_INSERT
//	| K_INSTR
//	| K_LEFT
//	| K_LENGTH
//	| K_LOAD_FILE
//	| K_LOCATE
//	| K_LOWER
//	| K_LPAD
//	| K_LTRIM
//	| K_MAKE_SET
//	| K_MID
//	| K_OCT
//	| K_ORD
//	| K_QUOTE
//	| K_REPEAT
//	| K_REPLACE
//	| K_REGEXP
//	| K_REVERSE
//	| K_RIGHT
//	| K_RPAD
//	| K_RTRIM
//	| K_SOUNDEX
//	| K_SPACE
//	| K_STRCMP
//	| K_SUBSTRING_INDEX
//	| K_SUBSTRING
//	| K_TO_BASE64
//	| K_TRIM
//	| K_UNHEX
//	| K_UPPER
//	| K_WEIGHT_STRING
;

time_functions:
any_name
//解决token不能作为列名、别名等名称的问题
//把name、status、函数名等token删除，把相应的关键字变为any_name。
//	  K_ADDDATE
//	| K_ADDTIME
//	| K_CONVERT_TZ
//	| K_CURDATE
//	| K_CURRENT_DATE
//	| K_CURTIME
//	| K_CURRENT_TIMESTAMP
//	| K_CURRENT_TIME
//	| K_DATE
//	| K_DATE_ADD
//	| K_DATE_FORMAT
//	| K_DATE_SUB
//	| K_DATE_SYM
//	| K_DATEDIFF
//	| K_DAY
//	| K_DAYNAME
//	| K_DAYOFMONTH
//	| K_DAYOFWEEK
//	| K_DAYOFYEAR
//	| K_EXTRACT
//	| K_FROM_DAYS
//	| K_FROM_UNIXTIME
//	| K_GET_FORMAT
//	| K_HOUR
//	| K_LAST_DAY
//	|K_LOCALTIME
//	|K_LOCALTIMESTAMP
//	| K_MAKEDATE
//	| K_MAKETIME
//	| K_MICROSECOND
//	| K_MINUTE
//	| K_MONTH
//	| K_MONTHNAME
//	| K_NOW
//	| K_PERIOD_ADD
//	| K_PERIOD_DIFF
//	| K_QUARTER
//	| K_SEC_TO_TIME
//	| K_SECOND
//	| K_SECOND_MICROSECOND
//	| K_STR_TO_DATE
//	| K_SUBTIME
//	| K_SYSDATE
//	| K_TIME
//	| K_TIME_FORMAT
//	| K_TIME_TO_SEC
//	| K_TIME_SYM
//	| K_TIMEDIFF
//	| K_TIMESTAMP
//	| K_TIMESTAMPADD
//	| K_TIMESTAMPDIFF
//	| K_TO_DAYS
//	| K_TO_SECONDS
//	| K_UNIX_TIMESTAMP
//	| K_UTC_DATE
//	| K_UTC_TIME
//	| K_UTC_TIMESTAMP
//	| K_WEEK
//	| K_WEEKDAY
//	| K_WEEKOFYEAR
//	| K_YEAR
//	| K_YEARWEEK
//	|K_TO_DATE
;

other_functions:
any_name
//解决token不能作为列名、别名等名称的问题
//把name、status、函数名等token删除，把相应的关键字变为any_name。
//	K_MAKE_SET | K_LOAD_FILE
//	| K_IF | K_IFNULL
//	| K_AES_ENCRYPT | K_AES_DECRYPT
//	| K_DECODE | K_ENCODE
//	| K_DES_DECRYPT | K_DES_ENCRYPT
//	| K_ENCRYPT | K_MD5
//	| K_OLD_PASSWORD | K_PASSWORD
//	| K_BENCHMARK | K_CHARSET | K_COERCIBILITY | K_COLLATION | K_CONNECTION_ID
//	| K_CURRENT_USER | K_DATABASE | K_SCHEMA | K_USER | K_SESSION_USER | K_SYSTEM_USER
//	| K_VERSION_SYM
//	| K_FOUND_ROWS | K_LAST_INSERT_ID | K_DEFAULT
//	| K_GET_LOCK | K_RELEASE_LOCK | K_IS_FREE_LOCK | K_IS_USED_LOCK | K_MASTER_POS_WAIT
//	| K_INET_ATON | K_INET_NTOA
//	| K_NAME_CONST
//	| K_SLEEP
//	| K_UUID
//	| K_VALUES
//	| any_name  //2016-06-09 add by tzm 应对自定义函数
//	| K_ISNULL  //2016-06-24 add by chentie 添加isnull函数
//	|K_COALESCE
//	|K_GREATEST
//	|K_LEAST
//	| K_GROUPING K_SETS
;

group_functions:
any_name
//解决token不能作为列名、别名等名称的问题
//	K_AVG | K_COUNT | K_MAX | K_MIN | K_SUM
//	| K_BIT_AND | K_BIT_OR | K_BIT_XOR
//	| K_GROUP_CONCAT
//	| K_STD | K_STDDEV | K_STDDEV_POP | K_STDDEV_SAMP
//	| K_VAR_POP | K_VAR_SAMP | K_VARIANCE
;

//2015-06-04 add by tzm }end

literal_value
 : NUMERIC_LITERAL
 |NUM0X
 | STRING_LITERAL
 | BLOB_LITERAL
 | K_NULL
// | time_functions
 ;
unary_operator
 : '-'
 | '+'
 | '~'
 | K_NOT
 ;
function_name
 : any_name
 ;

collation_name
 : any_name
 ;

//type_name
// : name+ ( '(' signed_number ')'
//         | '(' signed_number ',' signed_number ')' )?
// ;

raise_function
 : K_RAISE '(' ( K_IGNORE
               | ( K_ROLLBACK | K_ABORT | K_FAIL ) ',' error_message )
           ')'
 ;

dql_stmt_select
 :
//  select_or_values ( compound_operator select_or_values )*
//   ( K_ORDER K_BY ordering_term ( ',' ordering_term )* )?
//   ( K_LIMIT expression ( ( K_OFFSET | ',' ) expression )? )?
//   ( K_INTO K_OUTFILE outfile_name export_options?)?
	(select_or_values
	| dql_stmt_union )
	select_into_outfile?
 ;

select_or_values
 : select select_column select_from? select_where? hierarchical_clause? select_groupby? select_orderby? select_limit?
 //| K_VALUES '(' expression ( ',' expression )* ')' ( ',' '(' expression ( ',' expression )* ')' )*
 ;

select
:
K_SELECT ( K_DISTINCT | K_ALL |K_DISTINCTROW)?
;

dql_stmt_union:
union_item (union_operator_item)* select_orderby? select_limit?
;

union_operator_item:
	compound_operator union_item
;
union_item:
	select_or_values
	|OPEN_PAR select_or_values CLOSE_PAR
;

select_into_outfile:
	 K_INTO K_OUTFILE outfile_name export_options*
;

hierarchical_clause:
	(K_START K_WITH expression)? K_CONNECT K_BY connect_conditions
	|K_CONNECT K_BY connect_conditions (K_START K_WITH expression)?
	select_orderby?
;
connect_conditions:
 K_PRIOR expression  relational_op expression
 | expression relational_op K_PRIOR expression
 |expression relational_op connect_conditions
 |expression
;
select_groupby:
	K_GROUP K_BY expression ( ',' expression )* select_groupby_having?
;
select_groupby_having:
	K_HAVING expression
;
select_orderby:
        K_ORDER K_SIBLINGS? K_BY ordering_term ( ',' ordering_term )*
;
select_limit:
	K_LIMIT expression  select_limit_offset?
;

select_limit_offset:
	 ( K_OFFSET |COMMA) expression
;

select_column
:
	result_column ( ',' result_column )*
;
select_from
:
	K_FROM ( (table_or_subquery ( COMMA table_or_subquery )*) | join_clause )
;
select_where
:
	K_WHERE expression
;

compound_operator
	: K_UNION
	| K_UNION K_ALL
	| K_UNION K_DISTINCT
	| K_INTERSECT
	| K_MINUS
 ;

export_options
 :
 ( K_FIELDS K_TERMINATED K_BY
 | K_FIELDS  K_ENCLOSED K_BY
 | K_FIELDS K_ESCAPED K_BY
 | K_COLUMNS K_TERMINATED K_BY
 | K_COLUMNS  K_ENCLOSED K_BY
 | K_COLUMNS K_ESCAPED K_BY
 | K_LINES K_TERMINATED K_BY
 | K_LINES K_STARTING K_BY) any_name
 ;

ordering_term
// : expression ( K_COLLATE collation_name )? ( K_ASC | K_DESC )?
 : expression ( K_ASC | K_DESC )?
 ;

result_column
 : STAR
 | table_definition DOT STAR
 | result_expr
 ;
 result_expr
 :
 expression ( K_AS? column_alias )?
 |expression regexp_rlike expression
 ;

 regexp_rlike:
 	K_REGEXP | K_RLIKE | K_NOT K_REGEXP|K_NOT K_REGEXP
 ;
table_or_subquery
 : table_or_subquery_tablename//( K_INDEXED K_BY index_name | K_NOT K_INDEXED )?
 | table_or_subquery_subquery
 | table_or_subquery_select
 ;

 table_or_subquery_tablename:
 	 ( database_name DOT )? table_name ( K_AS? table_alias )?
 ;
 table_or_subquery_subquery:
 	OPEN_PAR ( (table_or_subquery ( COMMA table_or_subquery )*) | join_clause ) CLOSE_PAR ( K_AS? table_alias )?
 ;
 table_or_subquery_select:
 	OPEN_PAR dql_stmt_select CLOSE_PAR ( K_AS? table_alias )?
 ;
 join_clause
 : table_or_subquery ( join_reference_and_conditon )*
 ;
 join_reference_and_conditon:
	join_operator table_or_subquery join_condition?
 ;

 column_alias
 : IDENTIFIER
 | STRING_LITERAL
 |ZW//add by qiaoqian 中文
 |any_name
// | keyword  //add by chentie 别名添加关键字方法名称等
// | number_functions
// | char_functions
// | time_functions
// | other_functions
// | group_functions
 ;

 table_alias
 :
 any_name
// | keyword // add by qiaoqian 别名添加关键字方法名称等
 ;

 index_name
 : any_name
 ;

 outfile_name
 : any_name
 ;

 join_operator
 : ','
 |K_INNER  K_JOIN
 |K_CROSS K_JOIN
 |K_FULL K_JOIN
 |K_LEFT K_JOIN
 |K_LEFT K_OUTER K_JOIN
 |K_RIGHT K_JOIN
 |K_RIGHT K_OUTER K_JOIN
 |K_JOIN
 ;

 join_condition
 :  join_condition_on   |  join_condition_using
 ;
 join_condition_on:
 	K_ON expression
 ;
 join_condition_using:
 	K_USING OPEN_PAR column_name ( COMMA column_name )* CLOSE_PAR
 ;

 error_message
 : STRING_LITERAL
 ;

/*
 *
 */
dml_stmt_delete
: K_DELETE K_FROM? table_or_subquery_tablename
  select_where?
;

/*
 *
 */
dml_stmt_merge
:K_MERGE (K_INTO)? table_or_subquery_tablename
K_USING  table_refrence  K_ON merge_condition
match_condition
;

table_refrence
:(table_definition
|dql_stmt_select) table_alias?
;

merge_condition
:table_definition DOT column_name ASSIGN table_definition DOT column_name
;

match
:
K_WHEN K_MATCHED K_THEN K_UPDATE  K_SET set_columns_value
;

not_match
:
K_WHEN K_NOT K_MATCHED K_THEN K_INSERT   columns_list? K_VALUES insert_values
;

match_condition
:
match
|not_match
|match not_match
;

/*
 *
 */
dql_stmt_intersect:
	dql_stmt_select K_INTERSECT dql_stmt_select
;
dql_stmt_minus:
	dql_stmt_select  K_MINUS dql_stmt_select
;

/*
 *
 */

/*
 *
*/
database_name
:
	any_name
;
table_name
:
	any_name
	|K_DUAL
;
key_name
:
	any_name
;

name
:
	any_name
;

view_name
: any_name
;

data_type
:
 data_type_name ( '(' signed_number ')'
         | '(' signed_number ',' signed_number ')' )?
 ;
 data_type_name:
 K_TINYINT
 |K_SMALLINT
 |K_INT
 |K_BIGINT
 |K_FLOAT
 |K_DOUBLE
 |K_DECIMAL
 |K_CHAR
 |K_VARCHAR
 |K_TEXT
 |K_BLOB
 |K_DATE
 |K_DATETIME
 |K_TIME
 |K_TIMESTAMP
 ;
signed_number
 : ( '+' | '-' )? NUMERIC_LITERAL
 ;
//TODO
default_value
:
any_name
| NUMERIC_LITERAL
// | STRING_LITERAL
// | BLOB_LITERAL
 | K_NULL
// | K_CURRENT_TIME
// | K_CURRENT_DATE
 | K_CURRENT_TIMESTAMP	(K_ON K_UPDATE K_CURRENT_TIMESTAMP)?
;
//TODO
column_comment_value
:any_name
;

column_compress_value
:
NUMERIC_LITERAL
;


//TODO
table_comment_value
:any_name
;

any_name
:
	IDENTIFIER
	| STRING_LITERAL
	//@和中文
	|BIND_PARAMETER
	//_utf8'@'
	|CHERACTOR_STAR
	|BLOB_LITERAL
	| '(' any_name ')'
	|('G'|'g')
	|('M'|'m')
	|spacial_str

;

CHERACTOR_STAR
:
  IDENTIFIER'\''AT'\''
 ;

keyword
:
	//add GBase key word
	K_ACCESSIBLE
	|K_ADD
	|K_ALL
	|K_ALTER
	|K_ANALYZE
	|K_AND
	|K_AS
	|K_ASC
	|K_ASENSITIVE

	|K_BEFORE
	|K_BETWEEN
	|K_BIGINT
	|K_BINARY
	|K_BLOB
//	|K_BOOLEAN
	|K_BOTH
	|K_BY

	|K_CALL
	|K_CASCADE
	|K_CASE
	|K_CHANGE
	|K_CHAR
	|K_CHARACTER
	|K_CHARSET
	|K_CHECK
//	|K_CLUSTER
	|K_COLLATE
	|K_COLUMN
	|K_COMPRESS
	|K_CONDITION
	|K_CONNECT
	|K_CONSTRAINT
	|K_CONTINUE
	|K_CONVERT
	|K_CREATE
	|K_CROSS
	|K_CURRENT_DATE
	|K_CURRENT_DATETIME
//	|K_CURRENT_ROW
	|K_CURRENT_TIME
	|K_CURRENT_TIMESTAMP
	|K_CURRENT_USER
	|K_CURSOR

	|K_DATABASE
	|K_DATABASES
//	|K_DATACOPYMAP
//	|K_DATADIR
//	|K_DATASTATE
	|K_DATE
	|K_DAY_HOUR
	|K_DAY_MICROSECOND
	|K_DAY_MINUTE
	|K_DAY_SECOND
	|K_DEC
	|K_DECIMAL
	|K_DECLARE
	|K_DEFAULT
	|K_DELAYED
	|K_DELETE
	|K_DESC
	|K_DESCRIBE
	|K_DETERMINISTIC
	|K_DISTINCT
	|K_DISTINCTROW
	|K_DISTRIBUTED
	|K_DIV
	|K_DOUBLE
	|K_DROP
	|K_DUAL

	|K_EACH
	|K_ELSE
	|K_ELSEIF
	|K_ENCLOSED
//	|K_ENTRY
	|K_ESCAPED
//	|K_EXCHANGE
	|K_EXISTS
	|K_EXIT
	|K_EXT_BAD_FILE
//	|K_EXT_DATA_FILE
//	|K_EXT_ESCAPE_CHARACTER
//	|K_EXT_FLD_DELIM
//	|K_EXT_LOG_FILE
//	|K_EXT_STRING_QUALIFIER
//	|K_EXT_TAB_OPT
//	|K_EXT_TRIM_RIGHT_SPACE

	|K_FALSE
	|K_FETCH
//	|K_FIRST_ROWS
	|K_FLOAT
	|K_FLOAT4
	|K_FLOAT8
//	|K_FOLLOWING
	|K_FOR
	|K_FORCE
	|K_FOREIGN
	|K_FROM
	|K_FULL
	|K_FULLTEXT

//	|K_GBASE_ERRNO
	|K_GCLOCAL
	|K_GCLUSTER
	|K_GCLUSTER_LOCAL
//	|K_GCR
	|K_GET
	|K_GRANT
	|K_GROUP
	|K_GROUPED
//	|K_GROUPING

	|K_HAVING
	|K_HIGH_PRIORITY
	|K_HOUR_MICROSECOND
	|K_HOUR_MINUTE
	|K_HOUR_SECOND

	|K_IF
	|K_IGNORE
	|K_IN
	|K_INDEX
//	|K_INDEX_DATA_PATH
	|K_INFILE
	|K_INITNODEDATAMAP
	|K_INNER
	|K_INOUT
	|K_INSENSITIVE
	|K_INSERT
	|K_INT
	|K_INT1
	|K_INT2
	|K_INT3
	|K_INT4
	|K_INT8
	|K_INTEGER
	|K_INTERSECT
	|K_INTERVAL
	|K_INTO
	|K_IS
	|K_ITERATE

	|K_JOIN

//	|K_KEEPS
	|K_KEY
	|K_KEYS
	|K_KILL

	|K_LEADING
	|K_LEAVE
	|K_LEFT
	|K_LIKE
	|K_LIMIT
	|K_LIMIT_STORAGE_SIZE
	|K_LINEAR
	|K_LINES
	|K_LINK
	|K_LOAD
	|K_LOCALTIME
	|K_LOCALTIMESTAMP
	|K_LOCK
	|K_LONG
	|K_LONGBLOB
	|K_LONGTEXT
	|K_LOOP
	|K_LOW_PRIORITY

	|K_MASTER_SSL_VERIFY_SERVER_CERT
	|K_MATCH
	|K_MEDIUMBLOB
	|K_MEDIUMINT
	|K_MEDIUMTEXT
	|K_MIDDLEINT
	|K_MINUS
	|K_MINUTE_MICROSECOND
	|K_MINUTE_SECOND
	|K_MOD
	|K_MODIFIES
//	|K_MOVE

	|K_NATURAL
//	|K_NOCACHE
	|K_NOCOPIES
//	|K_NODE
//	|K_NOLOCK
	|K_NOT
	|K_NO_WRITE_TO_BINLOG
	|K_NULL
	|K_NUMERIC

	|K_ON
	|K_OPTIMIZE
	|K_OPTION
	|K_OPTIONALLY
	|K_OR
	|K_ORDER
	|K_ORDERED
	|K_OUT
	|K_OUTER
	|K_OUTFILE
	|K_OVER

//	|K_PARALLEL
//	|K_PRECEDING
	|K_PRECISION
	|K_PRIMARY
	|K_PROCEDURE
//	|K_PUBLIC
	|K_PURGE

	|K_RANGE
//	|K_RCMAN
	|K_READ
	|K_READS
	|K_READ_WRITE
	|K_REAL
	|K_REFERENCES
	|K_REFRESH
	|K_REFRESHNODEDATAMAP
	|K_REGEXP
	|K_RELEASE
//	|K_REMOTE
	|K_RENAME
	|K_REPEAT
	|K_REPLACE
//	|K_REPLICATED
	|K_REQUIRE
	|K_RESTRICT
	|K_RETURN
	|K_REVOKE
	|K_RIGHT
	|K_RLIKE

//	|K_SAFEGROUPS
	|K_SCHEMA
	|K_SCHEMAS
	|K_SCN_NUMBER
	|K_SECOND_MICROSECOND
	|K_SELECT
	|K_SELF
	|K_SENSITIVE
	|K_SEPARATOR
	|K_SET
//	|K_SETS
	|K_SHOW
//	|K_SHRINK
	|K_SMALLINT
//	|K_SPACE
	|K_SPATIAL
	|K_SPECIFIC
	|K_SQL
	|K_SQLEXCEPTION
	|K_SQLSTATE
	|K_SQLWARNING
	|K_SQL_BIG_RESULT
	|K_SQL_CALC_FOUND_ROWS
	|K_SQL_SMALL_RESULT
	|K_SSL
	|K_STARTING
	|K_STRAIGHT_JOIN
//	|K_SYSTEM

	|K_TABLE
//	|K_TABLEID
//	|K_TABLE_FIELDS
	|K_TARGET
	|K_TERMINATED
	|K_THEN
//	|K_TID
	|K_TINYBLOB
	|K_TINYINT
	|K_TINYTEXT
	|K_TO
//	|K_TO_DATE
	|K_TRAILING
//	|K_TRANSACTION_LOG
	|K_TRIGGER
	|K_TRUE

//	|K_UNBOUNDED
	|K_UNDO
	|K_UNION
	|K_UNIQUE
	|K_UNLOCK
	|K_UNSIGNED
	|K_UPDATE
//	|K_URI
	|K_USAGE
	|K_USE
	|K_USER
//	|K_USE_HASH
	|K_USING
	|K_UTC_DATE
	|K_UTC_DATETIME
	|K_UTC_TIME
	|K_UTC_TIMESTAMP

//	|K_VALIDATION
	|K_VALUES
	|K_VARBINARY
	|K_VARCHAR
	|K_VARCHARACTER
	|K_VARYING

	|K_WHEN
	|K_WHERE
	|K_WHILE
	|K_WITH
//	|K_WITHOUT
	|K_WRITE

	|K_XOR

	|K_YEAR_MONTH

	|K_ZEROFILL
		;

dcl_stmts:
	dcl_stmt_describe
	|dcl_stmt_use
	|dcl_stmt_kill
	|dcl_stmt_set
	|dcl_stmt_create_user
	|dcl_stmt_drop_user
	|dcl_stmt_rename_user
	|dcl_stmt_set_password
	|dcl_stmt_grant
	|dcl_stmt_revoke
	|dcl_stmt_revoke_all
	|dcl_stmt_show
;

dcl_stmt_describe:
	(K_DESCRIBE | K_DESC)  table_definition column_name?
;

dcl_stmt_use:
	K_USE database_name
;

dcl_stmt_kill:
	K_KILL (K_CONNECTION | K_QUERY)? thread_id
;

thread_id:
	literal_value
;

dcl_stmt_set:
	K_SET (K_GLOBAL | K_SESSION)? variablename ASSIGN set_value
;

variablename:
	any_name
;

set_value:
	expression
;

dcl_stmt_create_user:
	K_CREATE K_USER user_name (K_IDENTIFIED K_BY (K_PASSWORD)? password_value)?
;

user_name:
	any_name ('@' any_name)?
;

password_value:
	any_name
;

dcl_stmt_drop_user:
	K_DROP K_USER user_name
;


dcl_stmt_rename_user:
	K_RENAME K_USER old_user_name K_TO new_user_name
;

old_user_name:
	any_name
;

new_user_name:
	any_name
;

dcl_stmt_set_password:
	K_SET K_PASSWORD (K_FOR user_name)? ASSIGN K_PASSWORD OPEN_PAR new_password CLOSE_PAR
;

new_password:
	any_name
;

dcl_stmt_grant:
	K_GRANT priv_type_block(COMMA+priv_type_block)*
	K_ON  object_type? priv_level
	K_TO user_name  indentified_by_password
	(K_WITH with_option)?
;

indentified_by_password:
	(K_IDENTIFIED K_BY (K_PASSWORD)? password_value)?
;

priv_type_block:
	priv_type columns_list?
;

priv_type:
	K_ALL (K_PRIVILEGES)?
	|K_ALTER
	|K_ALTER K_ROUTINE
	|K_CREATE
	|K_CREATE K_ROUTINE
	|K_CREATE K_TEMPORARY
	|K_TABLES
	|K_CREATE K_USER
	|K_CREATE K_VIEW
	|K_DELETE
	|K_DROP
	|K_EXECUTE
	|K_FILE
	|K_GRANT K_OPTION
	|K_INDEX
	|K_INSERT
	|K_PROCESS
	|K_RELOAD
	|K_SELECT
	|K_SHOW K_DATABASES
	|K_SHOW K_VIEW
	|K_SHUTDOWN
	|K_SUPPER
	|K_UPDATE
	|K_USAGE
;

object_type:
	 K_TABLE
	 |K_FUNCTION
	 |K_PROCEDURE
;

priv_level:
	STAR 					//*
	| STAR DOT STAR			//*.*
	|database_name DOT STAR //database_name.*
	|table_definition
  	|table_name
  	|routine_definition
;

routine_definition:
	(database_name DOT)? routine_name
;

routine_name:
	any_name
;

with_option:
	K_TASK_PRIORITY priority_value
	| K_GRANT K_OPTION
;

priority_value:
	literal_value
;

dcl_stmt_revoke:
	K_REVOKE priv_type_block(COMMA+priv_type_block)*
	K_ON  object_type? priv_level
	K_FROM user_name
;

dcl_stmt_revoke_all:
	K_REVOKE K_ALL K_PRIVILEGES COMMA K_GRANT K_OPTION
	K_FROM user_name
;

dcl_stmt_show:
	dcl_stmt_show_columns
	|dcl_stmt_show_create_database
	|dcl_stmt_show_create_table
	|dcl_stmt_show_create_view
	|dcl_stmt_show_database
	|dcl_stmt_show_errors
	|dcl_stmt_show_count_errors
	|dcl_stmt_show_grants
	|dcl_stmt_show_index
	|dcl_stmt_show_processlist
	|dcl_stmt_show_status
	|dcl_stmt_show_tables
	|dcl_stmt_show_table_status
	|dcl_stmt_show_variables
	|dcl_stmt_show_warnings
	|dcl_stmt_show_count_warnings
	|dcl_stmt_show_priorities
	|dcl_stmt_show_cluster_entry
;

dcl_stmt_show_columns:
	K_SHOW (K_FULL)? K_COLUMNS K_FROM (table_definition | (table_name K_FROM database_name)) (K_LIKE columns_pattern)?
;

columns_pattern:
	any_name
;

dcl_stmt_show_create_database:
	K_SHOW K_CREATE (K_DATABASE | K_SCHEMA) database_name
;

dcl_stmt_show_create_function:
	K_SHOW K_CREATE K_FUNCTION  (database_name DOT)? function_name
;

dcl_stmt_show_create_procedure:
	K_SHOW K_CREATE K_PROCEDURE (database_name DOT)? procedure_name
;

procedure_name:
	any_name
;

dcl_stmt_show_create_table:
	K_SHOW K_CREATE K_TABLE table_definition
;

dcl_stmt_show_create_view:
	K_SHOW K_CREATE K_VIEW (database_name DOT)? view_name
;

dcl_stmt_show_database:
	K_SHOW (K_DATABASE | K_SCHEMA) (K_LIKE pattern)?
;

pattern:
	any_name
;

dcl_stmt_show_errors:
	K_SHOW K_ERRORS select_limit?
;

dcl_stmt_show_count_errors:
//	K_SHOW (K_COUNT OPEN_PAR STAR CLOSE_PAR) K_ERRORS
K_SHOW (any_name OPEN_PAR STAR CLOSE_PAR) K_ERRORS
;

dcl_stmt_show_function_status:
	K_SHOW K_FUNCTION K_STATUS
;

dcl_stmt_show_grants:
	K_SHOW K_GRANTS (K_FOR (user_name AT any_name  | K_CURRENT_USER | (K_CURRENT_USER OPEN_PAR  CLOSE_PAR) ) )?
;

dcl_stmt_show_index:
	K_SHOW K_INDEX K_FROM (table_definition | (table_name K_FROM database_name))
;

dcl_stmt_show_procedure_status:
	K_SHOW K_PROCEDURE K_STATUS
;

dcl_stmt_show_processlist:
	K_SHOW K_FULL? K_PROCESSLIST
;

dcl_stmt_show_status:
	K_SHOW (K_GLOBAL | K_SESSION)? K_STATUS (K_LIKE pattern)?
;

dcl_stmt_show_tables:
	K_SHOW (K_FULL | K_DISTRIBUTION)? K_TABLES (K_FROM database_name)? (K_LIKE pattern)?
;

dcl_stmt_show_table_status:
	K_SHOW K_TABLE K_STATUS (K_FROM database_name)? (K_WHERE any_name ASSIGN table_name)?
;

dcl_stmt_show_variables:
	K_SHOW (K_GLOBAL | K_SESSION)? K_VARIABLES (K_LIKE pattern)?
;

dcl_stmt_show_warnings:
	K_SHOW K_WARNINGS select_limit?
;

dcl_stmt_show_count_warnings:
//	K_SHOW (K_COUNT OPEN_PAR STAR CLOSE_PAR) K_WARNINGS
K_SHOW (any_name OPEN_PAR STAR CLOSE_PAR) K_WARNINGS
;

dcl_stmt_show_priorities:
	K_SHOW K_PRIORITIES select_where?
;

dcl_stmt_show_cluster_entry:
	K_SHOW K_GCLUSTER K_ENTRY
;

/*
 * token define
 */
