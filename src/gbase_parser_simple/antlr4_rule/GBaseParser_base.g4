parser grammar GBaseParser_base;

options {
//    superClass = MySQLBaseRecognizer;
    tokenVocab = GBaseLexer;
    exportMacro = PARSERS_PUBLIC_TYPE;
}

//----------------- Common basic rules ---------------------------------------------------------------------------------

// Identifiers excluding keywords (except if they are quoted). IDENT_sys in sql_yacc.yy.
pureIdentifier:
    (IDENTIFIER | BACK_TICK_QUOTED_ID)
    | {status.isSqlModeActive(status.AnsiQuotes)}? DOUBLE_QUOTED_TEXT
;

// Identifiers including a certain set of keywords, which are allowed also if not quoted.
// ident in sql_yacc.yy
identifier:
    pureIdentifier
    | identifierKeyword
;

identifierList: // ident_string_list in sql_yacc.yy.
    identifier (COMMA_SYMBOL identifier)*
;

identifierListWithParentheses:
    OPEN_PAR_SYMBOL identifierList CLOSE_PAR_SYMBOL
;

qualifiedIdentifier:
    identifier dotIdentifier?
;

simpleIdentifier: // simple_ident + simple_ident_q
    identifier (dotIdentifier dotIdentifier?)?
   // | dotIdentifier dotIdentifier                 //{status.serverVersion < 80000}?
;

// This rule encapsulates the frequently used dot + identifier sequence, which also requires a special
// treatment in the lexer. See there in the DOT_IDENTIFIER rule.
dotIdentifier:
    DOT_SYMBOL identifier
;

ulong_number:
    INT_NUMBER
    | HEX_NUMBER
    | LONG_NUMBER
    | ULONGLONG_NUMBER
    | DECIMAL_NUMBER
    | FLOAT_NUMBER
;

real_ulong_number:
    INT_NUMBER
    | HEX_NUMBER
    | LONG_NUMBER
    | ULONGLONG_NUMBER
;

ulonglong_number:
    INT_NUMBER
    | LONG_NUMBER
    | ULONGLONG_NUMBER
    | DECIMAL_NUMBER
    | FLOAT_NUMBER
;

real_ulonglong_number:
    INT_NUMBER
    | HEX_NUMBER  // {status.serverVersion >= 80017}?
    | ULONGLONG_NUMBER
    | LONG_NUMBER
;

literal:
    textLiteral
    | numLiteral
    | temporalLiteral
    | nullLiteral
    | boolLiteral
    | UNDERSCORE_CHARSET? (HEX_NUMBER | BIN_NUMBER)
;

signedLiteral:
    literal
    | PLUS_OPERATOR ulong_number
    | MINUS_OPERATOR ulong_number
;

stringList:
    OPEN_PAR_SYMBOL textString (COMMA_SYMBOL textString)* CLOSE_PAR_SYMBOL
;

// TEXT_STRING_sys + TEXT_STRING_literal + TEXT_STRING_filesystem + TEXT_STRING + TEXT_STRING_password +
// TEXT_STRING_validated in sql_yacc.yy.
textStringLiteral:
    value = SINGLE_QUOTED_TEXT
    | {not status.isSqlModeActive(status.AnsiQuotes)}? value = DOUBLE_QUOTED_TEXT
;

textString:
    textStringLiteral
    | HEX_NUMBER
    | BIN_NUMBER
;

textStringHash:
    textStringLiteral
    | {status.serverVersion >= 80017}? HEX_NUMBER
;

textLiteral:
    (UNDERSCORE_CHARSET? textStringLiteral | NCHAR_TEXT) textStringLiteral*
;

// A special variant of a text string that must not contain a linebreak (TEXT_STRING_sys_nonewline in sql_yacc.yy).
// Check validity in semantic phase.
textStringNoLinebreak:
    textStringLiteral
;

textStringLiteralList:
    textStringLiteral (COMMA_SYMBOL textStringLiteral)*
;

numLiteral:
    INT_NUMBER
    | LONG_NUMBER
    | ULONGLONG_NUMBER
    | DECIMAL_NUMBER
    | FLOAT_NUMBER
;

boolLiteral:
    TRUE_SYMBOL
    | FALSE_SYMBOL
;

nullLiteral: // In sql_yacc.cc both 'NULL' and '\N' are mapped to NULL_SYM (which is our nullLiteral).
    NULL_SYMBOL
    | NULL2_SYMBOL
;

temporalLiteral:
    DATE_SYMBOL SINGLE_QUOTED_TEXT
    | TIME_SYMBOL SINGLE_QUOTED_TEXT
    | TIMESTAMP_SYMBOL SINGLE_QUOTED_TEXT
;

floatOptions:
    fieldLength
    | precision
;

standardFloatOptions:
    precision
;

precision:
    OPEN_PAR_SYMBOL INT_NUMBER COMMA_SYMBOL INT_NUMBER CLOSE_PAR_SYMBOL
;

textOrIdentifier:
    identifier
    | textStringLiteral
;

lValueIdentifier:
    pureIdentifier
    | lValueKeyword
;

roleIdentifierOrText:
    roleIdentifier
    | textStringLiteral
;

sizeNumber:
    real_ulonglong_number
    | pureIdentifier // Something like 10G. Semantic check needed for validity.
;

parentheses:
    OPEN_PAR_SYMBOL CLOSE_PAR_SYMBOL
;

equal:
    EQUAL_OPERATOR
    | ASSIGN_OPERATOR
;

// PERSIST and PERSIST_ONLY are conditionally handled in the lexer. Hence no predicate required here.
optionType:
    PERSIST_SYMBOL
    | PERSIST_ONLY_SYMBOL
    | GLOBAL_SYMBOL
    | LOCAL_SYMBOL
    | SESSION_SYMBOL
;

varIdentType:
    GLOBAL_SYMBOL DOT_SYMBOL
    | LOCAL_SYMBOL DOT_SYMBOL
    | SESSION_SYMBOL DOT_SYMBOL
;

setVarIdentType:
    PERSIST_SYMBOL DOT_SYMBOL
    | PERSIST_ONLY_SYMBOL DOT_SYMBOL
    | GLOBAL_SYMBOL DOT_SYMBOL
    | LOCAL_SYMBOL DOT_SYMBOL
    | SESSION_SYMBOL DOT_SYMBOL
