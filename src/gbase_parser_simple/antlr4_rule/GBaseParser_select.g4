parser grammar GBaseParser_select;

options {
//    superClass = MySQLBaseRecognizer;
    tokenVocab = GBaseLexer;
    exportMacro = PARSERS_PUBLIC_TYPE;
}


//----------------------------------------------------------------------------------------------------------------------

selectStatement:
    queryExpression lockingClauseList?
    | queryExpressionParens
    | selectStatementWithInto
;

/*
  From the server grammar:

  MySQL has a syntax extension that allows into clauses in any one of two
  places. They may appear either before the from clause or at the end. All in
  a top-level select statement. This extends the standard syntax in two
  ways. First, we don't have the restriction that the result can contain only
  one row: the into clause might be INTO OUTFILE/DUMPFILE in which case any
  number of rows is allowed. Hence MySQL does not have any special case for
  the standard's <select statement: single row>. Secondly, and this has more
  severe implications for the parser, it makes the grammar ambiguous, because
  in a from-clause-less select statement with an into clause, it is not clear
  whether the into clause is the leading or the trailing one.

  While it's possible to write an unambiguous grammar, it would force us to
  duplicate the entire <select statement> syntax all the way down to the <into
  clause>. So instead we solve it by writing an ambiguous grammar and use
  precedence rules to sort out the shift/reduce conflict.

  The problem is when the parser has seen SELECT <select list>, and sees an
  INTO token. It can now either shift it or reduce what it has to a table-less
  query expression. If it shifts the token, it will accept seeing a FROM token
  next and hence the INTO will be interpreted as the leading INTO. If it
  reduces what it has seen to a table-less select, however, it will interpret
  INTO as the trailing into. But what if the next token is FROM? Obviously,
  we want to always shift INTO. We do this by two precedence declarations: We
  make the INTO token right-associative, and we give it higher precedence than
  an empty from clause, using the artificial token EMPTY_FROM_CLAUSE.

  The remaining problem is that now we allow the leading INTO anywhere, when
  it should be allowed on the top level only. We solve this by manually
  throwing parse errors whenever we reduce a nested query expression if it
  contains an into clause.
*/
selectStatementWithInto:
    OPEN_PAR_SYMBOL selectStatementWithInto CLOSE_PAR_SYMBOL
    | queryExpression intoClause lockingClauseList?
    | lockingClauseList intoClause
;

queryExpression:
    ({status.serverVersion >= 80000}? withClause)? (
        queryExpressionBody orderClause? limitClause?
        | queryExpressionParens orderClause? limitClause?
    ) ({status.serverVersion < 80000}? procedureAnalyseClause)?
;

queryExpressionBody:
    (
        queryPrimary
        | queryExpressionParens UNION_SYMBOL unionOption? (
            queryPrimary
            | queryExpressionParens
        )
    ) (UNION_SYMBOL unionOption? ( queryPrimary | queryExpressionParens))*
;

queryExpressionParens:
    OPEN_PAR_SYMBOL (
        queryExpressionParens
        | queryExpression lockingClauseList?
    ) CLOSE_PAR_SYMBOL
;

queryPrimary:
    querySpecification
    | {status.serverVersion >= 80019}? tableValueConstructor
    | {status.serverVersion >= 80019}? explicitTable
;

querySpecification:
    SELECT_SYMBOL selectOption* selectItemList intoClause? fromClause? whereClause? groupByClause? havingClause? (
        {status.serverVersion >= 80000}? windowClause
    )?
;

subquery:
    queryExpressionParens
;

querySpecOption:
    ALL_SYMBOL
    | DISTINCT_SYMBOL
    | STRAIGHT_JOIN_SYMBOL
    | HIGH_PRIORITY_SYMBOL
    | SQL_SMALL_RESULT_SYMBOL
    | SQL_BIG_RESULT_SYMBOL
    | SQL_BUFFER_RESULT_SYMBOL
    | SQL_CALC_FOUND_ROWS_SYMBOL
;

limitClause:
    LIMIT_SYMBOL limitOptions
;

simpleLimitClause:
    LIMIT_SYMBOL limitOption
;

limitOptions:
    limitOption ((COMMA_SYMBOL | OFFSET_SYMBOL) limitOption)?
;

limitOption:
    identifier
    | (PARAM_MARKER | ULONGLONG_NUMBER | LONG_NUMBER | INT_NUMBER)
;

intoClause:
    INTO_SYMBOL (
        OUTFILE_SYMBOL textStringLiteral charsetClause? fieldsClause? linesClause?
        | DUMPFILE_SYMBOL textStringLiteral
        | (textOrIdentifier | userVariable) (
            COMMA_SYMBOL (textOrIdentifier | userVariable)
        )*
    )
;

procedureAnalyseClause:
    PROCEDURE_SYMBOL ANALYSE_SYMBOL OPEN_PAR_SYMBOL (
        INT_NUMBER (COMMA_SYMBOL INT_NUMBER)?
    )? CLOSE_PAR_SYMBOL
