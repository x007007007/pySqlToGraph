parser grammar GBaseParser_expr;

options {
//    superClass = MySQLBaseRecognizer;
    tokenVocab = GBaseLexer;
    exportMacro = PARSERS_PUBLIC_TYPE;
}

//----------------- Expression support ---------------------------------------------------------------------------------

expr:
    boolPri (IS_SYMBOL notRule? the_type = (TRUE_SYMBOL | FALSE_SYMBOL | UNKNOWN_SYMBOL))? # exprIs
    | NOT_SYMBOL expr                                                                  # exprNot
    | expr op = (AND_SYMBOL | LOGICAL_AND_OPERATOR) expr                               # exprAnd
    | expr XOR_SYMBOL expr                                                             # exprXor
    | expr op = (OR_SYMBOL | LOGICAL_OR_OPERATOR) expr                                 # exprOr
;

boolPri:
    predicate                                           # primaryExprPredicate
    | boolPri IS_SYMBOL notRule? NULL_SYMBOL            # primaryExprIsNull
    | boolPri compOp predicate                          # primaryExprCompare
    | boolPri compOp (ALL_SYMBOL | ANY_SYMBOL) subquery # primaryExprAllAny
;

compOp:
    EQUAL_OPERATOR
    | NULL_SAFE_EQUAL_OPERATOR
    | GREATER_OR_EQUAL_OPERATOR
    | GREATER_THAN_OPERATOR
    | LESS_OR_EQUAL_OPERATOR
    | LESS_THAN_OPERATOR
    | NOT_EQUAL_OPERATOR
;

predicate:
    bitExpr (
        notRule? predicateOperations
        | {status.serverVersion >= 80017}? MEMBER_SYMBOL OF_SYMBOL? simpleExprWithParentheses
        | SOUNDS_SYMBOL LIKE_SYMBOL bitExpr
    )?
;

predicateOperations:
    IN_SYMBOL (subquery | OPEN_PAR_SYMBOL exprList CLOSE_PAR_SYMBOL) # predicateExprIn
    | BETWEEN_SYMBOL bitExpr AND_SYMBOL predicate                    # predicateExprBetween
    | LIKE_SYMBOL simpleExpr (ESCAPE_SYMBOL simpleExpr)?             # predicateExprLike
    | REGEXP_SYMBOL bitExpr                                          # predicateExprRegex
;

bitExpr:
    simpleExpr
    | bitExpr op = BITWISE_XOR_OPERATOR bitExpr
    | bitExpr op = (
        MULT_OPERATOR
        | DIV_OPERATOR
        | MOD_OPERATOR
        | DIV_SYMBOL
        | MOD_SYMBOL
    ) bitExpr
    | bitExpr op = (PLUS_OPERATOR | MINUS_OPERATOR) bitExpr
    | bitExpr op = (PLUS_OPERATOR | MINUS_OPERATOR) INTERVAL_SYMBOL expr interval
    | bitExpr op = (SHIFT_LEFT_OPERATOR | SHIFT_RIGHT_OPERATOR) bitExpr
    | bitExpr op = BITWISE_AND_OPERATOR bitExpr
    | bitExpr op = BITWISE_OR_OPERATOR bitExpr
;

