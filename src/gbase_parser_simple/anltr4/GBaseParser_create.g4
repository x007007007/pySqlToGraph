parser grammar GBaseParser_create;

options {
//    superClass = MySQLBaseRecognizer;
    tokenVocab = GBaseLexer;
    exportMacro = PARSERS_PUBLIC_TYPE;
}

//----------------------------------------------------------------------------------------------------------------------

createStatement:
    CREATE_SYMBOL (
        createDatabase
        | createTable
        | createFunction
        | createProcedure
        | createUdf
        | createLogfileGroup
        | createView
        | createTrigger
        | createIndex
        | createServer
        | createTablespace
        | createEvent
        | {status.serverVersion >= 80000}? createRole
        | {status.serverVersion >= 80011}? createSpatialReference
        | {status.serverVersion >= 80014}? createUndoTablespace
    )
;

createDatabase:
    DATABASE_SYMBOL ifNotExists? schemaName createDatabaseOption*
;

createDatabaseOption:
    defaultCharset
    | defaultCollation
    | {status.serverVersion >= 80016}? defaultEncryption
;

createTable:
    TEMPORARY_SYMBOL? TABLE_SYMBOL ifNotExists? tableName (
        (OPEN_PAR_SYMBOL tableElementList CLOSE_PAR_SYMBOL)? createTableOptions? partitionClause? duplicateAsQueryExpression?
        | LIKE_SYMBOL tableRef
        | OPEN_PAR_SYMBOL LIKE_SYMBOL tableRef CLOSE_PAR_SYMBOL
    )
;

tableElementList:
    tableElement (COMMA_SYMBOL tableElement)*
;

tableElement:
    columnDefinition
    | tableConstraintDef
;

duplicateAsQueryExpression: (REPLACE_SYMBOL | IGNORE_SYMBOL)? AS_SYMBOL? queryExpressionOrParens
;

queryExpressionOrParens:
    queryExpression
    | queryExpressionParens
;

createRoutine: // Rule for external use only.
    CREATE_SYMBOL (createProcedure | createFunction | createUdf) SEMICOLON_SYMBOL? EOF
;

createProcedure:
    definerClause? PROCEDURE_SYMBOL procedureName OPEN_PAR_SYMBOL (
        procedureParameter (COMMA_SYMBOL procedureParameter)*
    )? CLOSE_PAR_SYMBOL routineCreateOption* compoundStatement
;

createFunction:
    definerClause? FUNCTION_SYMBOL functionName OPEN_PAR_SYMBOL (
        functionParameter (COMMA_SYMBOL functionParameter)*
    )? CLOSE_PAR_SYMBOL RETURNS_SYMBOL typeWithOptCollate routineCreateOption* compoundStatement
;

createUdf:
    AGGREGATE_SYMBOL? FUNCTION_SYMBOL udfName RETURNS_SYMBOL the_type = (
        STRING_SYMBOL
        | INT_SYMBOL
        | REAL_SYMBOL
        | DECIMAL_SYMBOL
    ) SONAME_SYMBOL textLiteral
;

routineCreateOption:
    routineOption
    | NOT_SYMBOL? DETERMINISTIC_SYMBOL
;

routineAlterOptions:
    routineCreateOption+
;

routineOption:
    option = COMMENT_SYMBOL textLiteral
    | option = LANGUAGE_SYMBOL SQL_SYMBOL
    | option = NO_SYMBOL SQL_SYMBOL
    | option = CONTAINS_SYMBOL SQL_SYMBOL
    | option = READS_SYMBOL SQL_SYMBOL DATA_SYMBOL
    | option = MODIFIES_SYMBOL SQL_SYMBOL DATA_SYMBOL
    | option = SQL_SYMBOL SECURITY_SYMBOL security = (
        DEFINER_SYMBOL
        | INVOKER_SYMBOL
    )
;