;

// Note: rules for non-reserved keywords have changed significantly with MySQL 8.0.17, which make their
//       version dependent handling complicated.
//       Comments for keyword rules are taken over directly from the server grammar, but usually don't apply here
//       since we don't have something like shift/reduce conflicts in ANTLR4 (which those ugly rules try to overcome).

// Non-reserved keywords are allowed as unquoted identifiers in general.
//
// OTOH, in a few particular cases statement-specific rules are used
// instead of `ident_keyword` to avoid grammar ambiguities:
//
//  * `label_keyword` for SP label names
//  * `role_keyword` for role names
//  * `lvalue_keyword` for variable prefixes and names in left sides of
//                     assignments in SET statements
//
// Normally, new non-reserved words should be added to the
// the rule `ident_keywords_unambiguous`. If they cause grammar conflicts, try
// one of `ident_keywords_ambiguous_...` rules instead.
identifierKeyword:
    {status.serverVersion < 80017}? (
        labelKeyword
        | roleOrIdentifierKeyword
        | EXECUTE_SYMBOL
        | {status.serverVersion >= 50709}? SHUTDOWN_SYMBOL // Previously allowed as SP label as well.
        | {status.serverVersion >= 80011}? RESTART_SYMBOL
    )
    | (
        identifierKeywordsUnambiguous
        | identifierKeywordsAmbiguous1RolesAndLabels
        | identifierKeywordsAmbiguous2Labels
        | identifierKeywordsAmbiguous3Roles
        | identifierKeywordsAmbiguous4SystemVariables
    )
;

// These non-reserved words cannot be used as role names and SP label names:
identifierKeywordsAmbiguous1RolesAndLabels:
    EXECUTE_SYMBOL
    | RESTART_SYMBOL
    | SHUTDOWN_SYMBOL
;

// These non-reserved keywords cannot be used as unquoted SP label names:
identifierKeywordsAmbiguous2Labels:
    ASCII_SYMBOL
    | BEGIN_SYMBOL
    | BYTE_SYMBOL
    | CACHE_SYMBOL
    | CHARSET_SYMBOL
    | CHECKSUM_SYMBOL
    | CLONE_SYMBOL
    | COMMENT_SYMBOL
    | COMMIT_SYMBOL
    | CONTAINS_SYMBOL
    | DEALLOCATE_SYMBOL
    | DO_SYMBOL
    | END_SYMBOL
    | FLUSH_SYMBOL
    | FOLLOWS_SYMBOL
    | HANDLER_SYMBOL
    | HELP_SYMBOL
    | IMPORT_SYMBOL
    | INSTALL_SYMBOL
    | LANGUAGE_SYMBOL
    | NO_SYMBOL
    | PRECEDES_SYMBOL
    | PREPARE_SYMBOL
    | REPAIR_SYMBOL
    | RESET_SYMBOL
    | ROLLBACK_SYMBOL
    | SAVEPOINT_SYMBOL
    | SIGNED_SYMBOL
    | SLAVE_SYMBOL
    | START_SYMBOL
    | STOP_SYMBOL
    | TRUNCATE_SYMBOL
    | UNICODE_SYMBOL
    | UNINSTALL_SYMBOL
    | XA_SYMBOL
;

// Keywords that we allow for labels in SPs in the unquoted form.
// Any keyword that is allowed to begin a statement or routine characteristics
// must be in `ident_keywords_ambiguous_2_labels` above, otherwise
// we get (harmful) shift/reduce conflicts.
//
// Not allowed:
//
//   ident_keywords_ambiguous_1_roles_and_labels
//   ident_keywords_ambiguous_2_labels
labelKeyword:
    {status.serverVersion < 80017}? (
        roleOrLabelKeyword
        | EVENT_SYMBOL
        | FILE_SYMBOL
        | NONE_SYMBOL
        | PROCESS_SYMBOL
        | PROXY_SYMBOL
        | RELOAD_SYMBOL
        | REPLICATION_SYMBOL
        | RESOURCE_SYMBOL // Conditionally set in the lexer.
        | SUPER_SYMBOL
    )
    | (
        identifierKeywordsUnambiguous
        | identifierKeywordsAmbiguous3Roles
        | identifierKeywordsAmbiguous4SystemVariables
    )
;

// These non-reserved keywords cannot be used as unquoted role names:
identifierKeywordsAmbiguous3Roles:
    EVENT_SYMBOL
    | FILE_SYMBOL
    | NONE_SYMBOL
    | PROCESS_SYMBOL
    | PROXY_SYMBOL
    | RELOAD_SYMBOL
    | REPLICATION_SYMBOL
    | RESOURCE_SYMBOL
    | SUPER_SYMBOL
;