simpleExpr:
    variable (equal expr)?                                                                               # simpleExprVariable
    | columnRef jsonOperator?                                                                            # simpleExprColumnRef
    | runtimeFunctionCall                                                                                # simpleExprRuntimeFunction
    | functionCall                                                                                       # simpleExprFunction
    | simpleExpr COLLATE_SYMBOL textOrIdentifier                                                         # simpleExprCollate
    | literal                                                                                            # simpleExprLiteral
    | PARAM_MARKER                                                                                       # simpleExprParamMarker
    | sumExpr                                                                                            # simpleExprSum
    | {status.serverVersion >= 80000}? groupingOperation                                                        # simpleExprGroupingOperation
    | {status.serverVersion >= 80000}? windowFunctionCall                                                       # simpleExprWindowingFunction
    | simpleExpr CONCAT_PIPES_SYMBOL simpleExpr                                                          # simpleExprConcat
    | op = (PLUS_OPERATOR | MINUS_OPERATOR | BITWISE_NOT_OPERATOR) simpleExpr                            # simpleExprUnary
    | not2Rule simpleExpr                                                                                # simpleExprNot
    | ROW_SYMBOL? OPEN_PAR_SYMBOL exprList CLOSE_PAR_SYMBOL                                              # simpleExprList
    | EXISTS_SYMBOL? subquery                                                                            # simpleExprSubQuery
    | OPEN_CURLY_SYMBOL identifier expr CLOSE_CURLY_SYMBOL                                               # simpleExprOdbc
    | MATCH_SYMBOL identListArg AGAINST_SYMBOL OPEN_PAR_SYMBOL bitExpr fulltextOptions? CLOSE_PAR_SYMBOL # simpleExprMatch
    | BINARY_SYMBOL simpleExpr                                                                           # simpleExprBinary
    | CAST_SYMBOL OPEN_PAR_SYMBOL expr AS_SYMBOL castType arrayCast? CLOSE_PAR_SYMBOL                    # simpleExprCast
    | CASE_SYMBOL expr? (whenExpression thenExpression)+ elseExpression? END_SYMBOL                      # simpleExprCase
    | CONVERT_SYMBOL OPEN_PAR_SYMBOL expr COMMA_SYMBOL castType CLOSE_PAR_SYMBOL                         # simpleExprConvert
    | CONVERT_SYMBOL OPEN_PAR_SYMBOL expr USING_SYMBOL charsetName CLOSE_PAR_SYMBOL                      # simpleExprConvertUsing
    | DEFAULT_SYMBOL OPEN_PAR_SYMBOL simpleIdentifier CLOSE_PAR_SYMBOL                                   # simpleExprDefault
    | VALUES_SYMBOL OPEN_PAR_SYMBOL simpleIdentifier CLOSE_PAR_SYMBOL                                    # simpleExprValues
    | INTERVAL_SYMBOL expr interval PLUS_OPERATOR expr                                                   # simpleExprInterval
;

arrayCast:
    {status.serverVersion >= 80017}? ARRAY_SYMBOL
;

jsonOperator:
    {status.serverVersion >= 50708}? JSON_SEPARATOR_SYMBOL textStringLiteral
    | {status.serverVersion >= 50713}? JSON_UNQUOTED_SEPARATOR_SYMBOL textStringLiteral
;

sumExpr:
    name = AVG_SYMBOL OPEN_PAR_SYMBOL DISTINCT_SYMBOL? inSumExpr CLOSE_PAR_SYMBOL (
        {status.serverVersion >= 80000}? windowingClause
    )?
    | name = (BIT_AND_SYMBOL | BIT_OR_SYMBOL | BIT_XOR_SYMBOL) OPEN_PAR_SYMBOL inSumExpr CLOSE_PAR_SYMBOL (
        {status.serverVersion >= 80000}? windowingClause
    )?
    | {status.serverVersion >= 80000}? jsonFunction
    | name = COUNT_SYMBOL OPEN_PAR_SYMBOL ALL_SYMBOL? MULT_OPERATOR CLOSE_PAR_SYMBOL (
        {status.serverVersion >= 80000}? windowingClause
    )?
    | name = COUNT_SYMBOL OPEN_PAR_SYMBOL (
        ALL_SYMBOL? MULT_OPERATOR
        | inSumExpr
        | DISTINCT_SYMBOL exprList
    ) CLOSE_PAR_SYMBOL ({status.serverVersion >= 80000}? windowingClause)?
    | name = MIN_SYMBOL OPEN_PAR_SYMBOL DISTINCT_SYMBOL? inSumExpr CLOSE_PAR_SYMBOL (
        {status.serverVersion >= 80000}? windowingClause
    )?
    | name = MAX_SYMBOL OPEN_PAR_SYMBOL DISTINCT_SYMBOL? inSumExpr CLOSE_PAR_SYMBOL (
        {status.serverVersion >= 80000}? windowingClause
    )?
    | name = STD_SYMBOL OPEN_PAR_SYMBOL inSumExpr CLOSE_PAR_SYMBOL (
        {status.serverVersion >= 80000}? windowingClause
    )?
    | name = VARIANCE_SYMBOL OPEN_PAR_SYMBOL inSumExpr CLOSE_PAR_SYMBOL (
        {status.serverVersion >= 80000}? windowingClause
    )?
    | name = STDDEV_SAMP_SYMBOL OPEN_PAR_SYMBOL inSumExpr CLOSE_PAR_SYMBOL (
        {status.serverVersion >= 80000}? windowingClause
    )?
    | name = VAR_SAMP_SYMBOL OPEN_PAR_SYMBOL inSumExpr CLOSE_PAR_SYMBOL (
        {status.serverVersion >= 80000}? windowingClause
    )?
    | name = SUM_SYMBOL OPEN_PAR_SYMBOL DISTINCT_SYMBOL? inSumExpr CLOSE_PAR_SYMBOL (
        {status.serverVersion >= 80000}? windowingClause
    )?
    | name = GROUP_CONCAT_SYMBOL OPEN_PAR_SYMBOL DISTINCT_SYMBOL? exprList orderClause? (
        SEPARATOR_SYMBOL textString
    )? CLOSE_PAR_SYMBOL ({status.serverVersion >= 80000}? windowingClause)?