createIndex:
    onlineOption? (
        UNIQUE_SYMBOL? the_type = INDEX_SYMBOL (
            {status.serverVersion >= 80014}? indexName indexTypeClause?
            | indexNameAndType?
        ) createIndexTarget indexOption*
        | the_type = FULLTEXT_SYMBOL INDEX_SYMBOL indexName createIndexTarget fulltextIndexOption*
        | the_type = SPATIAL_SYMBOL INDEX_SYMBOL indexName createIndexTarget spatialIndexOption*
    ) indexLockAndAlgorithm?
;

/*
  The syntax for defining an index is:

    ... INDEX [index_name] [USING|TYPE] <index_type> ...

  The problem is that whereas USING is a reserved word, TYPE is not. We can
  still handle it if an index name is supplied, i.e.:

    ... INDEX the_type TYPE <index_type> ...

  here the index's name is unmbiguously 'the_type', but for this:

    ... INDEX TYPE <index_type> ...

  it's impossible to know what this actually mean - is 'the_type' the name or the
  the_type? For this reason we accept the TYPE syntax only if a name is supplied.
*/
indexNameAndType:
    indexName (USING_SYMBOL indexType)?
    | indexName TYPE_SYMBOL indexType
;

createIndexTarget:
    ON_SYMBOL tableRef keyListVariants
;

createLogfileGroup:
    LOGFILE_SYMBOL GROUP_SYMBOL logfileGroupName ADD_SYMBOL (
        UNDOFILE_SYMBOL
        | REDOFILE_SYMBOL // No longer used from 8.0 onwards. Taken out by lexer.
    ) textLiteral logfileGroupOptions?
;

logfileGroupOptions:
    logfileGroupOption (COMMA_SYMBOL? logfileGroupOption)*
;

logfileGroupOption:
    tsOptionInitialSize
    | tsOptionUndoRedoBufferSize
    | tsOptionNodegroup
    | tsOptionEngine
    | tsOptionWait
    | tsOptionComment
;

createServer:
    SERVER_SYMBOL serverName FOREIGN_SYMBOL DATA_SYMBOL WRAPPER_SYMBOL textOrIdentifier serverOptions
;

serverOptions:
    OPTIONS_SYMBOL OPEN_PAR_SYMBOL serverOption (COMMA_SYMBOL serverOption)* CLOSE_PAR_SYMBOL
;

// Options for CREATE/ALTER SERVER, used for the federated storage engine.
serverOption:
    option = HOST_SYMBOL textLiteral
    | option = DATABASE_SYMBOL textLiteral
    | option = USER_SYMBOL textLiteral
    | option = PASSWORD_SYMBOL textLiteral
    | option = SOCKET_SYMBOL textLiteral
    | option = OWNER_SYMBOL textLiteral
    | option = PORT_SYMBOL ulong_number
;

createTablespace:
    TABLESPACE_SYMBOL tablespaceName tsDataFileName (
        USE_SYMBOL LOGFILE_SYMBOL GROUP_SYMBOL logfileGroupRef
    )? tablespaceOptions?
;

createUndoTablespace:
    UNDO_SYMBOL TABLESPACE_SYMBOL tablespaceName ADD_SYMBOL tsDataFile undoTableSpaceOptions?
;

tsDataFileName:
    {status.serverVersion >= 80014}? (ADD_SYMBOL tsDataFile)?
    | ADD_SYMBOL tsDataFile
;

tsDataFile:
    DATAFILE_SYMBOL textLiteral
;

tablespaceOptions:
    tablespaceOption (COMMA_SYMBOL? tablespaceOption)*
;

tablespaceOption:
    tsOptionInitialSize
    | tsOptionAutoextendSize
    | tsOptionMaxSize
    | tsOptionExtentSize
    | tsOptionNodegroup
    | tsOptionEngine
    | tsOptionWait
    | tsOptionComment
    | {status.serverVersion >= 50707}? tsOptionFileblockSize
    | {status.serverVersion >= 80014}? tsOptionEncryption
;

tsOptionInitialSize:
    INITIAL_SIZE_SYMBOL EQUAL_OPERATOR? sizeNumber
;

tsOptionUndoRedoBufferSize:
    (UNDO_BUFFER_SIZE_SYMBOL | REDO_BUFFER_SIZE_SYMBOL) EQUAL_OPERATOR? sizeNumber