;

havingClause:
    HAVING_SYMBOL expr
;

windowClause:
    WINDOW_SYMBOL windowDefinition (COMMA_SYMBOL windowDefinition)*
;

windowDefinition:
    windowName AS_SYMBOL windowSpec
;

windowSpec:
    OPEN_PAR_SYMBOL windowSpecDetails CLOSE_PAR_SYMBOL
;

windowSpecDetails:
    windowName? (PARTITION_SYMBOL BY_SYMBOL orderList)? orderClause? windowFrameClause?
;

windowFrameClause:
    windowFrameUnits windowFrameExtent windowFrameExclusion?
;

windowFrameUnits:
    ROWS_SYMBOL
    | RANGE_SYMBOL
    | GROUPS_SYMBOL
;

windowFrameExtent:
    windowFrameStart
    | windowFrameBetween
;

windowFrameStart:
    UNBOUNDED_SYMBOL PRECEDING_SYMBOL
    | ulonglong_number PRECEDING_SYMBOL
    | PARAM_MARKER PRECEDING_SYMBOL
    | INTERVAL_SYMBOL expr interval PRECEDING_SYMBOL
    | CURRENT_SYMBOL ROW_SYMBOL
;

windowFrameBetween:
    BETWEEN_SYMBOL windowFrameBound AND_SYMBOL windowFrameBound
;

windowFrameBound:
    windowFrameStart
    | UNBOUNDED_SYMBOL FOLLOWING_SYMBOL
    | ulonglong_number FOLLOWING_SYMBOL
    | PARAM_MARKER FOLLOWING_SYMBOL
    | INTERVAL_SYMBOL expr interval FOLLOWING_SYMBOL
;

windowFrameExclusion:
    EXCLUDE_SYMBOL (
        CURRENT_SYMBOL ROW_SYMBOL
        | GROUP_SYMBOL
        | TIES_SYMBOL
        | NO_SYMBOL OTHERS_SYMBOL
    )
;

withClause:
    WITH_SYMBOL RECURSIVE_SYMBOL? commonTableExpression (
        COMMA_SYMBOL commonTableExpression
    )*
;

commonTableExpression:
    identifier columnInternalRefList? AS_SYMBOL subquery
;

groupByClause:
    GROUP_SYMBOL BY_SYMBOL orderList olapOption?
;

olapOption:
    WITH_SYMBOL ROLLUP_SYMBOL
    | {status.serverVersion < 80000}? WITH_SYMBOL CUBE_SYMBOL
;

orderClause:
    ORDER_SYMBOL BY_SYMBOL orderList
;

direction:
    ASC_SYMBOL
    | DESC_SYMBOL
;

fromClause:
    FROM_SYMBOL (DUAL_SYMBOL | tableReferenceList)
;

tableReferenceList:
    tableReference (COMMA_SYMBOL tableReference)*
;

tableValueConstructor:
    VALUES_SYMBOL rowValueExplicit (COMMA_SYMBOL rowValueExplicit)*
;

explicitTable:
    TABLE_SYMBOL tableRef
;

rowValueExplicit:
    ROW_SYMBOL OPEN_PAR_SYMBOL values? CLOSE_PAR_SYMBOL
;

selectOption:
    querySpecOption
    | SQL_NO_CACHE_SYMBOL // Deprecated and ignored in 8.0.
    | {status.serverVersion < 80000}? SQL_CACHE_SYMBOL
    | {status.serverVersion >= 50704 and status.serverVersion < 50708}? MAX_STATEMENT_TIME_SYMBOL EQUAL_OPERATOR real_ulong_number
;

lockingClauseList:
    lockingClause+
;

lockingClause:
    FOR_SYMBOL lockStrengh ({status.serverVersion >= 80000}? OF_SYMBOL tableAliasRefList)? (
        {status.serverVersion >= 80000}? lockedRowAction
    )?
    | LOCK_SYMBOL IN_SYMBOL SHARE_SYMBOL MODE_SYMBOL
;

lockStrengh:
    UPDATE_SYMBOL
    | {status.serverVersion >= 80000}? SHARE_SYMBOL
;

lockedRowAction:
    SKIP_SYMBOL LOCKED_SYMBOL
    | NOWAIT_SYMBOL
;


selectItemList: (selectItem | MULT_OPERATOR) (COMMA_SYMBOL selectItem)*
;

selectItem:
    tableWild
    | expr selectAlias?
;

selectAlias:
    AS_SYMBOL? (identifier | textStringLiteral)
;

whereClause:
    WHERE_SYMBOL expr
;

tableReference: ( // Note: we have also a tableRef rule for identifiers that reference a table anywhere.
        tableFactor
        | OPEN_CURLY_SYMBOL ({status.serverVersion < 80017}? identifier | OJ_SYMBOL) escapedTableReference CLOSE_CURLY_SYMBOL // ODBC syntax
    ) joinedTable*
;

escapedTableReference:
    tableFactor joinedTable*