;

groupingOperation:
    GROUPING_SYMBOL OPEN_PAR_SYMBOL exprList CLOSE_PAR_SYMBOL
;

windowFunctionCall:
    (
        ROW_NUMBER_SYMBOL
        | RANK_SYMBOL
        | DENSE_RANK_SYMBOL
        | CUME_DIST_SYMBOL
        | PERCENT_RANK_SYMBOL
    ) parentheses windowingClause
    | NTILE_SYMBOL simpleExprWithParentheses windowingClause
    | (LEAD_SYMBOL | LAG_SYMBOL) OPEN_PAR_SYMBOL expr leadLagInfo? CLOSE_PAR_SYMBOL nullTreatment? windowingClause
    | (FIRST_VALUE_SYMBOL | LAST_VALUE_SYMBOL) exprWithParentheses nullTreatment? windowingClause
    | NTH_VALUE_SYMBOL OPEN_PAR_SYMBOL expr COMMA_SYMBOL simpleExpr CLOSE_PAR_SYMBOL (
        FROM_SYMBOL (FIRST_SYMBOL | LAST_SYMBOL)
    )? nullTreatment? windowingClause
;

windowingClause:
    OVER_SYMBOL (windowName | windowSpec)
;

leadLagInfo:
    COMMA_SYMBOL (ulonglong_number | PARAM_MARKER) (COMMA_SYMBOL expr)?
;

nullTreatment:
    (RESPECT_SYMBOL | IGNORE_SYMBOL) NULLS_SYMBOL
;

jsonFunction:
    JSON_ARRAYAGG_SYMBOL OPEN_PAR_SYMBOL inSumExpr CLOSE_PAR_SYMBOL windowingClause?
    | JSON_OBJECTAGG_SYMBOL OPEN_PAR_SYMBOL inSumExpr COMMA_SYMBOL inSumExpr CLOSE_PAR_SYMBOL windowingClause?
;

inSumExpr:
    ALL_SYMBOL? expr
;

identListArg:
    identList
    | OPEN_PAR_SYMBOL identList CLOSE_PAR_SYMBOL
;

identList:
    simpleIdentifier (COMMA_SYMBOL simpleIdentifier)*
;

fulltextOptions:
    IN_SYMBOL BOOLEAN_SYMBOL MODE_SYMBOL
    | IN_SYMBOL NATURAL_SYMBOL LANGUAGE_SYMBOL MODE_SYMBOL (
        WITH_SYMBOL QUERY_SYMBOL EXPANSION_SYMBOL
    )?
    | WITH_SYMBOL QUERY_SYMBOL EXPANSION_SYMBOL
;