;

tsOptionAutoextendSize:
    AUTOEXTEND_SIZE_SYMBOL EQUAL_OPERATOR? sizeNumber
;

tsOptionMaxSize:
    MAX_SIZE_SYMBOL EQUAL_OPERATOR? sizeNumber
;

tsOptionExtentSize:
    EXTENT_SIZE_SYMBOL EQUAL_OPERATOR? sizeNumber
;

tsOptionNodegroup:
    NODEGROUP_SYMBOL EQUAL_OPERATOR? real_ulong_number
;

tsOptionEngine:
    STORAGE_SYMBOL? ENGINE_SYMBOL EQUAL_OPERATOR? engineRef
;

tsOptionWait: (WAIT_SYMBOL | NO_WAIT_SYMBOL)
;

tsOptionComment:
    COMMENT_SYMBOL EQUAL_OPERATOR? textLiteral
;

tsOptionFileblockSize:
    FILE_BLOCK_SIZE_SYMBOL EQUAL_OPERATOR? sizeNumber
;

tsOptionEncryption:
    ENCRYPTION_SYMBOL EQUAL_OPERATOR? textStringLiteral
;

createView:
    viewReplaceOrAlgorithm? definerClause? viewSuid? VIEW_SYMBOL viewName viewTail
;

viewReplaceOrAlgorithm:
    OR_SYMBOL REPLACE_SYMBOL viewAlgorithm?
    | viewAlgorithm
;

viewAlgorithm:
    ALGORITHM_SYMBOL EQUAL_OPERATOR algorithm = (
        UNDEFINED_SYMBOL
        | MERGE_SYMBOL
        | TEMPTABLE_SYMBOL
    )
;

viewSuid:
    SQL_SYMBOL SECURITY_SYMBOL (DEFINER_SYMBOL | INVOKER_SYMBOL)
;

createTrigger:
    definerClause? TRIGGER_SYMBOL triggerName timing = (BEFORE_SYMBOL | AFTER_SYMBOL) event = (
        INSERT_SYMBOL
        | UPDATE_SYMBOL
        | DELETE_SYMBOL
    ) ON_SYMBOL tableRef FOR_SYMBOL EACH_SYMBOL ROW_SYMBOL triggerFollowsPrecedesClause? compoundStatement
;

triggerFollowsPrecedesClause:
    {status.serverVersion >= 50700}? ordering = (FOLLOWS_SYMBOL | PRECEDES_SYMBOL) textOrIdentifier // not a trigger reference!
;

createEvent:
    definerClause? EVENT_SYMBOL ifNotExists? eventName ON_SYMBOL SCHEDULE_SYMBOL schedule (
        ON_SYMBOL COMPLETION_SYMBOL NOT_SYMBOL? PRESERVE_SYMBOL
    )? (ENABLE_SYMBOL | DISABLE_SYMBOL (ON_SYMBOL SLAVE_SYMBOL)?)? (
        COMMENT_SYMBOL textLiteral
    )? DO_SYMBOL compoundStatement
;

createRole:
    // The server grammar has a clear_privileges rule here, which is only used to clear internal state.
    ROLE_SYMBOL ifNotExists? roleList
;

createSpatialReference:
    OR_SYMBOL REPLACE_SYMBOL SPATIAL_SYMBOL REFERENCE_SYMBOL SYSTEM_SYMBOL real_ulonglong_number srsAttribute*
    | SPATIAL_SYMBOL REFERENCE_SYMBOL SYSTEM_SYMBOL ifNotExists? real_ulonglong_number srsAttribute*
;

srsAttribute:
    NAME_SYMBOL TEXT_SYMBOL textStringNoLinebreak
    | DEFINITION_SYMBOL TEXT_SYMBOL textStringNoLinebreak
    | ORGANIZATION_SYMBOL textStringNoLinebreak IDENTIFIED_SYMBOL BY_SYMBOL real_ulonglong_number
    | DESCRIPTION_SYMBOL TEXT_SYMBOL textStringNoLinebreak
;

//----------------------------------------------------------------------------------------------------------------------