// These are the non-reserved keywords which may be used for unquoted
// identifiers everywhere without introducing grammar conflicts:
identifierKeywordsUnambiguous:
    (
        ACTION_SYMBOL
        | ACCOUNT_SYMBOL
        | ACTIVE_SYMBOL
        | ADDDATE_SYMBOL
        | ADMIN_SYMBOL
        | AFTER_SYMBOL
        | AGAINST_SYMBOL
        | AGGREGATE_SYMBOL
        | ALGORITHM_SYMBOL
        | ALWAYS_SYMBOL
        | ANY_SYMBOL
        | AT_SYMBOL
        | AUTOEXTEND_SIZE_SYMBOL
        | AUTO_INCREMENT_SYMBOL
        | AVG_ROW_LENGTH_SYMBOL
        | AVG_SYMBOL
        | BACKUP_SYMBOL
        | BINLOG_SYMBOL
        | BIT_SYMBOL
        | BLOCK_SYMBOL
        | BOOLEAN_SYMBOL
        | BOOL_SYMBOL
        | BTREE_SYMBOL
        | BUCKETS_SYMBOL
        | CASCADED_SYMBOL
        | CATALOG_NAME_SYMBOL
        | CHAIN_SYMBOL
        | CHANGED_SYMBOL
        | CHANNEL_SYMBOL
        | CIPHER_SYMBOL
        | CLASS_ORIGIN_SYMBOL
        | CLIENT_SYMBOL
        | CLOSE_SYMBOL
        | COALESCE_SYMBOL
        | CODE_SYMBOL
        | COLLATION_SYMBOL
        | COLUMNS_SYMBOL
        | COLUMN_FORMAT_SYMBOL
        | COLUMN_NAME_SYMBOL
        | COMMITTED_SYMBOL
        | COMPACT_SYMBOL
        | COMPLETION_SYMBOL
        | COMPONENT_SYMBOL
        | COMPRESSED_SYMBOL
        | COMPRESSION_SYMBOL
        | CONCURRENT_SYMBOL
        | CONNECTION_SYMBOL
        | CONSISTENT_SYMBOL
        | CONSTRAINT_CATALOG_SYMBOL
        | CONSTRAINT_NAME_SYMBOL
        | CONSTRAINT_SCHEMA_SYMBOL
        | CONTEXT_SYMBOL
        | CPU_SYMBOL
        | CURRENT_SYMBOL // not reserved in MySQL per WL#2111 specification
        | CURSOR_NAME_SYMBOL
        | DATAFILE_SYMBOL
        | DATA_SYMBOL
        | DATETIME_SYMBOL
        | DATE_SYMBOL
        | DAY_SYMBOL
        | DEFAULT_AUTH_SYMBOL
        | DEFINER_SYMBOL
        | DEFINITION_SYMBOL
        | DELAY_KEY_WRITE_SYMBOL
        | DESCRIPTION_SYMBOL
        | DIAGNOSTICS_SYMBOL
        | DIRECTORY_SYMBOL
        | DISABLE_SYMBOL
        | DISCARD_SYMBOL
        | DISK_SYMBOL
        | DUMPFILE_SYMBOL
        | DUPLICATE_SYMBOL
        | DYNAMIC_SYMBOL
        | ENABLE_SYMBOL
        | ENCRYPTION_SYMBOL
        | ENDS_SYMBOL
        | ENFORCED_SYMBOL
        | ENGINES_SYMBOL
        | ENGINE_SYMBOL
        | ENUM_SYMBOL
        | ERRORS_SYMBOL
        | ERROR_SYMBOL
        | ESCAPE_SYMBOL
        | EVENTS_SYMBOL
        | EVERY_SYMBOL
        | EXCHANGE_SYMBOL
        | EXCLUDE_SYMBOL
        | EXPANSION_SYMBOL
        | EXPIRE_SYMBOL
        | EXPORT_SYMBOL
        | EXTENDED_SYMBOL
        | EXTENT_SIZE_SYMBOL
        | FAST_SYMBOL
        | FAULTS_SYMBOL
        | FILE_BLOCK_SIZE_SYMBOL
        | FILTER_SYMBOL
        | FIRST_SYMBOL
        | FIXED_SYMBOL
        | FOLLOWING_SYMBOL
        | FORMAT_SYMBOL
        | FOUND_SYMBOL
        | FULL_SYMBOL
        | GENERAL_SYMBOL
        | GEOMETRYCOLLECTION_SYMBOL
        | GEOMETRY_SYMBOL
        | GET_FORMAT_SYMBOL
        | GET_MASTER_PUBLIC_KEY_SYMBOL
        | GRANTS_SYMBOL
        | GROUP_REPLICATION_SYMBOL
        | HASH_SYMBOL
        | HISTOGRAM_SYMBOL
        | HISTORY_SYMBOL
        | HOSTS_SYMBOL
        | HOST_SYMBOL
        | HOUR_SYMBOL
        | IDENTIFIED_SYMBOL
        | IGNORE_SERVER_IDS_SYMBOL
        | INACTIVE_SYMBOL
        | INDEXES_SYMBOL
        | INITIAL_SIZE_SYMBOL
        | INSERT_METHOD_SYMBOL
        | INSTANCE_SYMBOL
        | INVISIBLE_SYMBOL
        | INVOKER_SYMBOL
        | IO_SYMBOL
        | IPC_SYMBOL
        | ISOLATION_SYMBOL
        | ISSUER_SYMBOL
        | JSON_SYMBOL
        | KEY_BLOCK_SIZE_SYMBOL
        | LAST_SYMBOL
        | LEAVES_SYMBOL
        | LESS_SYMBOL
        | LEVEL_SYMBOL
        | LINESTRING_SYMBOL
        | LIST_SYMBOL
        | LOCKED_SYMBOL
        | LOCKS_SYMBOL
        | LOGFILE_SYMBOL
        | LOGS_SYMBOL
        | MASTER_AUTO_POSITION_SYMBOL
        | MASTER_COMPRESSION_ALGORITHM_SYMBOL
        | MASTER_CONNECT_RETRY_SYMBOL
        | MASTER_DELAY_SYMBOL
        | MASTER_HEARTBEAT_PERIOD_SYMBOL
        | MASTER_HOST_SYMBOL
        | NETWORK_NAMESPACE_SYMBOL
        | MASTER_LOG_FILE_SYMBOL
        | MASTER_LOG_POS_SYMBOL
        | MASTER_PASSWORD_SYMBOL
        | MASTER_PORT_SYMBOL
        | MASTER_PUBLIC_KEY_PATH_SYMBOL
        | MASTER_RETRY_COUNT_SYMBOL
        | MASTER_SERVER_ID_SYMBOL
        | MASTER_SSL_CAPATH_SYMBOL
        | MASTER_SSL_CA_SYMBOL
        | MASTER_SSL_CERT_SYMBOL
        | MASTER_SSL_CIPHER_SYMBOL
        | MASTER_SSL_CRLPATH_SYMBOL
        | MASTER_SSL_CRL_SYMBOL
        | MASTER_SSL_KEY_SYMBOL
        | MASTER_SSL_SYMBOL
        | MASTER_SYMBOL
        | MASTER_TLS_CIPHERSUITES_SYMBOL
        | MASTER_TLS_VERSION_SYMBOL
        | MASTER_USER_SYMBOL
        | MASTER_ZSTD_COMPRESSION_LEVEL_SYMBOL
        | MAX_CONNECTIONS_PER_HOUR_SYMBOL
        | MAX_QUERIES_PER_HOUR_SYMBOL
        | MAX_ROWS_SYMBOL
        | MAX_SIZE_SYMBOL
        | MAX_UPDATES_PER_HOUR_SYMBOL
        | MAX_USER_CONNECTIONS_SYMBOL
        | MEDIUM_SYMBOL
        | MEMORY_SYMBOL
        | MERGE_SYMBOL
        | MESSAGE_TEXT_SYMBOL
        | MICROSECOND_SYMBOL
        | MIGRATE_SYMBOL
        | MINUTE_SYMBOL
        | MIN_ROWS_SYMBOL
        | MODE_SYMBOL
        | MODIFY_SYMBOL
        | MONTH_SYMBOL
        | MULTILINESTRING_SYMBOL
        | MULTIPOINT_SYMBOL
        | MULTIPOLYGON_SYMBOL
        | MUTEX_SYMBOL
        | MYSQL_ERRNO_SYMBOL
        | NAMES_SYMBOL
        | NAME_SYMBOL
        | NATIONAL_SYMBOL
        | NCHAR_SYMBOL
        | NDBCLUSTER_SYMBOL
        | NESTED_SYMBOL
        | NEVER_SYMBOL
        | NEW_SYMBOL
        | NEXT_SYMBOL
        | NODEGROUP_SYMBOL
        | NOWAIT_SYMBOL
        | NO_WAIT_SYMBOL
        | NULLS_SYMBOL
        | NUMBER_SYMBOL
        | NVARCHAR_SYMBOL
        | OFFSET_SYMBOL
        | OJ_SYMBOL
        | OLD_SYMBOL
        | ONE_SYMBOL
        | ONLY_SYMBOL
        | OPEN_SYMBOL
        | OPTIONAL_SYMBOL
        | OPTIONS_SYMBOL
        | ORDINALITY_SYMBOL
        | ORGANIZATION_SYMBOL
        | OTHERS_SYMBOL
        | OWNER_SYMBOL
        | PACK_KEYS_SYMBOL
        | PAGE_SYMBOL
        | PARSER_SYMBOL
        | PARTIAL_SYMBOL
        | PARTITIONING_SYMBOL
        | PARTITIONS_SYMBOL
        | PASSWORD_SYMBOL
        | PATH_SYMBOL
        | PHASE_SYMBOL
        | PLUGINS_SYMBOL
        | PLUGIN_DIR_SYMBOL
        | PLUGIN_SYMBOL
        | POINT_SYMBOL
        | POLYGON_SYMBOL
        | PORT_SYMBOL
        | PRECEDING_SYMBOL
        | PRESERVE_SYMBOL
        | PREV_SYMBOL
        | PRIVILEGES_SYMBOL
        | PRIVILEGE_CHECKS_USER_SYMBOL
        | PROCESSLIST_SYMBOL
        | PROFILES_SYMBOL
        | PROFILE_SYMBOL
        | QUARTER_SYMBOL
        | QUERY_SYMBOL
        | QUICK_SYMBOL
        | READ_ONLY_SYMBOL
        | REBUILD_SYMBOL
        | RECOVER_SYMBOL
        | REDO_BUFFER_SIZE_SYMBOL
        | REDUNDANT_SYMBOL
        | REFERENCE_SYMBOL
        | RELAY_SYMBOL
        | RELAYLOG_SYMBOL
        | RELAY_LOG_FILE_SYMBOL
        | RELAY_LOG_POS_SYMBOL
        | RELAY_THREAD_SYMBOL
        | REMOVE_SYMBOL
        | REORGANIZE_SYMBOL
        | REPEATABLE_SYMBOL
        | REPLICATE_DO_DB_SYMBOL
        | REPLICATE_DO_TABLE_SYMBOL
        | REPLICATE_IGNORE_DB_SYMBOL
        | REPLICATE_IGNORE_TABLE_SYMBOL
        | REPLICATE_REWRITE_DB_SYMBOL
        | REPLICATE_WILD_DO_TABLE_SYMBOL
        | REPLICATE_WILD_IGNORE_TABLE_SYMBOL
        | USER_RESOURCES_SYMBOL
        | RESPECT_SYMBOL
        | RESTORE_SYMBOL
        | RESUME_SYMBOL
        | RETAIN_SYMBOL
        | RETURNED_SQLSTATE_SYMBOL
        | RETURNED_GBASE_ERRNO_SYMBOL
        | RETURNS_SYMBOL
        | REUSE_SYMBOL
        | REVERSE_SYMBOL
        | ROLE_SYMBOL
        | ROLLUP_SYMBOL
        | ROTATE_SYMBOL
        | ROUTINE_SYMBOL
        | ROW_COUNT_SYMBOL
        | ROW_FORMAT_SYMBOL
        | RTREE_SYMBOL
        | SCHEDULE_SYMBOL
        | SCHEMA_NAME_SYMBOL
        | SECONDARY_ENGINE_SYMBOL
        | SECONDARY_LOAD_SYMBOL
        | SECONDARY_SYMBOL
        | SECONDARY_UNLOAD_SYMBOL
        | SECOND_SYMBOL
        | SECURITY_SYMBOL
        | SERIALIZABLE_SYMBOL
        | SERIAL_SYMBOL
        | SERVER_SYMBOL
        | SHARE_SYMBOL
        | SIMPLE_SYMBOL
        | SKIP_SYMBOL
        | SLOW_SYMBOL
        | SNAPSHOT_SYMBOL
        | SOCKET_SYMBOL
        | SONAME_SYMBOL
        | SOUNDS_SYMBOL
        | SOURCE_SYMBOL
        | SQL_AFTER_GTIDS_SYMBOL
        | SQL_AFTER_MTS_GAPS_SYMBOL
        | SQL_BEFORE_GTIDS_SYMBOL
        | SQL_BUFFER_RESULT_SYMBOL
        | SQL_NO_CACHE_SYMBOL
        | SQL_THREAD_SYMBOL
        | SRID_SYMBOL
        | STACKED_SYMBOL
        | STARTS_SYMBOL
        | STATS_AUTO_RECALC_SYMBOL
        | STATS_PERSISTENT_SYMBOL
        | STATS_SAMPLE_PAGES_SYMBOL
        | STATUS_SYMBOL
        | STORAGE_SYMBOL
        | STRING_SYMBOL
        | SUBCLASS_ORIGIN_SYMBOL
        | SUBDATE_SYMBOL
        | SUBJECT_SYMBOL
        | SUBPARTITIONS_SYMBOL
        | SUBPARTITION_SYMBOL
        | SUSPEND_SYMBOL
        | SWAPS_SYMBOL
        | SWITCHES_SYMBOL
        | TABLES_SYMBOL
        | TABLESPACE_SYMBOL
        | TABLE_CHECKSUM_SYMBOL
        | TABLE_NAME_SYMBOL
        | TEMPORARY_SYMBOL
        | TEMPTABLE_SYMBOL
        | TEXT_SYMBOL
        | THAN_SYMBOL
        | THREAD_PRIORITY_SYMBOL
        | TIES_SYMBOL
        | TIMESTAMP_ADD_SYMBOL
        | TIMESTAMP_DIFF_SYMBOL
        | TIMESTAMP_SYMBOL
        | TIME_SYMBOL
        | TRANSACTION_SYMBOL
        | TRIGGERS_SYMBOL
        | TYPES_SYMBOL
        | TYPE_SYMBOL
        | UNBOUNDED_SYMBOL
        | UNCOMMITTED_SYMBOL
        | UNDEFINED_SYMBOL
        | UNDOFILE_SYMBOL
        | UNDO_BUFFER_SIZE_SYMBOL
        | UNKNOWN_SYMBOL
        | UNTIL_SYMBOL
        | UPGRADE_SYMBOL
        | USER_SYMBOL
        | USE_FRM_SYMBOL
        | VALIDATION_SYMBOL
        | VALUE_SYMBOL
        | VARIABLES_SYMBOL
        | VCPU_SYMBOL
        | VIEW_SYMBOL
        | VISIBLE_SYMBOL
        | WAIT_SYMBOL
        | WARNINGS_SYMBOL
        | WEEK_SYMBOL
        | WEIGHT_STRING_SYMBOL
        | WITHOUT_SYMBOL
        | WORK_SYMBOL
        | WRAPPER_SYMBOL
        | X509_SYMBOL
        | XID_SYMBOL
        | XML_SYMBOL
        | YEAR_SYMBOL
    )
    | {status.serverVersion >= 80019}? (
        ARRAY_SYMBOL
        | FAILED_LOGIN_ATTEMPTS_SYMBOL
        | MASTER_COMPRESSION_ALGORITHM_SYMBOL
        | MASTER_TLS_CIPHERSUITES_SYMBOL
        | MASTER_ZSTD_COMPRESSION_LEVEL_SYMBOL
        | MEMBER_SYMBOL
        | OFF_SYMBOL
        | PASSWORD_LOCK_TIME_SYMBOL
        | PRIVILEGE_CHECKS_USER_SYMBOL
        | RANDOM_SYMBOL
        | REQUIRE_ROW_FORMAT_SYMBOL
        | REQUIRE_TABLE_PRIMARY_KEY_CHECK_SYMBOL
        | STREAM_SYMBOL
        | TIMESTAMP_SYMBOL
        | TIME_SYMBOL
    )
