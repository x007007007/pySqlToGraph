parser grammar GBaseParser_dlm;

options {
//    superClass = MySQLBaseRecognizer;
    tokenVocab = GBaseLexer;
    exportMacro = PARSERS_PUBLIC_TYPE;
}

//--------------- DML statements ---------------------------------------------------------------------------------------

callStatement:
    CALL_SYMBOL procedureRef (OPEN_PAR_SYMBOL exprList? CLOSE_PAR_SYMBOL)?
;

deleteStatement:
    ({status.serverVersion >= 80000}? withClause)? DELETE_SYMBOL deleteStatementOption* (
        FROM_SYMBOL (
            tableAliasRefList USING_SYMBOL tableReferenceList whereClause?       // Multi table variant 1.
            | tableRef ({status.serverVersion >= 80017}? tableAlias)? partitionDelete?
                whereClause? orderClause? simpleLimitClause?                     // Single table delete.
        )
        | tableAliasRefList FROM_SYMBOL tableReferenceList whereClause?          // Multi table variant 2.
    )
;

partitionDelete:
    {status.serverVersion >= 50602}? PARTITION_SYMBOL OPEN_PAR_SYMBOL identifierList CLOSE_PAR_SYMBOL
;

deleteStatementOption: // opt_delete_option in sql_yacc.yy, but the name collides with another rule (delete_options).
    QUICK_SYMBOL
    | LOW_PRIORITY_SYMBOL
    | QUICK_SYMBOL
    | IGNORE_SYMBOL
;

doStatement:
    DO_SYMBOL (
        {status.serverVersion < 50709}? exprList
        | {status.serverVersion >= 50709}? selectItemList
    )
;

handlerStatement:
    HANDLER_SYMBOL (
        tableRef OPEN_SYMBOL tableAlias?
        | identifier (
            CLOSE_SYMBOL
            | READ_SYMBOL handlerReadOrScan whereClause? limitClause?
        )
    )
;

handlerReadOrScan:
    (FIRST_SYMBOL | NEXT_SYMBOL) // Scan function.
    | identifier (
        // The rkey part.
        (FIRST_SYMBOL | NEXT_SYMBOL | PREV_SYMBOL | LAST_SYMBOL)
        | (
            EQUAL_OPERATOR
            | LESS_THAN_OPERATOR
            | GREATER_THAN_OPERATOR
            | LESS_OR_EQUAL_OPERATOR
            | GREATER_OR_EQUAL_OPERATOR
        ) OPEN_PAR_SYMBOL values CLOSE_PAR_SYMBOL
    )
;

//----------------------------------------------------------------------------------------------------------------------