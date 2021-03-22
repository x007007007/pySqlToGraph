parser grammar GBaseParser_show;

options {
//    superClass = MySQLBaseRecognizer;
    tokenVocab = GBaseLexer;
    exportMacro = PARSERS_PUBLIC_TYPE;
}


//----------------------------------------------------------------------------------------------------------------------

showStatement:
    SHOW_SYMBOL (
        {status.serverVersion < 50700}? value = AUTHORS_SYMBOL
        | value = DATABASES_SYMBOL likeOrWhere?
        | showCommandType? value = TABLES_SYMBOL inDb? likeOrWhere?
        | FULL_SYMBOL? value = TRIGGERS_SYMBOL inDb? likeOrWhere?
        | value = EVENTS_SYMBOL inDb? likeOrWhere?
        | value = TABLE_SYMBOL STATUS_SYMBOL inDb? likeOrWhere?
        | value = OPEN_SYMBOL TABLES_SYMBOL inDb? likeOrWhere?
        | value = PLUGINS_SYMBOL
        | value = ENGINE_SYMBOL (engineRef | ALL_SYMBOL) (
            STATUS_SYMBOL
            | MUTEX_SYMBOL
            | LOGS_SYMBOL
        )
        | showCommandType? value = COLUMNS_SYMBOL (FROM_SYMBOL | IN_SYMBOL) tableRef inDb? likeOrWhere?
        | (BINARY_SYMBOL | MASTER_SYMBOL) value = LOGS_SYMBOL
        | value = SLAVE_SYMBOL (HOSTS_SYMBOL | STATUS_SYMBOL nonBlocking channel?)
        | value = (BINLOG_SYMBOL | RELAYLOG_SYMBOL) EVENTS_SYMBOL (
            IN_SYMBOL textString
        )? (FROM_SYMBOL ulonglong_number)? limitClause? channel?
        | ({status.serverVersion >= 80000}? EXTENDED_SYMBOL)? value = (
            INDEX_SYMBOL
            | INDEXES_SYMBOL
            | KEYS_SYMBOL
        ) fromOrIn tableRef inDb? whereClause?
        | STORAGE_SYMBOL? value = ENGINES_SYMBOL
        | COUNT_SYMBOL OPEN_PAR_SYMBOL MULT_OPERATOR CLOSE_PAR_SYMBOL value = (
            WARNINGS_SYMBOL
            | ERRORS_SYMBOL
        )
        | value = WARNINGS_SYMBOL limitClause?
        | value = ERRORS_SYMBOL limitClause?
        | value = PROFILES_SYMBOL
        | value = PROFILE_SYMBOL (profileType (COMMA_SYMBOL profileType)*)? (
            FOR_SYMBOL QUERY_SYMBOL INT_NUMBER
        )? limitClause?
        | optionType? value = (STATUS_SYMBOL | VARIABLES_SYMBOL) likeOrWhere?
        | FULL_SYMBOL? value = PROCESSLIST_SYMBOL
        | charset likeOrWhere?
        | value = COLLATION_SYMBOL likeOrWhere?
        | {status.serverVersion < 50700}? value = CONTRIBUTORS_SYMBOL
        | value = PRIVILEGES_SYMBOL
        | value = GRANTS_SYMBOL (FOR_SYMBOL user)?
        | value = GRANTS_SYMBOL FOR_SYMBOL user USING_SYMBOL userList
        | value = MASTER_SYMBOL STATUS_SYMBOL
        | value = CREATE_SYMBOL (
            the_object = DATABASE_SYMBOL ifNotExists? schemaRef
            | the_object = EVENT_SYMBOL eventRef
            | the_object = FUNCTION_SYMBOL functionRef
            | the_object = PROCEDURE_SYMBOL procedureRef
            | the_object = TABLE_SYMBOL tableRef
            | the_object = TRIGGER_SYMBOL triggerRef
            | the_object = VIEW_SYMBOL viewRef
            | {status.serverVersion >= 50704}? the_object = USER_SYMBOL user
        )
        | value = PROCEDURE_SYMBOL STATUS_SYMBOL likeOrWhere?
        | value = FUNCTION_SYMBOL STATUS_SYMBOL likeOrWhere?
        | value = PROCEDURE_SYMBOL CODE_SYMBOL procedureRef
        | value = FUNCTION_SYMBOL CODE_SYMBOL functionRef
    )
;

showCommandType:
    FULL_SYMBOL
    | {status.serverVersion >= 80000}? EXTENDED_SYMBOL FULL_SYMBOL?
;

nonBlocking:
    {status.serverVersion >= 50700 and status.serverVersion < 50706}? NONBLOCKING_SYMBOL?
    | /* empty */
;

fromOrIn:
    FROM_SYMBOL
    | IN_SYMBOL
;

inDb:
    fromOrIn identifier
;

profileType:
    BLOCK_SYMBOL IO_SYMBOL
    | CONTEXT_SYMBOL SWITCHES_SYMBOL
    | PAGE_SYMBOL FAULTS_SYMBOL
    | (
        ALL_SYMBOL
        | CPU_SYMBOL
        | IPC_SYMBOL
        | MEMORY_SYMBOL
        | SOURCE_SYMBOL
        | SWAPS_SYMBOL
    )
;

//----------------------------------------------------------------------------------------------------------------------
