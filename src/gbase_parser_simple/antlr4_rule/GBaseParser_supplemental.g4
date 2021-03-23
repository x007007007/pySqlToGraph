parser grammar GBaseParser_supplemental;

options {
//    superClass = MySQLBaseRecognizer;
    tokenVocab = GBaseLexer;
    exportMacro = PARSERS_PUBLIC_TYPE;
}


//----------------- Supplemental rules ---------------------------------------------------------------------------------

// Schedules in CREATE/ALTER EVENT.
schedule:
    AT_SYMBOL expr
    | EVERY_SYMBOL expr interval (STARTS_SYMBOL expr)? (ENDS_SYMBOL expr)?
;

columnDefinition:
    columnName fieldDefinition checkOrReferences?
;

checkOrReferences:
    {status.serverVersion < 80016}? checkConstraint
    | references
;

checkConstraint:
    CHECK_SYMBOL exprWithParentheses
;

constraintEnforcement:
    NOT_SYMBOL? ENFORCED_SYMBOL
;

tableConstraintDef:
    the_type = (KEY_SYMBOL | INDEX_SYMBOL) indexNameAndType? keyListVariants indexOption*
    | the_type = FULLTEXT_SYMBOL keyOrIndex? indexName? keyListVariants fulltextIndexOption*
    | the_type = SPATIAL_SYMBOL keyOrIndex? indexName? keyListVariants spatialIndexOption*
    | constraintName? (
        (the_type = PRIMARY_SYMBOL KEY_SYMBOL | the_type = UNIQUE_SYMBOL keyOrIndex?) indexNameAndType? keyListVariants indexOption*
        | the_type = FOREIGN_SYMBOL KEY_SYMBOL indexName? keyList references
        | checkConstraint ({status.serverVersion >= 80017}? constraintEnforcement)?
    )
;

constraintName:
    CONSTRAINT_SYMBOL identifier?
;

fieldDefinition:
    dataType (
        columnAttribute*
        | {status.serverVersion >= 50707}? collate? (GENERATED_SYMBOL ALWAYS_SYMBOL)? AS_SYMBOL exprWithParentheses (
            VIRTUAL_SYMBOL
            | STORED_SYMBOL
        )? (
            {status.serverVersion < 80000}? gcolAttribute*
            | {status.serverVersion >= 80000}? columnAttribute* // Beginning with 8.0 the full attribute set is supported.
        )
    )
;

columnAttribute:
    NOT_SYMBOL? nullLiteral
    | {status.serverVersion >= 80014}? NOT_SYMBOL SECONDARY_SYMBOL
    | value = DEFAULT_SYMBOL (
        signedLiteral
        | NOW_SYMBOL timeFunctionParameters?
        | {status.serverVersion >= 80013}? exprWithParentheses
    )
    | value = ON_SYMBOL UPDATE_SYMBOL NOW_SYMBOL timeFunctionParameters?
    | value = AUTO_INCREMENT_SYMBOL
    | value = SERIAL_SYMBOL DEFAULT_SYMBOL VALUE_SYMBOL
    | PRIMARY_SYMBOL? value = KEY_SYMBOL
    | value = UNIQUE_SYMBOL KEY_SYMBOL?
    | value = COMMENT_SYMBOL textLiteral
    | collate
    | value = COLUMN_FORMAT_SYMBOL columnFormat
    | value = STORAGE_SYMBOL storageMedia
    | {status.serverVersion >= 80000}? value = SRID_SYMBOL real_ulonglong_number
    | {status.serverVersion >= 80017}? constraintName? checkConstraint
    | {status.serverVersion >= 80017}? constraintEnforcement
;

columnFormat:
    FIXED_SYMBOL
    | DYNAMIC_SYMBOL
    | DEFAULT_SYMBOL
;

storageMedia:
    DISK_SYMBOL
    | MEMORY_SYMBOL
    | DEFAULT_SYMBOL
