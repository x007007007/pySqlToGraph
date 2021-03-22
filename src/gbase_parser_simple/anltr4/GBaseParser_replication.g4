parser grammar GBaseParser_replaction;

options {
//    superClass = MySQLBaseRecognizer;
    tokenVocab = GBaseLexer;
    exportMacro = PARSERS_PUBLIC_TYPE;
}


//----------------------------------------------------------------------------------------------------------------------

replicationStatement:
    PURGE_SYMBOL (BINARY_SYMBOL | MASTER_SYMBOL) LOGS_SYMBOL (
        TO_SYMBOL textLiteral
        | BEFORE_SYMBOL expr
    )
    | changeMaster
    | RESET_SYMBOL resetOption (COMMA_SYMBOL resetOption)*
    | {status.serverVersion > 80000}? RESET_SYMBOL PERSIST_SYMBOL (ifExists identifier)?
    | slave
    | {status.serverVersion >= 50700}? changeReplication
    | replicationLoad
    | {status.serverVersion > 50706}? groupReplication
;

resetOption:
    option = MASTER_SYMBOL masterResetOptions?
    | {status.serverVersion < 80000}? option = QUERY_SYMBOL CACHE_SYMBOL
    | option = SLAVE_SYMBOL ALL_SYMBOL? channel?
;

masterResetOptions:
    {status.serverVersion >= 80000}? TO_SYMBOL (
        {status.serverVersion < 80017}? real_ulong_number
        | {status.serverVersion >= 80017}? real_ulonglong_number
    )
;

replicationLoad:
    LOAD_SYMBOL (DATA_SYMBOL | TABLE_SYMBOL tableRef) FROM_SYMBOL MASTER_SYMBOL
;

changeMaster:
    CHANGE_SYMBOL MASTER_SYMBOL TO_SYMBOL changeMasterOptions channel?
;

changeMasterOptions:
    masterOption (COMMA_SYMBOL masterOption)*
;

masterOption:
    MASTER_HOST_SYMBOL EQUAL_OPERATOR textStringNoLinebreak
    | NETWORK_NAMESPACE_SYMBOL EQUAL_OPERATOR textStringNoLinebreak
    | MASTER_BIND_SYMBOL EQUAL_OPERATOR textStringNoLinebreak
    | MASTER_USER_SYMBOL EQUAL_OPERATOR textStringNoLinebreak
    | MASTER_PASSWORD_SYMBOL EQUAL_OPERATOR textStringNoLinebreak
    | MASTER_PORT_SYMBOL EQUAL_OPERATOR ulong_number
    | MASTER_CONNECT_RETRY_SYMBOL EQUAL_OPERATOR ulong_number
    | MASTER_RETRY_COUNT_SYMBOL EQUAL_OPERATOR ulong_number
    | MASTER_DELAY_SYMBOL EQUAL_OPERATOR ulong_number
    | MASTER_SSL_SYMBOL EQUAL_OPERATOR ulong_number
    | MASTER_SSL_CA_SYMBOL EQUAL_OPERATOR textStringNoLinebreak
    | MASTER_SSL_CAPATH_SYMBOL EQUAL_OPERATOR textStringNoLinebreak
    | MASTER_TLS_VERSION_SYMBOL EQUAL_OPERATOR textStringNoLinebreak
    | MASTER_SSL_CERT_SYMBOL EQUAL_OPERATOR textStringNoLinebreak
    | MASTER_TLS_CIPHERSUITES_SYMBOL EQUAL_OPERATOR masterTlsCiphersuitesDef
    | MASTER_SSL_CIPHER_SYMBOL EQUAL_OPERATOR textStringNoLinebreak
    | MASTER_SSL_KEY_SYMBOL EQUAL_OPERATOR textStringNoLinebreak
    | MASTER_SSL_VERIFY_SERVER_CERT_SYMBOL EQUAL_OPERATOR ulong_number
    | MASTER_SSL_CRL_SYMBOL EQUAL_OPERATOR textLiteral
    | MASTER_SSL_CRLPATH_SYMBOL EQUAL_OPERATOR textStringNoLinebreak
    | MASTER_PUBLIC_KEY_PATH_SYMBOL EQUAL_OPERATOR textStringNoLinebreak // Conditionally set in the lexer.
    | GET_MASTER_PUBLIC_KEY_SYMBOL EQUAL_OPERATOR ulong_number           // Conditionally set in the lexer.
    | MASTER_HEARTBEAT_PERIOD_SYMBOL EQUAL_OPERATOR ulong_number
    | IGNORE_SERVER_IDS_SYMBOL EQUAL_OPERATOR serverIdList
    | MASTER_COMPRESSION_ALGORITHM_SYMBOL EQUAL_OPERATOR textStringLiteral
    | MASTER_ZSTD_COMPRESSION_LEVEL_SYMBOL EQUAL_OPERATOR ulong_number
    | MASTER_AUTO_POSITION_SYMBOL EQUAL_OPERATOR ulong_number
    | PRIVILEGE_CHECKS_USER_SYMBOL EQUAL_OPERATOR privilegeCheckDef
    | REQUIRE_ROW_FORMAT_SYMBOL EQUAL_OPERATOR ulong_number
    | REQUIRE_TABLE_PRIMARY_KEY_CHECK_SYMBOL EQUAL_OPERATOR tablePrimaryKeyCheckDef
    | masterFileDef