runtimeFunctionCall:
    // Function names that are keywords.
    name = CHAR_SYMBOL OPEN_PAR_SYMBOL exprList (USING_SYMBOL charsetName)? CLOSE_PAR_SYMBOL
    | name = CHAR_SYMBOL
    | name = CURRENT_USER_SYMBOL parentheses?
    | name = DATE_SYMBOL exprWithParentheses
    | name = DAY_SYMBOL exprWithParentheses
    | name = HOUR_SYMBOL exprWithParentheses
    | name = INSERT_SYMBOL OPEN_PAR_SYMBOL expr COMMA_SYMBOL expr COMMA_SYMBOL expr COMMA_SYMBOL expr CLOSE_PAR_SYMBOL
    | name = INTERVAL_SYMBOL OPEN_PAR_SYMBOL expr (COMMA_SYMBOL expr)+ CLOSE_PAR_SYMBOL
    | name = LEFT_SYMBOL OPEN_PAR_SYMBOL expr COMMA_SYMBOL expr CLOSE_PAR_SYMBOL
    | name = MINUTE_SYMBOL exprWithParentheses
    | name = MONTH_SYMBOL exprWithParentheses
    | name = RIGHT_SYMBOL OPEN_PAR_SYMBOL expr COMMA_SYMBOL expr CLOSE_PAR_SYMBOL
    | name = SECOND_SYMBOL exprWithParentheses
    | name = TIME_SYMBOL exprWithParentheses
    | name = TIMESTAMP_SYMBOL OPEN_PAR_SYMBOL expr (COMMA_SYMBOL expr)? CLOSE_PAR_SYMBOL
    | trimFunction
    | name = USER_SYMBOL parentheses
    | name = VALUES_SYMBOL exprWithParentheses
    | name = YEAR_SYMBOL exprWithParentheses

    // Function names that are not keywords.
    | name = (ADDDATE_SYMBOL | SUBDATE_SYMBOL) OPEN_PAR_SYMBOL expr COMMA_SYMBOL (
        expr
        | INTERVAL_SYMBOL expr interval
    ) CLOSE_PAR_SYMBOL
    | name = CURDATE_SYMBOL parentheses?
    | name = CURTIME_SYMBOL timeFunctionParameters?
    | name = (DATE_ADD_SYMBOL | DATE_SUB_SYMBOL) OPEN_PAR_SYMBOL expr COMMA_SYMBOL INTERVAL_SYMBOL expr interval CLOSE_PAR_SYMBOL
    | name = EXTRACT_SYMBOL OPEN_PAR_SYMBOL interval FROM_SYMBOL expr CLOSE_PAR_SYMBOL
    | name = GET_FORMAT_SYMBOL OPEN_PAR_SYMBOL dateTimeTtype COMMA_SYMBOL expr CLOSE_PAR_SYMBOL
    | name = NOW_SYMBOL timeFunctionParameters?
    | name = POSITION_SYMBOL OPEN_PAR_SYMBOL bitExpr IN_SYMBOL expr CLOSE_PAR_SYMBOL
    | substringFunction
    | name = SYSDATE_SYMBOL timeFunctionParameters?
    | name = (TIMESTAMP_ADD_SYMBOL | TIMESTAMP_DIFF_SYMBOL) OPEN_PAR_SYMBOL intervalTimeStamp COMMA_SYMBOL expr COMMA_SYMBOL expr
        CLOSE_PAR_SYMBOL
    | name = UTC_DATE_SYMBOL parentheses?
    | name = UTC_TIME_SYMBOL timeFunctionParameters?
    | name = UTC_TIMESTAMP_SYMBOL timeFunctionParameters?

    // Function calls with other conflicts.
    | name = ASCII_SYMBOL exprWithParentheses
    | name = CHARSET_SYMBOL exprWithParentheses
    | name = COALESCE_SYMBOL exprListWithParentheses
    | name = COLLATION_SYMBOL exprWithParentheses
    | name = DATABASE_SYMBOL parentheses
    | name = IF_SYMBOL OPEN_PAR_SYMBOL expr COMMA_SYMBOL expr COMMA_SYMBOL expr CLOSE_PAR_SYMBOL
    | name = FORMAT_SYMBOL OPEN_PAR_SYMBOL expr COMMA_SYMBOL expr (COMMA_SYMBOL expr)? CLOSE_PAR_SYMBOL
    | name = MICROSECOND_SYMBOL exprWithParentheses
    | name = MOD_SYMBOL OPEN_PAR_SYMBOL expr COMMA_SYMBOL expr CLOSE_PAR_SYMBOL
    | {status.serverVersion < 50607}? name = OLD_PASSWORD_SYMBOL OPEN_PAR_SYMBOL textLiteral CLOSE_PAR_SYMBOL
    | {status.serverVersion < 80011}? name = PASSWORD_SYMBOL exprWithParentheses
    | name = QUARTER_SYMBOL exprWithParentheses
    | name = REPEAT_SYMBOL OPEN_PAR_SYMBOL expr COMMA_SYMBOL expr CLOSE_PAR_SYMBOL
    | name = REPLACE_SYMBOL OPEN_PAR_SYMBOL expr COMMA_SYMBOL expr COMMA_SYMBOL expr CLOSE_PAR_SYMBOL
    | name = REVERSE_SYMBOL exprWithParentheses
    | name = ROW_COUNT_SYMBOL parentheses
    | name = TRUNCATE_SYMBOL OPEN_PAR_SYMBOL expr COMMA_SYMBOL expr CLOSE_PAR_SYMBOL
    | name = WEEK_SYMBOL OPEN_PAR_SYMBOL expr (COMMA_SYMBOL expr)? CLOSE_PAR_SYMBOL
    | name = WEIGHT_STRING_SYMBOL OPEN_PAR_SYMBOL expr (
        (AS_SYMBOL CHAR_SYMBOL wsNumCodepoints)? (
            {status.serverVersion < 80000}? weightStringLevels
        )?
        | AS_SYMBOL BINARY_SYMBOL wsNumCodepoints
        | COMMA_SYMBOL ulong_number COMMA_SYMBOL ulong_number COMMA_SYMBOL ulong_number
    ) CLOSE_PAR_SYMBOL
    | geometryFunction
