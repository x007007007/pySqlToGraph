parser grammar GBaseParser_transection;

options {
//    superClass = MySQLBaseRecognizer;
    tokenVocab = GBaseLexer;
    exportMacro = PARSERS_PUBLIC_TYPE;
}


//----------------------------------------------------------------------------------------------------------------------

transactionOrLockingStatement:
    transactionStatement
    | savepointStatement
    | lockStatement
    | xaStatement
;

transactionStatement:
    START_SYMBOL TRANSACTION_SYMBOL transactionCharacteristic*
    | COMMIT_SYMBOL WORK_SYMBOL? (AND_SYMBOL NO_SYMBOL? CHAIN_SYMBOL)? (
        NO_SYMBOL? RELEASE_SYMBOL
    )?
    // SET TRANSACTION is part of setStatement.
;

// BEGIN WORK is separated from transactional statements as it must not appear as part of a stored program.
beginWork:
    BEGIN_SYMBOL WORK_SYMBOL?
;

transactionCharacteristic:
    WITH_SYMBOL CONSISTENT_SYMBOL SNAPSHOT_SYMBOL
    | {status.serverVersion >= 50605}? READ_SYMBOL (WRITE_SYMBOL | ONLY_SYMBOL)
;

savepointStatement:
    SAVEPOINT_SYMBOL identifier
    | ROLLBACK_SYMBOL WORK_SYMBOL? (
        TO_SYMBOL SAVEPOINT_SYMBOL? identifier
        | (AND_SYMBOL NO_SYMBOL? CHAIN_SYMBOL)? (NO_SYMBOL? RELEASE_SYMBOL)?
    )
    | RELEASE_SYMBOL SAVEPOINT_SYMBOL identifier
;

lockStatement:
    LOCK_SYMBOL (TABLES_SYMBOL | TABLE_SYMBOL) lockItem (COMMA_SYMBOL lockItem)*
    | {status.serverVersion >= 80000}? LOCK_SYMBOL INSTANCE_SYMBOL FOR_SYMBOL BACKUP_SYMBOL
    | UNLOCK_SYMBOL (
        TABLES_SYMBOL
        | TABLE_SYMBOL
        | {status.serverVersion >= 80000}? INSTANCE_SYMBOL
    )
;

lockItem:
    tableRef tableAlias? lockOption
;

lockOption:
    READ_SYMBOL LOCAL_SYMBOL?
    | LOW_PRIORITY_SYMBOL? WRITE_SYMBOL // low priority deprecated since 5.7
;

xaStatement:
    XA_SYMBOL (
        (START_SYMBOL | BEGIN_SYMBOL) xid (JOIN_SYMBOL | RESUME_SYMBOL)?
        | END_SYMBOL xid (SUSPEND_SYMBOL (FOR_SYMBOL MIGRATE_SYMBOL)?)?
        | PREPARE_SYMBOL xid
        | COMMIT_SYMBOL xid (ONE_SYMBOL PHASE_SYMBOL)?
        | ROLLBACK_SYMBOL xid
        | RECOVER_SYMBOL xaConvert
    )
;

xaConvert:
    {status.serverVersion >= 50704}? (CONVERT_SYMBOL XID_SYMBOL)?
    | /* empty */
;

xid:
    textString (COMMA_SYMBOL textString (COMMA_SYMBOL ulong_number)?)?
;

//----------------------------------------------------------------------------------------------------------------------