;

gcolAttribute:
    UNIQUE_SYMBOL KEY_SYMBOL?
    | COMMENT_SYMBOL textString
    | notRule? NULL_SYMBOL
    | PRIMARY_SYMBOL? KEY_SYMBOL
;

references:
    REFERENCES_SYMBOL tableRef identifierListWithParentheses? (
        MATCH_SYMBOL match = (FULL_SYMBOL | PARTIAL_SYMBOL | SIMPLE_SYMBOL)
    )? (
        ON_SYMBOL option = UPDATE_SYMBOL deleteOption (
            ON_SYMBOL DELETE_SYMBOL deleteOption
        )?
        | ON_SYMBOL option = DELETE_SYMBOL deleteOption (
            ON_SYMBOL UPDATE_SYMBOL deleteOption
        )?
    )?
;

deleteOption:
    (RESTRICT_SYMBOL | CASCADE_SYMBOL)
    | SET_SYMBOL nullLiteral
    | NO_SYMBOL ACTION_SYMBOL
;

keyList:
    OPEN_PAR_SYMBOL keyPart (COMMA_SYMBOL keyPart)* CLOSE_PAR_SYMBOL
;

keyPart:
    identifier fieldLength? direction?
;

keyListWithExpression:
    OPEN_PAR_SYMBOL keyPartOrExpression (COMMA_SYMBOL keyPartOrExpression)* CLOSE_PAR_SYMBOL
;

keyPartOrExpression: // key_part_with_expression in sql_yacc.yy.
    keyPart
    | exprWithParentheses direction?
;

keyListVariants:
    {status.serverVersion >= 80013}? keyListWithExpression
    | {status.serverVersion < 80013}? keyList
;

indexType:
    algorithm = (BTREE_SYMBOL | RTREE_SYMBOL | HASH_SYMBOL)
;

indexOption:
    commonIndexOption
    | indexTypeClause
;

// These options are common for all index types.
commonIndexOption:
    KEY_BLOCK_SIZE_SYMBOL EQUAL_OPERATOR? ulong_number
    | COMMENT_SYMBOL textLiteral
    | {status.serverVersion >= 80000}? visibility
;

visibility:
    VISIBLE_SYMBOL
    | INVISIBLE_SYMBOL
;

indexTypeClause:
    (USING_SYMBOL | TYPE_SYMBOL) indexType
;

fulltextIndexOption:
    commonIndexOption
    | WITH_SYMBOL PARSER_SYMBOL identifier
;

spatialIndexOption:
    commonIndexOption
;

dataTypeDefinition: // For external use only. Don't reference this in the normal grammar.
    dataType EOF
;

