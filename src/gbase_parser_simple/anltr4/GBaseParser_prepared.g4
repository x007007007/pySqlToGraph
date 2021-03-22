parser grammar GBaseParser_prepared;

options {
//    superClass = MySQLBaseRecognizer;
    tokenVocab = GBaseLexer;
    exportMacro = PARSERS_PUBLIC_TYPE;
}

//----------------------------------------------------------------------------------------------------------------------

preparedStatement:
    the_type = PREPARE_SYMBOL identifier FROM_SYMBOL (textLiteral | userVariable)
    | executeStatement
    | the_type = (DEALLOCATE_SYMBOL | DROP_SYMBOL) PREPARE_SYMBOL identifier
;

executeStatement:
    EXECUTE_SYMBOL identifier (USING_SYMBOL executeVarList)?
;

executeVarList:
    userVariable (COMMA_SYMBOL userVariable)*
;

//----------------------------------------------------------------------------------------------------------------------
