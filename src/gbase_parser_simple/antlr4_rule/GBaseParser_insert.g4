parser grammar GBaseParser_insert;

options {
//    superClass = MySQLBaseRecognizer;
    tokenVocab = GBaseLexer;
    exportMacro = PARSERS_PUBLIC_TYPE;
}

//----------------------------------------------------------------------------------------------------------------------

insertStatement:
    INSERT_SYMBOL insertLockOption? IGNORE_SYMBOL? INTO_SYMBOL? tableRef usePartition? (
        insertFromConstructor ({ status.serverVersion >= 80018}? valuesReference)?
        | SET_SYMBOL updateList ({ status.serverVersion >= 80018}? valuesReference)?
        | insertQueryExpression
    ) insertUpdateList?
;

insertLockOption:
    LOW_PRIORITY_SYMBOL
    | DELAYED_SYMBOL // Only allowed if no select is used. Check in the semantic phase.
    | HIGH_PRIORITY_SYMBOL
;
// (c1, c3, ...) value (1,2,3,4)
insertFromConstructor:
    (OPEN_PAR_SYMBOL fields? CLOSE_PAR_SYMBOL)? insertValues
;

fields:
    insertIdentifier (COMMA_SYMBOL insertIdentifier)*
;

insertValues:
    (VALUES_SYMBOL | VALUE_SYMBOL) valueList
;

insertQueryExpression:
    queryExpressionOrParens
    | OPEN_PAR_SYMBOL fields? CLOSE_PAR_SYMBOL queryExpressionOrParens
;

valueList:
    OPEN_PAR_SYMBOL values? CLOSE_PAR_SYMBOL (
        COMMA_SYMBOL OPEN_PAR_SYMBOL values? CLOSE_PAR_SYMBOL
    )*
;

values:
    (expr | DEFAULT_SYMBOL) (COMMA_SYMBOL (expr | DEFAULT_SYMBOL))*
;

valuesReference:
    AS_SYMBOL identifier columnInternalRefList?
;

insertUpdateList:
    ON_SYMBOL DUPLICATE_SYMBOL KEY_SYMBOL UPDATE_SYMBOL updateList
;

//----------------------------------------------------------------------------------------------------------------------
