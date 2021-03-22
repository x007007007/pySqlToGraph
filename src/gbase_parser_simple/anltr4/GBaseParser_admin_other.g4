parser grammar GBaseParser_admin_other;

options {
//    superClass = MySQLBaseRecognizer;
    tokenVocab = GBaseLexer;
    exportMacro = PARSERS_PUBLIC_TYPE;
}

//----------------------------------------------------------------------------------------------------------------------

otherAdministrativeStatement:
    the_type = BINLOG_SYMBOL textLiteral
    | the_type = CACHE_SYMBOL INDEX_SYMBOL keyCacheListOrParts IN_SYMBOL (
        identifier
        | DEFAULT_SYMBOL
    )
    | the_type = FLUSH_SYMBOL noWriteToBinLog? (
        flushTables
        | flushOption (COMMA_SYMBOL flushOption)*
    )
    | the_type = KILL_SYMBOL (CONNECTION_SYMBOL | QUERY_SYMBOL)? expr
    | the_type = LOAD_SYMBOL INDEX_SYMBOL INTO_SYMBOL CACHE_SYMBOL preloadTail
    | {status.serverVersion >= 50709}? the_type = SHUTDOWN_SYMBOL
;

keyCacheListOrParts:
    keyCacheList
    | assignToKeycachePartition
;

keyCacheList:
    assignToKeycache (COMMA_SYMBOL assignToKeycache)*
;

assignToKeycache:
    tableRef cacheKeyList?
;

assignToKeycachePartition:
    tableRef PARTITION_SYMBOL OPEN_PAR_SYMBOL allOrPartitionNameList CLOSE_PAR_SYMBOL cacheKeyList?
;

cacheKeyList:
    keyOrIndex OPEN_PAR_SYMBOL keyUsageList? CLOSE_PAR_SYMBOL
;

keyUsageElement:
    identifier
    | PRIMARY_SYMBOL
;

keyUsageList:
    keyUsageElement (COMMA_SYMBOL keyUsageElement)*
;

flushOption:
    option = (
        DES_KEY_FILE_SYMBOL // No longer used from 8.0 onwards. Taken out by lexer.
        | HOSTS_SYMBOL
        | PRIVILEGES_SYMBOL
        | STATUS_SYMBOL
        | USER_RESOURCES_SYMBOL
    )
    | logType? option = LOGS_SYMBOL
    | option = RELAY_SYMBOL LOGS_SYMBOL channel?
    | {status.serverVersion < 80000}? option = QUERY_SYMBOL CACHE_SYMBOL
    | {status.serverVersion >= 50706}? option = OPTIMIZER_COSTS_SYMBOL
;

logType:
    BINARY_SYMBOL
    | ENGINE_SYMBOL
    | ERROR_SYMBOL
    | GENERAL_SYMBOL
    | SLOW_SYMBOL
;

flushTables:
    (TABLES_SYMBOL | TABLE_SYMBOL) (
        WITH_SYMBOL READ_SYMBOL LOCK_SYMBOL
        | identifierList flushTablesOptions?
    )?
;

flushTablesOptions:
    {status.serverVersion >= 50606}? FOR_SYMBOL EXPORT_SYMBOL
    | WITH_SYMBOL READ_SYMBOL LOCK_SYMBOL
;

preloadTail:
    tableRef adminPartition cacheKeyList? (IGNORE_SYMBOL LEAVES_SYMBOL)?
    | preloadList
;

preloadList:
    preloadKeys (COMMA_SYMBOL preloadKeys)*
;

preloadKeys:
    tableRef cacheKeyList? (IGNORE_SYMBOL LEAVES_SYMBOL)?
;

adminPartition:
    PARTITION_SYMBOL OPEN_PAR_SYMBOL allOrPartitionNameList CLOSE_PAR_SYMBOL
;

//----------------------------------------------------------------------------------------------------------------------