parser grammar GBaseParser_alter;

options {
//    superClass = MySQLBaseRecognizer;
    tokenVocab = GBaseLexer;
    exportMacro = PARSERS_PUBLIC_TYPE;
}


//----------------- DDL statements -------------------------------------------------------------------------------------

alterStatement:
    ALTER_SYMBOL (
        alterTable
        | alterDatabase
        | PROCEDURE_SYMBOL procedureRef routineAlterOptions?
        | FUNCTION_SYMBOL functionRef routineAlterOptions?
        | alterView
        | alterEvent
        | alterTablespace
        | {status.serverVersion >= 80014}? alterUndoTablespace
        | alterLogfileGroup
        | alterServer
        // ALTER USER is part of the user management rule.
        | {status.serverVersion >= 50713}? INSTANCE_SYMBOL ROTATE_SYMBOL textOrIdentifier MASTER_SYMBOL KEY_SYMBOL
    )
;

alterDatabase:
    DATABASE_SYMBOL schemaRef (
        createDatabaseOption+
        | {status.serverVersion < 80000}? UPGRADE_SYMBOL DATA_SYMBOL DIRECTORY_SYMBOL NAME_SYMBOL
    )
;

alterEvent:
    definerClause? EVENT_SYMBOL eventRef (ON_SYMBOL SCHEDULE_SYMBOL schedule)? (
        ON_SYMBOL COMPLETION_SYMBOL NOT_SYMBOL? PRESERVE_SYMBOL
    )? (RENAME_SYMBOL TO_SYMBOL identifier)? (
        ENABLE_SYMBOL
        | DISABLE_SYMBOL (ON_SYMBOL SLAVE_SYMBOL)?
    )? (COMMENT_SYMBOL textLiteral)? (DO_SYMBOL compoundStatement)?
;

alterLogfileGroup:
    LOGFILE_SYMBOL GROUP_SYMBOL logfileGroupRef ADD_SYMBOL UNDOFILE_SYMBOL textLiteral alterLogfileGroupOptions?
;

alterLogfileGroupOptions:
    alterLogfileGroupOption (COMMA_SYMBOL? alterLogfileGroupOption)*
;

alterLogfileGroupOption:
    tsOptionInitialSize
    | tsOptionEngine
    | tsOptionWait
;

alterServer:
    SERVER_SYMBOL serverRef serverOptions
;

alterTable:
    onlineOption? ({status.serverVersion < 50700}? IGNORE_SYMBOL)? TABLE_SYMBOL tableRef alterTableActions?
;

alterTableActions:
    alterCommandList (partitionClause | removePartitioning)?
    | partitionClause
    | removePartitioning
    | (alterCommandsModifierList COMMA_SYMBOL)? standaloneAlterCommands
;

alterCommandList:
    alterCommandsModifierList
    | (alterCommandsModifierList COMMA_SYMBOL)? alterList
;

alterCommandsModifierList:
    alterCommandsModifier (COMMA_SYMBOL alterCommandsModifier)*
;

standaloneAlterCommands:
    DISCARD_SYMBOL TABLESPACE_SYMBOL
    | IMPORT_SYMBOL TABLESPACE_SYMBOL
    | alterPartition
    | {status.serverVersion >= 80014}? (SECONDARY_LOAD_SYMBOL | SECONDARY_UNLOAD_SYMBOL)
;