;

geometryFunction:
    {status.serverVersion < 50706}? name = CONTAINS_SYMBOL OPEN_PAR_SYMBOL expr COMMA_SYMBOL expr CLOSE_PAR_SYMBOL
    | name = GEOMETRYCOLLECTION_SYMBOL OPEN_PAR_SYMBOL exprList? CLOSE_PAR_SYMBOL
    | name = LINESTRING_SYMBOL exprListWithParentheses
    | name = MULTILINESTRING_SYMBOL exprListWithParentheses
    | name = MULTIPOINT_SYMBOL exprListWithParentheses
    | name = MULTIPOLYGON_SYMBOL exprListWithParentheses
    | name = POINT_SYMBOL OPEN_PAR_SYMBOL expr COMMA_SYMBOL expr CLOSE_PAR_SYMBOL
    | name = POLYGON_SYMBOL exprListWithParentheses
;

timeFunctionParameters:
    OPEN_PAR_SYMBOL fractionalPrecision? CLOSE_PAR_SYMBOL
;

fractionalPrecision:
    {status.serverVersion >= 50604}? INT_NUMBER
;

weightStringLevels:
    LEVEL_SYMBOL (
        real_ulong_number MINUS_OPERATOR real_ulong_number
        | weightStringLevelListItem (COMMA_SYMBOL weightStringLevelListItem)*
    )
;

weightStringLevelListItem:
    real_ulong_number ((ASC_SYMBOL | DESC_SYMBOL) REVERSE_SYMBOL? | REVERSE_SYMBOL)?
;

dateTimeTtype:
    DATE_SYMBOL
    | TIME_SYMBOL
    | DATETIME_SYMBOL
    | TIMESTAMP_SYMBOL
;

trimFunction:
    TRIM_SYMBOL OPEN_PAR_SYMBOL (
        expr (FROM_SYMBOL expr)?
        | LEADING_SYMBOL expr? FROM_SYMBOL expr
        | TRAILING_SYMBOL expr? FROM_SYMBOL expr
        | BOTH_SYMBOL expr? FROM_SYMBOL expr
    ) CLOSE_PAR_SYMBOL
;

substringFunction:
    SUBSTRING_SYMBOL OPEN_PAR_SYMBOL expr (
        COMMA_SYMBOL expr (COMMA_SYMBOL expr)?
        | FROM_SYMBOL expr (FOR_SYMBOL expr)?
    ) CLOSE_PAR_SYMBOL
;

