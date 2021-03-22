parser grammar GBaseParser_load;

options {
//    superClass = MySQLBaseRecognizer;
    tokenVocab = GBaseLexer;
    exportMacro = PARSERS_PUBLIC_TYPE;
}

//----------------------------------------------------------------------------------------------------------------------

loadStatement:
    LOAD_SYMBOL dataOrXml (LOW_PRIORITY_SYMBOL | CONCURRENT_SYMBOL)? LOCAL_SYMBOL? INFILE_SYMBOL textLiteral (
        REPLACE_SYMBOL
        | IGNORE_SYMBOL
    )? INTO_SYMBOL TABLE_SYMBOL tableRef usePartition? charsetClause? xmlRowsIdentifiedBy? fieldsClause? linesClause?
        loadDataFileTail
;

dataOrXml:
    DATA_SYMBOL
    | XML_SYMBOL
;

xmlRowsIdentifiedBy:
    ROWS_SYMBOL IDENTIFIED_SYMBOL BY_SYMBOL textString
;

loadDataFileTail:
    (IGNORE_SYMBOL INT_NUMBER (LINES_SYMBOL | ROWS_SYMBOL))? loadDataFileTargetList? (
        SET_SYMBOL updateList
    )?
;

loadDataFileTargetList:
    OPEN_PAR_SYMBOL fieldOrVariableList? CLOSE_PAR_SYMBOL
;

fieldOrVariableList:
    (columnRef | userVariable) (COMMA_SYMBOL (columnRef | userVariable))*
;

//----------------------------------------------------------------------------------------------------------------------