;

// Non-reserved keywords that we allow for unquoted role names:
//
//  Not allowed:
//
//    ident_keywords_ambiguous_1_roles_and_labels
//    ident_keywords_ambiguous_3_roles
roleKeyword:
    {status.serverVersion < 80017}? (roleOrLabelKeyword | roleOrIdentifierKeyword)
    | (
        identifierKeywordsUnambiguous
        | identifierKeywordsAmbiguous2Labels
        | identifierKeywordsAmbiguous4SystemVariables
    )
;

// Non-reserved words allowed for unquoted unprefixed variable names and
// unquoted variable prefixes in the left side of assignments in SET statements:
//
// Not allowed:
//
//   ident_keywords_ambiguous_4_system_variables
lValueKeyword:
    identifierKeywordsUnambiguous
    | identifierKeywordsAmbiguous1RolesAndLabels
    | identifierKeywordsAmbiguous2Labels
    | identifierKeywordsAmbiguous3Roles
;

// These non-reserved keywords cannot be used as unquoted unprefixed
// variable names and unquoted variable prefixes in the left side of
// assignments in SET statements:
identifierKeywordsAmbiguous4SystemVariables:
    GLOBAL_SYMBOL
    | LOCAL_SYMBOL
    | PERSIST_SYMBOL
    | PERSIST_ONLY_SYMBOL
    | SESSION_SYMBOL