dataType: // the_type in sql_yacc.yy
    the_type = (
        INT_SYMBOL
        | TINYINT_SYMBOL
        | SMALLINT_SYMBOL
        | MEDIUMINT_SYMBOL
        | BIGINT_SYMBOL
    ) fieldLength? fieldOptions?
    | (the_type = REAL_SYMBOL | the_type = DOUBLE_SYMBOL PRECISION_SYMBOL?) precision? fieldOptions?
    | the_type = (FLOAT_SYMBOL | DECIMAL_SYMBOL | NUMERIC_SYMBOL | FIXED_SYMBOL) floatOptions? fieldOptions?
    | the_type = BIT_SYMBOL fieldLength?
    | the_type = (BOOL_SYMBOL | BOOLEAN_SYMBOL)
    | the_type = CHAR_SYMBOL fieldLength? charsetWithOptBinary?
    | nchar fieldLength? BINARY_SYMBOL?
    | the_type = BINARY_SYMBOL fieldLength?
    | (
        the_type = CHAR_SYMBOL VARYING_SYMBOL
        | the_type = VARCHAR_SYMBOL
      ) fieldLength? charsetWithOptBinary?                      // gbase update
    | (
        the_type = NATIONAL_SYMBOL VARCHAR_SYMBOL
        | the_type = NVARCHAR_SYMBOL
        | the_type = NCHAR_SYMBOL VARCHAR_SYMBOL
        | the_type = NATIONAL_SYMBOL CHAR_SYMBOL VARYING_SYMBOL
        | the_type = NCHAR_SYMBOL VARYING_SYMBOL
    ) fieldLength BINARY_SYMBOL?
    | the_type = VARBINARY_SYMBOL fieldLength
    | the_type = YEAR_SYMBOL fieldLength? fieldOptions?
    | the_type = DATE_SYMBOL
    | the_type = TIME_SYMBOL typeDatetimePrecision?
    | the_type = TIMESTAMP_SYMBOL typeDatetimePrecision?
    | the_type = DATETIME_SYMBOL typeDatetimePrecision?
    | the_type = TINYBLOB_SYMBOL
    | the_type = BLOB_SYMBOL fieldLength?
    | the_type = (MEDIUMBLOB_SYMBOL | LONGBLOB_SYMBOL)
    | the_type = LONG_SYMBOL VARBINARY_SYMBOL
    | the_type = LONG_SYMBOL (CHAR_SYMBOL VARYING_SYMBOL | VARCHAR_SYMBOL)? charsetWithOptBinary?
    | the_type = TINYTEXT_SYMBOL charsetWithOptBinary?
    | the_type = TEXT_SYMBOL fieldLength? charsetWithOptBinary?
    | the_type = MEDIUMTEXT_SYMBOL charsetWithOptBinary?
    | the_type = LONGTEXT_SYMBOL charsetWithOptBinary?
    | the_type = ENUM_SYMBOL stringList charsetWithOptBinary?
    | the_type = SET_SYMBOL stringList charsetWithOptBinary?
    | the_type = SERIAL_SYMBOL
    | {status.serverVersion >= 50708}? the_type = JSON_SYMBOL
    | the_type = (
        GEOMETRY_SYMBOL
        | GEOMETRYCOLLECTION_SYMBOL
        | POINT_SYMBOL
        | MULTIPOINT_SYMBOL
        | LINESTRING_SYMBOL
        | MULTILINESTRING_SYMBOL
        | POLYGON_SYMBOL
        | MULTIPOLYGON_SYMBOL
    )
;

nchar:
    the_type = NCHAR_SYMBOL
    | the_type = NATIONAL_SYMBOL CHAR_SYMBOL
;

realType:
    the_type = REAL_SYMBOL
    | the_type = DOUBLE_SYMBOL PRECISION_SYMBOL?
;

fieldLength:
    OPEN_PAR_SYMBOL (real_ulonglong_number | DECIMAL_NUMBER) CLOSE_PAR_SYMBOL
;

fieldOptions: (SIGNED_SYMBOL | UNSIGNED_SYMBOL | ZEROFILL_SYMBOL)+
;

charsetWithOptBinary:
    ascii
    | the_unicode
    | BYTE_SYMBOL
    | charset charsetName BINARY_SYMBOL?
    | BINARY_SYMBOL (charset charsetName)?
;

ascii:
    ASCII_SYMBOL BINARY_SYMBOL?
    | BINARY_SYMBOL ASCII_SYMBOL
;

the_unicode:
    UNICODE_SYMBOL BINARY_SYMBOL?
    | BINARY_SYMBOL UNICODE_SYMBOL
;

wsNumCodepoints:
    OPEN_PAR_SYMBOL real_ulong_number CLOSE_PAR_SYMBOL
;

typeDatetimePrecision:
    OPEN_PAR_SYMBOL INT_NUMBER CLOSE_PAR_SYMBOL
;

charsetName:
    textOrIdentifier
    | BINARY_SYMBOL
    | {status.serverVersion < 80011}? DEFAULT_SYMBOL
;

