parser grammar GBaseParser_rename;

options {
//    superClass = MySQLBaseRecognizer;
    tokenVocab = GBaseLexer;
    exportMacro = PARSERS_PUBLIC_TYPE;
}


//----------------------------------------------------------------------------------------------------------------------

renameTableStatement:
    RENAME_SYMBOL (TABLE_SYMBOL | TABLES_SYMBOL) renamePair (COMMA_SYMBOL renamePair)*
;

renamePair:
    tableRef TO_SYMBOL tableName
;

//----------------------------------------------------------------------------------------------------------------------

truncateTableStatement:
    TRUNCATE_SYMBOL TABLE_SYMBOL? tableRef
;

//----------------------------------------------------------------------------------------------------------------------

importStatement:
    IMPORT_SYMBOL TABLE_SYMBOL FROM_SYMBOL textStringLiteralList
;
