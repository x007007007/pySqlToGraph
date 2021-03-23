parser grammar GBaseParser_update;

options {
//    superClass = MySQLBaseRecognizer;
    tokenVocab = GBaseLexer;
    exportMacro = PARSERS_PUBLIC_TYPE;
}


//----------------------------------------------------------------------------------------------------------------------

updateStatement:
    ({status.serverVersion >= 80000}? withClause)? UPDATE_SYMBOL LOW_PRIORITY_SYMBOL? IGNORE_SYMBOL? tableReferenceList SET_SYMBOL
        updateList whereClause? orderClause? simpleLimitClause?
;

//----------------------------------------------------------------------------------------------------------------------