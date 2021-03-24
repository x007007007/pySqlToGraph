parser grammar GBaseParser_merge_into;

options {
//    superClass = MySQLBaseRecognizer;
    tokenVocab = GBaseLexer;
    exportMacro = PARSERS_PUBLIC_TYPE;
}


//----------------------------------------------------------------------------------------------------------------------

mergeIntoStatement:
    MERGE_SYMBOL mergeHint? INTO_SYMBOL? tableReference
    USING_SYMBOL tableReference ON_SYMBOL mergeIntoStatementCondition
    mergeUpdateClause? mergeInsertClause? oraleErrorLoggingClause?
;

mergeHint:
;

mergeIntoStatementCondition:
    whereClause
;

mergeUpdateClause:
    WHEN_SYMBOL MATCHED_SYMBOL THEN_SYMBOL UPDATE_SYMBOL SET_SYMBOL updateList whereClause? mergeUpdateClauseDelete?
;

mergeUpdateClauseDelete:
    DELETE_SYMBOL whereClause
;

//
mergeInsertClause:
    WHEN_SYMBOL NOT_SYMBOL MATCHED_SYMBOL THEN_SYMBOL INSERT_SYMBOL insertFromConstructor whereClause?
;

oraleErrorLoggingClause:
;
//----------------------------------------------------------------------------------------------------------------------