alterPartition:
    ADD_SYMBOL PARTITION_SYMBOL noWriteToBinLog? (
        partitionDefinitions
        | PARTITIONS_SYMBOL real_ulong_number
    )
    | DROP_SYMBOL PARTITION_SYMBOL identifierList
    | REBUILD_SYMBOL PARTITION_SYMBOL noWriteToBinLog? allOrPartitionNameList

    // yes, twice "no write to bin log".
    | OPTIMIZE_SYMBOL PARTITION_SYMBOL noWriteToBinLog? allOrPartitionNameList noWriteToBinLog?
    | ANALYZE_SYMBOL PARTITION_SYMBOL noWriteToBinLog? allOrPartitionNameList
    | CHECK_SYMBOL PARTITION_SYMBOL allOrPartitionNameList checkOption*
    | REPAIR_SYMBOL PARTITION_SYMBOL noWriteToBinLog? allOrPartitionNameList repairType*
    | COALESCE_SYMBOL PARTITION_SYMBOL noWriteToBinLog? real_ulong_number
    | TRUNCATE_SYMBOL PARTITION_SYMBOL allOrPartitionNameList
    | REORGANIZE_SYMBOL PARTITION_SYMBOL noWriteToBinLog? (
        identifierList INTO_SYMBOL partitionDefinitions
    )?
    | EXCHANGE_SYMBOL PARTITION_SYMBOL identifier WITH_SYMBOL TABLE_SYMBOL tableRef withValidation?
    | {status.serverVersion >= 50704}? DISCARD_SYMBOL PARTITION_SYMBOL allOrPartitionNameList TABLESPACE_SYMBOL
    | {status.serverVersion >= 50704}? IMPORT_SYMBOL PARTITION_SYMBOL allOrPartitionNameList TABLESPACE_SYMBOL
;

alterList:
    (alterListItem | createTableOptionsSpaceSeparated) (
        COMMA_SYMBOL (
            alterListItem
            | alterCommandsModifier
            | createTableOptionsSpaceSeparated
        )
    )*
;

alterCommandsModifier:
    alterAlgorithmOption
    | alterLockOption
    | withValidation
;

alterListItem:
    ADD_SYMBOL COLUMN_SYMBOL? (
        identifier fieldDefinition checkOrReferences? place?
        | OPEN_PAR_SYMBOL tableElementList CLOSE_PAR_SYMBOL
    )
    | ADD_SYMBOL tableConstraintDef
    | CHANGE_SYMBOL COLUMN_SYMBOL? columnInternalRef identifier fieldDefinition place?
    | MODIFY_SYMBOL COLUMN_SYMBOL? columnInternalRef fieldDefinition place?
    | DROP_SYMBOL (
        COLUMN_SYMBOL? columnInternalRef restrict?
        | FOREIGN_SYMBOL KEY_SYMBOL (
            // This part is no longer optional starting with 5.7.
            {status.serverVersion >= 50700}? columnInternalRef
            | {status.serverVersion < 50700}? columnInternalRef?
        )
        | PRIMARY_SYMBOL KEY_SYMBOL
        | keyOrIndex indexRef
        | {status.serverVersion >= 80017}? CHECK_SYMBOL identifier
        | {status.serverVersion >= 80019}? CONSTRAINT_SYMBOL identifier
    )
    | DISABLE_SYMBOL KEYS_SYMBOL
    | ENABLE_SYMBOL KEYS_SYMBOL
    | ALTER_SYMBOL COLUMN_SYMBOL? columnInternalRef (
        SET_SYMBOL DEFAULT_SYMBOL (
            {status.serverVersion >= 80014}? exprWithParentheses
            | signedLiteral
        )
        | DROP_SYMBOL DEFAULT_SYMBOL
    )
    | {status.serverVersion >= 80000}? ALTER_SYMBOL INDEX_SYMBOL indexRef visibility
    | {status.serverVersion >= 80017}? ALTER_SYMBOL CHECK_SYMBOL identifier constraintEnforcement
    | {status.serverVersion >= 80019}? ALTER_SYMBOL CONSTRAINT_SYMBOL identifier constraintEnforcement
    | {status.serverVersion >= 80000}? RENAME_SYMBOL COLUMN_SYMBOL columnInternalRef TO_SYMBOL identifier
    | RENAME_SYMBOL (TO_SYMBOL | AS_SYMBOL)? tableName
    | {status.serverVersion >= 50700}? RENAME_SYMBOL keyOrIndex indexRef TO_SYMBOL indexName
    | CONVERT_SYMBOL TO_SYMBOL charset (
        {status.serverVersion >= 80014}? DEFAULT_SYMBOL
        | charsetName
    ) collate?
    | FORCE_SYMBOL
    | ORDER_SYMBOL BY_SYMBOL alterOrderList
    | {status.serverVersion >= 50708 and status.serverVersion < 80000}? UPGRADE_SYMBOL PARTITIONING_SYMBOL