collationName:
    textOrIdentifier
    | {status.serverVersion < 80011}? DEFAULT_SYMBOL
    | {status.serverVersion >= 80018}? BINARY_SYMBOL
;

createTableOptions:
    createTableOption (COMMA_SYMBOL? createTableOption)*
;

createTableOptionsSpaceSeparated:
    createTableOption+
;

createTableOption: // In the order as they appear in the server grammar.
    option = ENGINE_SYMBOL EQUAL_OPERATOR? engineRef
    | {status.serverVersion >= 80014}? option = SECONDARY_ENGINE_SYMBOL equal? (
        NULL_SYMBOL
        | textOrIdentifier
    )
    | option = MAX_ROWS_SYMBOL EQUAL_OPERATOR? ulonglong_number
    | option = MIN_ROWS_SYMBOL EQUAL_OPERATOR? ulonglong_number
    | option = AVG_ROW_LENGTH_SYMBOL EQUAL_OPERATOR? ulong_number
    | option = PASSWORD_SYMBOL EQUAL_OPERATOR? textStringLiteral
    | option = COMMENT_SYMBOL EQUAL_OPERATOR? textStringLiteral
    | {status.serverVersion >= 50708}? option = COMPRESSION_SYMBOL EQUAL_OPERATOR? textString
    | {status.serverVersion >= 50711}? option = ENCRYPTION_SYMBOL EQUAL_OPERATOR? textString
    | option = AUTO_INCREMENT_SYMBOL EQUAL_OPERATOR? ulonglong_number
    | option = PACK_KEYS_SYMBOL EQUAL_OPERATOR? ternaryOption
    | option = (
        STATS_AUTO_RECALC_SYMBOL
        | STATS_PERSISTENT_SYMBOL
        | STATS_SAMPLE_PAGES_SYMBOL
    ) EQUAL_OPERATOR? ternaryOption
    | option = (CHECKSUM_SYMBOL | TABLE_CHECKSUM_SYMBOL) EQUAL_OPERATOR? ulong_number
    | option = DELAY_KEY_WRITE_SYMBOL EQUAL_OPERATOR? ulong_number
    | option = ROW_FORMAT_SYMBOL EQUAL_OPERATOR? the_format = (
        DEFAULT_SYMBOL
        | DYNAMIC_SYMBOL
        | FIXED_SYMBOL
        | COMPRESSED_SYMBOL
        | REDUNDANT_SYMBOL
        | COMPACT_SYMBOL
    )
    | option = UNION_SYMBOL EQUAL_OPERATOR? OPEN_PAR_SYMBOL tableRefList CLOSE_PAR_SYMBOL
    | defaultCharset
    | defaultCollation
    | option = INSERT_METHOD_SYMBOL EQUAL_OPERATOR? method = (
        NO_SYMBOL
        | FIRST_SYMBOL
        | LAST_SYMBOL
    )
    | option = DATA_SYMBOL DIRECTORY_SYMBOL EQUAL_OPERATOR? textString
    | option = INDEX_SYMBOL DIRECTORY_SYMBOL EQUAL_OPERATOR? textString
    | option = TABLESPACE_SYMBOL (
        {status.serverVersion >= 50707}? EQUAL_OPERATOR?
        | /* empty */
    ) identifier
    | option = STORAGE_SYMBOL (DISK_SYMBOL | MEMORY_SYMBOL)
    | option = CONNECTION_SYMBOL EQUAL_OPERATOR? textString
    | option = KEY_BLOCK_SIZE_SYMBOL EQUAL_OPERATOR? ulong_number
;

ternaryOption:
    ulong_number
    | DEFAULT_SYMBOL
;

defaultCollation:
    DEFAULT_SYMBOL? COLLATE_SYMBOL EQUAL_OPERATOR? collationName
;

defaultEncryption:
    DEFAULT_SYMBOL? ENCRYPTION_SYMBOL EQUAL_OPERATOR? textStringLiteral
;

