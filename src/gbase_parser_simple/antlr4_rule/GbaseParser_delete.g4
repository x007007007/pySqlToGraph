parser grammar GBaseParser_delete;

options {
//    superClass = MySQLBaseRecognizer;
    tokenVocab = GBaseLexer;
    exportMacro = PARSERS_PUBLIC_TYPE;
}

//--------------- DML statements ---------------------------------------------------------------------------------------


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
