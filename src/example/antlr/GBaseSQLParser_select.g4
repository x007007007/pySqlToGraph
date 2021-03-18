parser grammar GBaseSQLParser_select;

import GBaseSQLParser_base1,
    GBaseSQLParser_base
;


options {
    tokenVocab=GBaseSQLLexer;
}

match_against_statement:
	K_MATCH (column_name (COMMA column_name)* ) K_AGAINST (expression (search_modifier)? )
;

dql_stmt_select:
//  select_or_values ( compound_operator select_or_values )*
//   ( K_ORDER K_BY ordering_term ( ',' ordering_term )* )?
//   ( K_LIMIT expression ( ( K_OFFSET | ',' ) expression )? )?
//   ( K_INTO K_OUTFILE outfile_name export_options?)?
	(
	    select_or_values
	  //  | dql_stmt_union
	)
	select_into_outfile?
 ;

routine_body:
	(
//	    routine_begin_end				//2
	    routine_select_into				//3
//        |declare									//4
//        |routine_set							//5
//        |routine_case_when			//6
//        |routine_if								//7
//        |routine_iterate						//8
//        |routine_leave						//9
//        |routine_loop							//10
//        |routine_repeat						//11
//        |routine_while						//12
//        |routine_return						//13
//        |routine_open_cursor			//14
//        |routine_close_cursor			//15
//        |routine_fetch_into				//16
//        |routine_prepare					//17
//        |routine_execute					//18
//        |routine_drop_prepare		//19
//        |call_procedure						//20
//        |sqls											//1
//        |alter_sp									//21
//        |drop_sp									//22
//        |show_sp_status					//23
//        |show_create_sp					//24

	) SCOL?
;

select_or_values:
    select select_column select_from? select_where? hierarchical_clause? select_groupby? select_orderby? select_limit?
 //| K_VALUES '(' expression ( ',' expression )* ')' ( ',' '(' expression ( ',' expression )* ')' )*
;

//dql_stmt_union:
//    union_item (union_operator_item)* select_orderby? select_limit?
//;

select_into_outfile:
	 K_INTO K_OUTFILE outfile_name export_options*
;

routine_select_into:
    select select_column K_INTO var_name_list select_from? select_where? select_groupby? select_orderby? select_limit?
;

select:
    K_SELECT ( K_DISTINCT | K_ALL |K_DISTINCTROW)?
;

select_column:
	result_column ( ',' result_column )*
;

select_from:
	K_FROM ( (table_or_subquery ( COMMA table_or_subquery )*) | join_clause )
;

table_or_subquery:
    table_or_subquery_tablename//( K_INDEXED K_BY index_name | K_NOT K_INDEXED )?
    | table_or_subquery_subquery
    | table_or_subquery_select
 ;

table_or_subquery_tablename: ( database_name DOT )? table_name ( K_AS? table_alias )? ;
table_or_subquery_subquery:
 	OPEN_PAR ( (table_or_subquery ( COMMA table_or_subquery )*) | join_clause ) CLOSE_PAR ( K_AS? table_alias )?
;
table_or_subquery_select:
    OPEN_PAR dql_stmt_select CLOSE_PAR ( K_AS? table_alias )?
;
select_where:
	K_WHERE expression
;

result_column:
    STAR
    | table_definition DOT STAR
    | result_expr
;

result_expr:
    expression ( K_AS? column_alias )?
    | expression regexp_rlike expression
;

var_name_list:
	column_alias(COMMA+column_alias)*
;

join_clause:
    table_or_subquery ( join_reference_and_conditon )*
;

join_reference_and_conditon:
    join_operator table_or_subquery join_condition?
;

join_condition:
    join_condition_on   |  join_condition_using
;
join_condition_on:
    K_ON expression
;
join_condition_using:
    K_USING OPEN_PAR column_name ( COMMA column_name )* CLOSE_PAR
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

ordering_term:
    expression ( K_ASC | K_DESC )?
 // : expression ( K_COLLATE collation_name )? ( K_ASC | K_DESC )?
;

select_limit_offset:
	 ( K_OFFSET |COMMA) expression
;

hierarchical_clause:
	(K_START K_WITH expression)? K_CONNECT K_BY connect_conditions
	|K_CONNECT K_BY connect_conditions (K_START K_WITH expression)?
	select_orderby?
;

connect_conditions:
    K_PRIOR expression  relational_op expression
    | expression relational_op K_PRIOR expression
    | expression relational_op connect_conditions
    | expression
;