;

// $antlr-the_format groupedAlignments off

// These are the non-reserved keywords which may be used for roles or idents.
// Keywords defined only for specific server versions are handled at lexer level and so cannot match this rule
// if the current server version doesn't allow them. Hence we don't need predicates here for them.
roleOrIdentifierKeyword:
    (
        ACCOUNT_SYMBOL                  // Conditionally set in the lexer.
        | ASCII_SYMBOL
        | ALWAYS_SYMBOL                 // Conditionally set in the lexer.
        | BACKUP_SYMBOL
        | BEGIN_SYMBOL
        | BYTE_SYMBOL
        | CACHE_SYMBOL
        | CHARSET_SYMBOL
        | CHECKSUM_SYMBOL
        | CLONE_SYMBOL                  // Conditionally set in the lexer.
        | CLOSE_SYMBOL
        | COMMENT_SYMBOL
        | COMMIT_SYMBOL
        | CONTAINS_SYMBOL
        | DEALLOCATE_SYMBOL
        | DO_SYMBOL
        | END_SYMBOL
        | FLUSH_SYMBOL
        | FOLLOWS_SYMBOL
        | FORMAT_SYMBOL
        | GROUP_REPLICATION_SYMBOL      // Conditionally set in the lexer.
        | HANDLER_SYMBOL
        | HELP_SYMBOL
        | HOST_SYMBOL
        | INSTALL_SYMBOL
        | INVISIBLE_SYMBOL              // Conditionally set in the lexer.
        | LANGUAGE_SYMBOL
        | NO_SYMBOL
        | OPEN_SYMBOL
        | OPTIONS_SYMBOL
        | OWNER_SYMBOL
        | PARSER_SYMBOL
        | PARTITION_SYMBOL
        | PORT_SYMBOL
        | PRECEDES_SYMBOL
        | PREPARE_SYMBOL
        | REMOVE_SYMBOL
        | REPAIR_SYMBOL
        | RESET_SYMBOL
        | RESTORE_SYMBOL
        | ROLE_SYMBOL                   // Conditionally set in the lexer.
        | ROLLBACK_SYMBOL
        | SAVEPOINT_SYMBOL
        | SECONDARY_SYMBOL              // Conditionally set in the lexer.
        | SECONDARY_ENGINE_SYMBOL       // Conditionally set in the lexer.
        | SECONDARY_LOAD_SYMBOL         // Conditionally set in the lexer.
        | SECONDARY_UNLOAD_SYMBOL       // Conditionally set in the lexer.
        | SECURITY_SYMBOL
        | SERVER_SYMBOL
        | SIGNED_SYMBOL
        | SOCKET_SYMBOL
        | SLAVE_SYMBOL
        | SONAME_SYMBOL
        | START_SYMBOL
        | STOP_SYMBOL
        | TRUNCATE_SYMBOL
        | UNICODE_SYMBOL
        | UNINSTALL_SYMBOL
        | UPGRADE_SYMBOL
        | VISIBLE_SYMBOL                // Conditionally set in the lexer.
        | WRAPPER_SYMBOL
        | XA_SYMBOL
    )
    // Rules that entered or left this rule in specific versions.
    | {status.serverVersion >= 50709}? SHUTDOWN_SYMBOL
    | {status.serverVersion >= 80000}? IMPORT_SYMBOL