functionCall:
    pureIdentifier OPEN_PAR_SYMBOL udfExprList? CLOSE_PAR_SYMBOL     // For both UDF + other functions.
    | qualifiedIdentifier OPEN_PAR_SYMBOL exprList? CLOSE_PAR_SYMBOL // Other functions only.
;

udfExprList:
    udfExpr (COMMA_SYMBOL udfExpr)*
;

udfExpr:
    expr selectAlias?
;

variable:
    userVariable
    | systemVariable
;

userVariable:
    AT_SIGN_SYMBOL textOrIdentifier
    | AT_TEXT_SUFFIX
;

systemVariable:
    AT_AT_SIGN_SYMBOL varIdentType? textOrIdentifier dotIdentifier?
;

internalVariableName: (
        // Check in semantic phase that the first id is not global/local/session/default.
        {status.serverVersion < 80017}? identifier dotIdentifier?
        | {status.serverVersion >= 80017}? lValueIdentifier dotIdentifier?
    )
    | DEFAULT_SYMBOL dotIdentifier
;

whenExpression:
    WHEN_SYMBOL expr
;

thenExpression:
    THEN_SYMBOL expr
;

elseExpression:
    ELSE_SYMBOL expr
;

castType:
    BINARY_SYMBOL fieldLength?
    | CHAR_SYMBOL fieldLength? charsetWithOptBinary?
    | nchar fieldLength?
    | SIGNED_SYMBOL INT_SYMBOL?
    | UNSIGNED_SYMBOL INT_SYMBOL?
    | DATE_SYMBOL
    | TIME_SYMBOL typeDatetimePrecision?
    | DATETIME_SYMBOL typeDatetimePrecision?
    | DECIMAL_SYMBOL floatOptions?
    | {status.serverVersion >= 50708}? JSON_SYMBOL
    | {status.serverVersion >= 80017}? realType
    | {status.serverVersion >= 80017}? FLOAT_SYMBOL standardFloatOptions?
;

exprList:
    expr (COMMA_SYMBOL expr)*
;

charset:
    CHAR_SYMBOL SET_SYMBOL
    | CHARSET_SYMBOL
;

notRule:
    NOT_SYMBOL
    | NOT2_SYMBOL // A NOT with a different (higher) operator precedence.
;

not2Rule:
    LOGICAL_NOT_OPERATOR
    | NOT2_SYMBOL
;

// None of the microsecond variants can be used in schedules (e.g. events).
interval:
    intervalTimeStamp
    | (
        SECOND_MICROSECOND_SYMBOL
        | MINUTE_MICROSECOND_SYMBOL
        | MINUTE_SECOND_SYMBOL
        | HOUR_MICROSECOND_SYMBOL
        | HOUR_SECOND_SYMBOL
        | HOUR_MINUTE_SYMBOL
        | DAY_MICROSECOND_SYMBOL
        | DAY_SECOND_SYMBOL
        | DAY_MINUTE_SYMBOL
        | DAY_HOUR_SYMBOL
        | YEAR_MONTH_SYMBOL
    )
;

// Support for SQL_TSI_* units is added by mapping those to tokens without SQL_TSI_ prefix.
intervalTimeStamp:
    MICROSECOND_SYMBOL
    | SECOND_SYMBOL
    | MINUTE_SYMBOL
    | HOUR_SYMBOL
    | DAY_SYMBOL
    | WEEK_SYMBOL
    | MONTH_SYMBOL
    | QUARTER_SYMBOL
    | YEAR_SYMBOL
;

exprListWithParentheses:
    OPEN_PAR_SYMBOL exprList CLOSE_PAR_SYMBOL
;

exprWithParentheses:
    OPEN_PAR_SYMBOL expr CLOSE_PAR_SYMBOL
;

simpleExprWithParentheses:
    OPEN_PAR_SYMBOL simpleExpr CLOSE_PAR_SYMBOL
;

orderList:
    orderExpression (COMMA_SYMBOL orderExpression)*
;

orderExpression:
    expr direction?
;

groupList:
    groupingExpression (COMMA_SYMBOL groupingExpression)*
;

groupingExpression:
    expr
;

channel:
    {status.serverVersion >= 50706}? FOR_SYMBOL CHANNEL_SYMBOL textStringNoLinebreak
;

