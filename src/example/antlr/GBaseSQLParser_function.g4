parser grammar GBaseSQLParser_function;

import GBaseSQLParser_base1,
    GBaseSQLParser_base
;


options {
    tokenVocab=GBaseSQLLexer;
}


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