defaultCharset:
    DEFAULT_SYMBOL? charset EQUAL_OPERATOR? charsetName
;

// Partition rules for CREATE/ALTER TABLE.
partitionClause:
    PARTITION_SYMBOL BY_SYMBOL partitionTypeDef (PARTITIONS_SYMBOL real_ulong_number)? subPartitions? partitionDefinitions?
;

partitionTypeDef:
    LINEAR_SYMBOL? KEY_SYMBOL partitionKeyAlgorithm? OPEN_PAR_SYMBOL identifierList? CLOSE_PAR_SYMBOL # partitionDefKey
    | LINEAR_SYMBOL? HASH_SYMBOL OPEN_PAR_SYMBOL bitExpr CLOSE_PAR_SYMBOL                             # partitionDefHash
    | (RANGE_SYMBOL | LIST_SYMBOL) (
        OPEN_PAR_SYMBOL bitExpr CLOSE_PAR_SYMBOL
        | COLUMNS_SYMBOL OPEN_PAR_SYMBOL identifierList? CLOSE_PAR_SYMBOL
    ) # partitionDefRangeList
;

subPartitions:
    SUBPARTITION_SYMBOL BY_SYMBOL LINEAR_SYMBOL? (
        HASH_SYMBOL OPEN_PAR_SYMBOL bitExpr CLOSE_PAR_SYMBOL
        | KEY_SYMBOL partitionKeyAlgorithm? identifierListWithParentheses
    ) (SUBPARTITIONS_SYMBOL real_ulong_number)?
;

partitionKeyAlgorithm: // Actually only 1 and 2 are allowed. Needs a semantic check.
    {status.serverVersion >= 50700}? ALGORITHM_SYMBOL EQUAL_OPERATOR real_ulong_number
;

partitionDefinitions:
    OPEN_PAR_SYMBOL partitionDefinition (COMMA_SYMBOL partitionDefinition)* CLOSE_PAR_SYMBOL
;

partitionDefinition:
    PARTITION_SYMBOL identifier (
        VALUES_SYMBOL LESS_SYMBOL THAN_SYMBOL (
            partitionValueItemListParen
            | MAXVALUE_SYMBOL
        )
        | VALUES_SYMBOL IN_SYMBOL partitionValuesIn
    )? partitionOption* (
        OPEN_PAR_SYMBOL subpartitionDefinition (COMMA_SYMBOL subpartitionDefinition)* CLOSE_PAR_SYMBOL
    )?
;

partitionValuesIn:
    partitionValueItemListParen
    | OPEN_PAR_SYMBOL partitionValueItemListParen (
        COMMA_SYMBOL partitionValueItemListParen
    )* CLOSE_PAR_SYMBOL
;

partitionOption:
    option = TABLESPACE_SYMBOL EQUAL_OPERATOR? identifier
    | STORAGE_SYMBOL? option = ENGINE_SYMBOL EQUAL_OPERATOR? engineRef
    | option = NODEGROUP_SYMBOL EQUAL_OPERATOR? real_ulong_number
    | option = (MAX_ROWS_SYMBOL | MIN_ROWS_SYMBOL) EQUAL_OPERATOR? real_ulong_number
    | option = (DATA_SYMBOL | INDEX_SYMBOL) DIRECTORY_SYMBOL EQUAL_OPERATOR? textLiteral
    | option = COMMENT_SYMBOL EQUAL_OPERATOR? textLiteral
;

subpartitionDefinition:
    SUBPARTITION_SYMBOL textOrIdentifier partitionOption*
;

partitionValueItemListParen:
    OPEN_PAR_SYMBOL partitionValueItem (COMMA_SYMBOL partitionValueItem)* CLOSE_PAR_SYMBOL
;

partitionValueItem:
    bitExpr
    | MAXVALUE_SYMBOL
;

definerClause:
    DEFINER_SYMBOL EQUAL_OPERATOR user
;

