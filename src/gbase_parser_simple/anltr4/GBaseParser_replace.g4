parser grammar GBaseParser_replace;

options {
//    superClass = MySQLBaseRecognizer;
    tokenVocab = GBaseLexer;
    exportMacro = PARSERS_PUBLIC_TYPE;
}


//----------------------------------------------------------------------------------------------------------------------

replaceStatement:
    REPLACE_SYMBOL (LOW_PRIORITY_SYMBOL | DELAYED_SYMBOL)? INTO_SYMBOL? tableRef usePartition? (
        insertFromConstructor
        | SET_SYMBOL updateList
        | insertQueryExpression
    )
;

//----------------------------------------------------------------------------------------------------------------------