;

privilegeCheckDef:
    userIdentifierOrText
    | NULL_SYMBOL
;

tablePrimaryKeyCheckDef:
    STREAM_SYMBOL
    | ON_SYMBOL
    | OFF_SYMBOL
;

masterTlsCiphersuitesDef:
    textStringNoLinebreak
    | NULL_SYMBOL
;

masterFileDef:
    MASTER_LOG_FILE_SYMBOL EQUAL_OPERATOR textStringNoLinebreak
    | MASTER_LOG_POS_SYMBOL EQUAL_OPERATOR ulonglong_number
    | RELAY_LOG_FILE_SYMBOL EQUAL_OPERATOR textStringNoLinebreak
    | RELAY_LOG_POS_SYMBOL EQUAL_OPERATOR ulong_number
;

serverIdList:
    OPEN_PAR_SYMBOL (ulong_number (COMMA_SYMBOL ulong_number)*)? CLOSE_PAR_SYMBOL
;

changeReplication:
    CHANGE_SYMBOL REPLICATION_SYMBOL FILTER_SYMBOL filterDefinition (
        COMMA_SYMBOL filterDefinition
    )* ({status.serverVersion >= 80000}? channel)?
;

filterDefinition:
    REPLICATE_DO_DB_SYMBOL EQUAL_OPERATOR OPEN_PAR_SYMBOL filterDbList? CLOSE_PAR_SYMBOL
    | REPLICATE_IGNORE_DB_SYMBOL EQUAL_OPERATOR OPEN_PAR_SYMBOL filterDbList? CLOSE_PAR_SYMBOL
    | REPLICATE_DO_TABLE_SYMBOL EQUAL_OPERATOR OPEN_PAR_SYMBOL filterTableList? CLOSE_PAR_SYMBOL
    | REPLICATE_IGNORE_TABLE_SYMBOL EQUAL_OPERATOR OPEN_PAR_SYMBOL filterTableList? CLOSE_PAR_SYMBOL
    | REPLICATE_WILD_DO_TABLE_SYMBOL EQUAL_OPERATOR OPEN_PAR_SYMBOL filterStringList? CLOSE_PAR_SYMBOL
    | REPLICATE_WILD_IGNORE_TABLE_SYMBOL EQUAL_OPERATOR OPEN_PAR_SYMBOL filterStringList? CLOSE_PAR_SYMBOL
    | REPLICATE_REWRITE_DB_SYMBOL EQUAL_OPERATOR OPEN_PAR_SYMBOL filterDbPairList? CLOSE_PAR_SYMBOL
;

filterDbList:
    schemaRef (COMMA_SYMBOL schemaRef)*
;

filterTableList:
    filterTableRef (COMMA_SYMBOL filterTableRef)*
;

filterStringList:
    filterWildDbTableString (COMMA_SYMBOL filterWildDbTableString)*
;

filterWildDbTableString:
    textStringNoLinebreak // sql_yacc.yy checks for the existance of at least one dot char in the string.
;

filterDbPairList:
    schemaIdentifierPair (COMMA_SYMBOL schemaIdentifierPair)*
;

slave:
    START_SYMBOL SLAVE_SYMBOL slaveThreadOptions? (UNTIL_SYMBOL slaveUntilOptions)? slaveConnectionOptions channel?
    | STOP_SYMBOL SLAVE_SYMBOL slaveThreadOptions? channel?
;

slaveUntilOptions:
    (
        masterFileDef
        | {status.serverVersion >= 50606}? (
            SQL_BEFORE_GTIDS_SYMBOL
            | SQL_AFTER_GTIDS_SYMBOL
        ) EQUAL_OPERATOR textString
        | {status.serverVersion >= 50606}? SQL_AFTER_MTS_GAPS_SYMBOL
    ) (COMMA_SYMBOL masterFileDef)*
;

slaveConnectionOptions:
    {status.serverVersion >= 50604}? (USER_SYMBOL EQUAL_OPERATOR textString)? (
        PASSWORD_SYMBOL EQUAL_OPERATOR textString
    )? (DEFAULT_AUTH_SYMBOL EQUAL_OPERATOR textString)? (
        PLUGIN_DIR_SYMBOL EQUAL_OPERATOR textString
    )?
    | /* empty */
;

slaveThreadOptions:
    slaveThreadOption (COMMA_SYMBOL slaveThreadOption)*
;

slaveThreadOption:
    RELAY_THREAD_SYMBOL
    | SQL_THREAD_SYMBOL
;

groupReplication:
    (START_SYMBOL | STOP_SYMBOL) GROUP_REPLICATION_SYMBOL
;

//----------------------------------------------------------------------------------------------------------------------