ifExists:
    IF_SYMBOL EXISTS_SYMBOL
;

ifNotExists:
    IF_SYMBOL notRule EXISTS_SYMBOL
;

procedureParameter:
    the_type = (IN_SYMBOL | OUT_SYMBOL | INOUT_SYMBOL)? functionParameter
;

functionParameter:
    parameterName typeWithOptCollate
;

collate:
    COLLATE_SYMBOL collationName
;

typeWithOptCollate:
    dataType collate?
;

schemaIdentifierPair:
    OPEN_PAR_SYMBOL schemaRef COMMA_SYMBOL schemaRef CLOSE_PAR_SYMBOL
;

viewRefList:
    viewRef (COMMA_SYMBOL viewRef)*
;

updateList:
    updateElement (COMMA_SYMBOL updateElement)*
;

updateElement:
    columnRef EQUAL_OPERATOR (expr | DEFAULT_SYMBOL)
;

charsetClause:
    charset charsetName
;

fieldsClause:
    COLUMNS_SYMBOL fieldTerm+
;

fieldTerm:
    TERMINATED_SYMBOL BY_SYMBOL textString
    | OPTIONALLY_SYMBOL? ENCLOSED_SYMBOL BY_SYMBOL textString
    | ESCAPED_SYMBOL BY_SYMBOL textString
;

linesClause:
    LINES_SYMBOL lineTerm+
;

lineTerm: (TERMINATED_SYMBOL | STARTING_SYMBOL) BY_SYMBOL textString
;

userList:
    user (COMMA_SYMBOL user)*
;

createUserList:
    createUserEntry (COMMA_SYMBOL createUserEntry)*
;

alterUserList:
    alterUserEntry (COMMA_SYMBOL alterUserEntry)*
;

createUserEntry: // create_user in sql_yacc.yy
    user (
        IDENTIFIED_SYMBOL (
            BY_SYMBOL ({status.serverVersion < 80011}? PASSWORD_SYMBOL)? textString
            | WITH_SYMBOL textOrIdentifier (
                AS_SYMBOL textStringHash
                | {status.serverVersion >= 50706}? BY_SYMBOL textString
            )?
            | {status.serverVersion >= 80018}? (WITH_SYMBOL textOrIdentifier)? BY_SYMBOL RANDOM_SYMBOL PASSWORD_SYMBOL
        )
    )?
;

alterUserEntry: // alter_user in sql_yacc.yy
    user (
        IDENTIFIED_SYMBOL (
            (WITH_SYMBOL textOrIdentifier)? BY_SYMBOL textString (
                REPLACE_SYMBOL textString
            )? retainCurrentPassword?
            | WITH_SYMBOL textOrIdentifier (
                AS_SYMBOL textStringHash retainCurrentPassword?
            )?
        )?
        | discardOldPassword?
    )
;

retainCurrentPassword:
    RETAIN_SYMBOL CURRENT_SYMBOL PASSWORD_SYMBOL
;

discardOldPassword:
    DISCARD_SYMBOL OLD_SYMBOL PASSWORD_SYMBOL
;

replacePassword:
    REPLACE_SYMBOL textString
;

userIdentifierOrText:
    textOrIdentifier (AT_SIGN_SYMBOL textOrIdentifier | AT_TEXT_SUFFIX)?
;

user:
    userIdentifierOrText
    | CURRENT_USER_SYMBOL parentheses?
;

likeClause:
    LIKE_SYMBOL textStringLiteral
;

likeOrWhere: // opt_wild_or_where in sql_yacc.yy
    likeClause
    | whereClause
;

onlineOption:
    ONLINE_SYMBOL
    | OFFLINE_SYMBOL
;

noWriteToBinLog:
    LOCAL_SYMBOL
    | NO_WRITE_TO_BINLOG_SYMBOL
;

usePartition:
    {status.serverVersion >= 50602}? PARTITION_SYMBOL identifierListWithParentheses
;