;

joinedTable: // Same as joined_table in sql_yacc.yy, but with removed left recursion.
    innerJoinType tableReference (
        ON_SYMBOL expr
        | USING_SYMBOL identifierListWithParentheses
    )?
    | outerJoinType tableReference (
        ON_SYMBOL expr
        | USING_SYMBOL identifierListWithParentheses
    )
    | naturalJoinType tableFactor
;

naturalJoinType:
    NATURAL_SYMBOL INNER_SYMBOL? JOIN_SYMBOL
    | NATURAL_SYMBOL (LEFT_SYMBOL | RIGHT_SYMBOL) OUTER_SYMBOL? JOIN_SYMBOL
;

innerJoinType:
    the_type = (INNER_SYMBOL | CROSS_SYMBOL)? JOIN_SYMBOL
    | the_type = STRAIGHT_JOIN_SYMBOL
;

outerJoinType:
    the_type = (LEFT_SYMBOL | RIGHT_SYMBOL) OUTER_SYMBOL? JOIN_SYMBOL
;

/**
  MySQL has a syntax extension where a comma-separated list of table
  references is allowed as a table reference in itself, for instance

    SELECT * FROM (t1, t2) JOIN t3 ON 1

  which is not allowed in standard SQL. The syntax is equivalent to

    SELECT * FROM (t1 CROSS JOIN t2) JOIN t3 ON 1

  We call this rule tableReferenceListParens.
*/
tableFactor:
    singleTable
    | singleTableParens
    | derivedTable
    | tableReferenceListParens
    | tableFunction  //{status.serverVersion >= 80004}?
;

singleTable:
    tableRef usePartition? tableAlias? indexHintList?
;

singleTableParens:
    OPEN_PAR_SYMBOL (singleTable | singleTableParens) CLOSE_PAR_SYMBOL
;

derivedTable:
    subquery tableAlias? ({status.serverVersion >= 80000}? columnInternalRefList)?
    | {status.serverVersion >= 80014}? LATERAL_SYMBOL subquery tableAlias? columnInternalRefList?
;

// This rule covers both: joined_table_parens and table_reference_list_parens from sql_yacc.yy.
// We can simplify that because we have unrolled the indirect left recursion in joined_table <-> table_reference.
tableReferenceListParens:
    OPEN_PAR_SYMBOL (tableReferenceList | tableReferenceListParens) CLOSE_PAR_SYMBOL
;

tableFunction:
    JSON_TABLE_SYMBOL OPEN_PAR_SYMBOL expr COMMA_SYMBOL textStringLiteral columnsClause CLOSE_PAR_SYMBOL tableAlias?
;

columnsClause:
    COLUMNS_SYMBOL OPEN_PAR_SYMBOL jtColumn (COMMA_SYMBOL jtColumn)* CLOSE_PAR_SYMBOL
;

jtColumn:
    identifier FOR_SYMBOL ORDINALITY_SYMBOL
    | identifier dataType ({status.serverVersion >= 80014}? collate)? EXISTS_SYMBOL? PATH_SYMBOL textStringLiteral onEmptyOrError?
    | NESTED_SYMBOL PATH_SYMBOL textStringLiteral columnsClause
;

onEmptyOrError:
    onEmpty onError?
    | onError onEmpty?
;

onEmpty:
    jtOnResponse ON_SYMBOL EMPTY_SYMBOL
;

onError:
    jtOnResponse ON_SYMBOL ERROR_SYMBOL
;

jtOnResponse:
    ERROR_SYMBOL
    | NULL_SYMBOL
    | DEFAULT_SYMBOL textStringLiteral
;

unionOption:
    DISTINCT_SYMBOL
    | ALL_SYMBOL
;

tableAlias:
    (AS_SYMBOL
   // | {status.serverVersion < 80017}? EQUAL_OPERATOR
    )? identifier
;

indexHintList:
    indexHint (COMMA_SYMBOL indexHint)*
;

indexHint:
    indexHintType keyOrIndex indexHintClause? OPEN_PAR_SYMBOL indexList CLOSE_PAR_SYMBOL
    | USE_SYMBOL keyOrIndex indexHintClause? OPEN_PAR_SYMBOL indexList? CLOSE_PAR_SYMBOL
;

indexHintType:
    FORCE_SYMBOL
    | IGNORE_SYMBOL
;

keyOrIndex:
    KEY_SYMBOL
    | INDEX_SYMBOL
;

constraintKeyType:
    PRIMARY_SYMBOL KEY_SYMBOL
    | UNIQUE_SYMBOL keyOrIndex?
;

indexHintClause:
    FOR_SYMBOL (JOIN_SYMBOL | ORDER_SYMBOL BY_SYMBOL | GROUP_SYMBOL BY_SYMBOL)
;

indexList:
    indexListElement (COMMA_SYMBOL indexListElement)*
;

indexListElement:
    identifier
    | PRIMARY_SYMBOL
;

//----------------------------------------------------------------------------------------------------------------------