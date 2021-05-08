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