;

place:
    AFTER_SYMBOL identifier
    | FIRST_SYMBOL
;

restrict:
    RESTRICT_SYMBOL
    | CASCADE_SYMBOL
;

alterOrderList:
    identifier direction? (COMMA_SYMBOL identifier direction?)*
;

alterAlgorithmOption:
    ALGORITHM_SYMBOL EQUAL_OPERATOR? (DEFAULT_SYMBOL | identifier)
;

alterLockOption:
    LOCK_SYMBOL EQUAL_OPERATOR? (DEFAULT_SYMBOL | identifier)
;

indexLockAndAlgorithm:
    alterAlgorithmOption alterLockOption?
    | alterLockOption alterAlgorithmOption?
;

withValidation:
    {status.serverVersion >= 50706}? (WITH_SYMBOL | WITHOUT_SYMBOL) VALIDATION_SYMBOL
;

removePartitioning:
    REMOVE_SYMBOL PARTITIONING_SYMBOL
;

allOrPartitionNameList:
    ALL_SYMBOL
    | identifierList
;

alterTablespace:
    TABLESPACE_SYMBOL tablespaceRef (
        (ADD_SYMBOL | DROP_SYMBOL) DATAFILE_SYMBOL textLiteral alterTablespaceOptions?
        | {status.serverVersion < 80000}? (
            | CHANGE_SYMBOL DATAFILE_SYMBOL textLiteral (
                changeTablespaceOption (COMMA_SYMBOL? changeTablespaceOption)*
            )?
            | (READ_ONLY_SYMBOL | READ_WRITE_SYMBOL)
            | NOT_SYMBOL ACCESSIBLE_SYMBOL
        )
        | RENAME_SYMBOL TO_SYMBOL identifier
        | {status.serverVersion >= 80014}? alterTablespaceOptions
    )
;

alterUndoTablespace:
    UNDO_SYMBOL TABLESPACE_SYMBOL tablespaceRef SET_SYMBOL (
        ACTIVE_SYMBOL
        | INACTIVE_SYMBOL
    ) undoTableSpaceOptions?
;

undoTableSpaceOptions:
    undoTableSpaceOption (COMMA_SYMBOL? undoTableSpaceOption)*
;

undoTableSpaceOption:
    tsOptionEngine
;

alterTablespaceOptions:
    alterTablespaceOption (COMMA_SYMBOL? alterTablespaceOption)*
;

alterTablespaceOption:
    INITIAL_SIZE_SYMBOL EQUAL_OPERATOR? sizeNumber
    | tsOptionAutoextendSize
    | tsOptionMaxSize
    | tsOptionEngine
    | tsOptionWait
    | tsOptionEncryption
;

changeTablespaceOption:
    INITIAL_SIZE_SYMBOL EQUAL_OPERATOR? sizeNumber
    | tsOptionAutoextendSize
    | tsOptionMaxSize
;

alterView:
    viewAlgorithm? definerClause? viewSuid? VIEW_SYMBOL viewRef viewTail
;

// This is not the full view_tail from sql_yacc.yy as we have either a view name or a view reference,
// depending on whether we come from createView or alterView. Everything until this difference is duplicated in those rules.
viewTail:
    columnInternalRefList? AS_SYMBOL viewSelect
;

viewSelect:
    queryExpressionOrParens viewCheckOption?
;

viewCheckOption:
    WITH_SYMBOL (CASCADED_SYMBOL | LOCAL_SYMBOL)? CHECK_SYMBOL OPTION_SYMBOL
;

//----------------------------------------------------------------------------------------------------------------------