;

roleOrLabelKeyword:
    (
        ACTION_SYMBOL
        | ACTIVE_SYMBOL                 // Conditionally set in the lexer.
        | ADDDATE_SYMBOL
        | AFTER_SYMBOL
        | AGAINST_SYMBOL
        | AGGREGATE_SYMBOL
        | ALGORITHM_SYMBOL
        | ANALYSE_SYMBOL                // Conditionally set in the lexer.
        | ANY_SYMBOL
        | AT_SYMBOL
        | AUTHORS_SYMBOL                // Conditionally set in the lexer.
        | AUTO_INCREMENT_SYMBOL
        | AUTOEXTEND_SIZE_SYMBOL
        | AVG_ROW_LENGTH_SYMBOL
        | AVG_SYMBOL
        | BINLOG_SYMBOL
        | BIT_SYMBOL
        | BLOCK_SYMBOL
        | BOOL_SYMBOL
        | BOOLEAN_SYMBOL
        | BTREE_SYMBOL
        | BUCKETS_SYMBOL                // Conditionally set in the lexer.
        | CASCADED_SYMBOL
        | CATALOG_NAME_SYMBOL
        | CHAIN_SYMBOL
        | CHANGED_SYMBOL
        | CHANNEL_SYMBOL                // Conditionally set in the lexer.
        | CIPHER_SYMBOL
        | CLIENT_SYMBOL
        | CLASS_ORIGIN_SYMBOL
        | COALESCE_SYMBOL
        | CODE_SYMBOL
        | COLLATION_SYMBOL
        | COLUMN_NAME_SYMBOL
        | COLUMN_FORMAT_SYMBOL
        | COLUMNS_SYMBOL
        | COMMITTED_SYMBOL
        | COMPACT_SYMBOL
        | COMPLETION_SYMBOL
        | COMPONENT_SYMBOL
        | COMPRESSED_SYMBOL             // Conditionally set in the lexer.
        | COMPRESSION_SYMBOL            // Conditionally set in the lexer.
        | CONCURRENT_SYMBOL
        | CONNECTION_SYMBOL
        | CONSISTENT_SYMBOL
        | CONSTRAINT_CATALOG_SYMBOL
        | CONSTRAINT_SCHEMA_SYMBOL
        | CONSTRAINT_NAME_SYMBOL
        | CONTEXT_SYMBOL
        | CONTRIBUTORS_SYMBOL           // Conditionally set in the lexer.
        | CPU_SYMBOL
        /*
          Although a reserved keyword in SQL:2003 (and :2008),
          not reserved in MySQL per WL#2111 specification.
        */
        | CURRENT_SYMBOL
        | CURSOR_NAME_SYMBOL
        | DATA_SYMBOL
        | DATAFILE_SYMBOL
        | DATETIME_SYMBOL
        | DATE_SYMBOL
        | DAY_SYMBOL
        | DEFAULT_AUTH_SYMBOL
        | DEFINER_SYMBOL
        | DELAY_KEY_WRITE_SYMBOL
        | DES_KEY_FILE_SYMBOL           // Conditionally set in the lexer.
        | DESCRIPTION_SYMBOL            // Conditionally set in the lexer.
        | DIAGNOSTICS_SYMBOL
        | DIRECTORY_SYMBOL
        | DISABLE_SYMBOL
        | DISCARD_SYMBOL
        | DISK_SYMBOL
        | DUMPFILE_SYMBOL
        | DUPLICATE_SYMBOL
        | DYNAMIC_SYMBOL
        | ENCRYPTION_SYMBOL             // Conditionally set in the lexer.
        | ENDS_SYMBOL
        | ENUM_SYMBOL
        | ENGINE_SYMBOL
        | ENGINES_SYMBOL
        | ERROR_SYMBOL
        | ERRORS_SYMBOL
        | ESCAPE_SYMBOL
        | EVENTS_SYMBOL
        | EVERY_SYMBOL
        | EXCLUDE_SYMBOL                // Conditionally set in the lexer.
        | EXPANSION_SYMBOL
        | EXPORT_SYMBOL
        | EXTENDED_SYMBOL
        | EXTENT_SIZE_SYMBOL
        | FAULTS_SYMBOL
        | FAST_SYMBOL
        | FOLLOWING_SYMBOL              // Conditionally set in the lexer.
        | FOUND_SYMBOL
        | ENABLE_SYMBOL
        | FULL_SYMBOL
        | FILE_BLOCK_SIZE_SYMBOL        // Conditionally set in the lexer.
        | FILTER_SYMBOL
        | FIRST_SYMBOL
        | FIXED_SYMBOL
        | GENERAL_SYMBOL
        | GEOMETRY_SYMBOL
        | GEOMETRYCOLLECTION_SYMBOL
        | GET_FORMAT_SYMBOL
        | GRANTS_SYMBOL
        | GLOBAL_SYMBOL
        | HASH_SYMBOL
        | HISTOGRAM_SYMBOL              // Conditionally set in the lexer.
        | HISTORY_SYMBOL                // Conditionally set in the lexer.
        | HOSTS_SYMBOL
        | HOUR_SYMBOL
        | IDENTIFIED_SYMBOL
        | IGNORE_SERVER_IDS_SYMBOL
        | INVOKER_SYMBOL
        | INDEXES_SYMBOL
        | INITIAL_SIZE_SYMBOL
        | INSTANCE_SYMBOL               // Conditionally deprecated in the lexer.
        | INACTIVE_SYMBOL               // Conditionally set in the lexer.
        | IO_SYMBOL
        | IPC_SYMBOL
        | ISOLATION_SYMBOL
        | ISSUER_SYMBOL
        | INSERT_METHOD_SYMBOL
        | JSON_SYMBOL                   // Conditionally set in the lexer.
        | KEY_BLOCK_SIZE_SYMBOL
        | LAST_SYMBOL
        | LEAVES_SYMBOL
        | LESS_SYMBOL
        | LEVEL_SYMBOL
        | LINESTRING_SYMBOL
        | LIST_SYMBOL
        | LOCAL_SYMBOL
        | LOCKED_SYMBOL                 // Conditionally set in the lexer.
        | LOCKS_SYMBOL
        | LOGFILE_SYMBOL
        | LOGS_SYMBOL
        | MAX_ROWS_SYMBOL
        | MASTER_SYMBOL
        | MASTER_HEARTBEAT_PERIOD_SYMBOL
        | MASTER_HOST_SYMBOL
        | MASTER_PORT_SYMBOL
        | MASTER_LOG_FILE_SYMBOL
        | MASTER_LOG_POS_SYMBOL
        | MASTER_USER_SYMBOL
        | MASTER_PASSWORD_SYMBOL
        | MASTER_PUBLIC_KEY_PATH_SYMBOL // Conditionally set in the lexer.
        | MASTER_SERVER_ID_SYMBOL
        | MASTER_CONNECT_RETRY_SYMBOL
        | MASTER_RETRY_COUNT_SYMBOL
        | MASTER_DELAY_SYMBOL
        | MASTER_SSL_SYMBOL
        | MASTER_SSL_CA_SYMBOL
        | MASTER_SSL_CAPATH_SYMBOL
        | MASTER_TLS_VERSION_SYMBOL     // Conditionally deprecated in the lexer.
        | MASTER_SSL_CERT_SYMBOL
        | MASTER_SSL_CIPHER_SYMBOL
        | MASTER_SSL_CRL_SYMBOL
        | MASTER_SSL_CRLPATH_SYMBOL
        | MASTER_SSL_KEY_SYMBOL
        | MASTER_AUTO_POSITION_SYMBOL
        | MAX_CONNECTIONS_PER_HOUR_SYMBOL
        | MAX_QUERIES_PER_HOUR_SYMBOL
        | MAX_STATEMENT_TIME_SYMBOL     // Conditionally deprecated in the lexer.
        | MAX_SIZE_SYMBOL
        | MAX_UPDATES_PER_HOUR_SYMBOL
        | MAX_USER_CONNECTIONS_SYMBOL
        | MEDIUM_SYMBOL
        | MEMORY_SYMBOL
        | MERGE_SYMBOL
        | MESSAGE_TEXT_SYMBOL
        | MICROSECOND_SYMBOL
        | MIGRATE_SYMBOL
        | MINUTE_SYMBOL
        | MIN_ROWS_SYMBOL
        | MODIFY_SYMBOL
        | MODE_SYMBOL
        | MONTH_SYMBOL
        | MULTILINESTRING_SYMBOL
        | MULTIPOINT_SYMBOL
        | MULTIPOLYGON_SYMBOL
        | MUTEX_SYMBOL
        | MYSQL_ERRNO_SYMBOL
        | NAME_SYMBOL
        | NAMES_SYMBOL
        | NATIONAL_SYMBOL
        | NCHAR_SYMBOL
        | NDBCLUSTER_SYMBOL
        | NESTED_SYMBOL                 // Conditionally set in the lexer.
        | NEVER_SYMBOL
        | NEXT_SYMBOL
        | NEW_SYMBOL
        | NO_WAIT_SYMBOL
        | NODEGROUP_SYMBOL
        | NULLS_SYMBOL                  // Conditionally set in the lexer.
        | NOWAIT_SYMBOL                 // Conditionally set in the lexer.
        | NUMBER_SYMBOL
        | NVARCHAR_SYMBOL
        | OFFSET_SYMBOL
        | OLD_SYMBOL                    // Conditionally set in the lexer.
        | OLD_PASSWORD_SYMBOL           // Conditionally set in the lexer.
        | ONE_SYMBOL
        | OPTIONAL_SYMBOL               // Conditionally set in the lexer.
        | ORDINALITY_SYMBOL             // Conditionally set in the lexer.
        | ORGANIZATION_SYMBOL           // Conditionally set in the lexer.
        | OTHERS_SYMBOL                 // Conditionally set in the lexer.
        | PACK_KEYS_SYMBOL
        | PAGE_SYMBOL
        | PARTIAL_SYMBOL
        | PARTITIONING_SYMBOL
        | PARTITIONS_SYMBOL
        | PASSWORD_SYMBOL
        | PATH_SYMBOL                   // Conditionally set in the lexer.
        | PHASE_SYMBOL
        | PLUGIN_DIR_SYMBOL
        | PLUGIN_SYMBOL
        | PLUGINS_SYMBOL
        | POINT_SYMBOL
        | POLYGON_SYMBOL
        | PRECEDING_SYMBOL              // Conditionally set in the lexer.
        | PRESERVE_SYMBOL
        | PREV_SYMBOL
        | THREAD_PRIORITY_SYMBOL        // Conditionally set in the lexer.
        | PRIVILEGES_SYMBOL
        | PROCESSLIST_SYMBOL
        | PROFILE_SYMBOL
        | PROFILES_SYMBOL
        | QUARTER_SYMBOL
        | QUERY_SYMBOL
        | QUICK_SYMBOL
        | READ_ONLY_SYMBOL
        | REBUILD_SYMBOL
        | RECOVER_SYMBOL
        | REDO_BUFFER_SIZE_SYMBOL
        | REDOFILE_SYMBOL               // Conditionally set in the lexer.
        | REDUNDANT_SYMBOL
        | RELAY_SYMBOL
        | RELAYLOG_SYMBOL
        | RELAY_LOG_FILE_SYMBOL
        | RELAY_LOG_POS_SYMBOL
        | RELAY_THREAD_SYMBOL
        | REMOTE_SYMBOL                 // Conditionally set in the lexer.
        | REORGANIZE_SYMBOL
        | REPEATABLE_SYMBOL
        | REPLICATE_DO_DB_SYMBOL
        | REPLICATE_IGNORE_DB_SYMBOL
        | REPLICATE_DO_TABLE_SYMBOL
        | REPLICATE_IGNORE_TABLE_SYMBOL
        | REPLICATE_WILD_DO_TABLE_SYMBOL
        | REPLICATE_WILD_IGNORE_TABLE_SYMBOL
        | REPLICATE_REWRITE_DB_SYMBOL
        | USER_RESOURCES_SYMBOL         // Placed like in the server grammar where it is named just RESOURCES.
        | RESPECT_SYMBOL                // Conditionally set in the lexer.
        | RESUME_SYMBOL
        | RETAIN_SYMBOL                 // Conditionally set in the lexer.
        | RETURNED_SQLSTATE_SYMBOL
        | RETURNED_GBASE_ERRNO_SYMBOL   // Gbase ERRNO
        | RETURNS_SYMBOL
        | REUSE_SYMBOL                  // Conditionally set in the lexer.
        | REVERSE_SYMBOL
        | ROLLUP_SYMBOL
        | ROTATE_SYMBOL                 // Conditionally deprecated in the lexer.
        | ROUTINE_SYMBOL
        | ROW_COUNT_SYMBOL
        | ROW_FORMAT_SYMBOL
        | RTREE_SYMBOL
        | SCHEDULE_SYMBOL
        | SCHEMA_NAME_SYMBOL
        | SECOND_SYMBOL
        | SERIAL_SYMBOL
        | SERIALIZABLE_SYMBOL
        | SESSION_SYMBOL
        | SHARE_SYMBOL
        | SIMPLE_SYMBOL
        | SKIP_SYMBOL                   // Conditionally set in the lexer.
        | SLOW_SYMBOL
        | SNAPSHOT_SYMBOL
        | SOUNDS_SYMBOL
        | SOURCE_SYMBOL
        | SQL_AFTER_GTIDS_SYMBOL
        | SQL_AFTER_MTS_GAPS_SYMBOL
        | SQL_BEFORE_GTIDS_SYMBOL
        | SQL_CACHE_SYMBOL              // Conditionally deprecated in the lexer.
        | SQL_BUFFER_RESULT_SYMBOL
        | SQL_NO_CACHE_SYMBOL
        | SQL_THREAD_SYMBOL
        | SRID_SYMBOL                   // Conditionally set in the lexer.
        | STACKED_SYMBOL
        | STARTS_SYMBOL
        | STATS_AUTO_RECALC_SYMBOL
        | STATS_PERSISTENT_SYMBOL
        | STATS_SAMPLE_PAGES_SYMBOL
        | STATUS_SYMBOL
        | STORAGE_SYMBOL
        | STRING_SYMBOL
        | SUBCLASS_ORIGIN_SYMBOL
        | SUBDATE_SYMBOL
        | SUBJECT_SYMBOL
        | SUBPARTITION_SYMBOL
        | SUBPARTITIONS_SYMBOL
        | SUPER_SYMBOL
        | SUSPEND_SYMBOL
        | SWAPS_SYMBOL
        | SWITCHES_SYMBOL
        | TABLE_NAME_SYMBOL
        | TABLES_SYMBOL
        | TABLE_CHECKSUM_SYMBOL
        | TABLESPACE_SYMBOL
        | TEMPORARY_SYMBOL
        | TEMPTABLE_SYMBOL
        | TEXT_SYMBOL
        | THAN_SYMBOL
        | TIES_SYMBOL                   // Conditionally set in the lexer.
        | TRANSACTION_SYMBOL
        | TRIGGERS_SYMBOL
        | TIMESTAMP_SYMBOL
        | TIMESTAMP_ADD_SYMBOL
        | TIMESTAMP_DIFF_SYMBOL
        | TIME_SYMBOL
        | TYPES_SYMBOL
        | TYPE_SYMBOL
        | UDF_RETURNS_SYMBOL
        | UNBOUNDED_SYMBOL              // Conditionally set in the lexer.
        | UNCOMMITTED_SYMBOL
        | UNDEFINED_SYMBOL
        | UNDO_BUFFER_SIZE_SYMBOL
        | UNDOFILE_SYMBOL
        | UNKNOWN_SYMBOL
        | UNTIL_SYMBOL
        | USER_SYMBOL
        | USE_FRM_SYMBOL
        | VARIABLES_SYMBOL
        | VCPU_SYMBOL                   // Conditionally set in the lexer.
        | VIEW_SYMBOL
        | VALUE_SYMBOL
        | WARNINGS_SYMBOL
        | WAIT_SYMBOL
        | WEEK_SYMBOL
        | WORK_SYMBOL
        | WEIGHT_STRING_SYMBOL
        | X509_SYMBOL
        | XID_SYMBOL
        | XML_SYMBOL
        | YEAR_SYMBOL
    )
    // Tokens that entered or left this rule in specific versions and are not automatically
    // handled in the lexer.
    | {status.serverVersion < 50709}? SHUTDOWN_SYMBOL
    | {status.serverVersion < 80000}? (
        CUBE_SYMBOL
        | IMPORT_SYMBOL
        | FUNCTION_SYMBOL
        | ROWS_SYMBOL
        | ROW_SYMBOL
    )
    | {status.serverVersion >= 80000}? (
        EXCHANGE_SYMBOL
        | EXPIRE_SYMBOL
        | ONLY_SYMBOL
        | SUPER_SYMBOL
        | VALIDATION_SYMBOL
        | WITHOUT_SYMBOL
    )
    | {status.serverVersion >= 80014}? ADMIN_SYMBOL
;
