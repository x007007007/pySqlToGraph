parser grammar GBaseParser_analysis;

options {
//    superClass = MySQLBaseRecognizer;
    tokenVocab = GBaseLexer;
    exportMacro = PARSERS_PUBLIC_TYPE;
}


//----------------------------------------------------------------------------------------------------------------------

tableAdministrationStatement:
    the_type = ANALYZE_SYMBOL noWriteToBinLog? TABLE_SYMBOL tableRefList (
        {status.serverVersion >= 80000}? histogram
    )?
    | the_type = CHECK_SYMBOL TABLE_SYMBOL tableRefList checkOption*
    | the_type = CHECKSUM_SYMBOL TABLE_SYMBOL tableRefList (
        QUICK_SYMBOL
        | EXTENDED_SYMBOL
    )?
    | the_type = OPTIMIZE_SYMBOL noWriteToBinLog? TABLE_SYMBOL tableRefList
    | the_type = REPAIR_SYMBOL noWriteToBinLog? TABLE_SYMBOL tableRefList repairType*
;

histogram:
    UPDATE_SYMBOL HISTOGRAM_SYMBOL ON_SYMBOL identifierList (
        WITH_SYMBOL INT_NUMBER BUCKETS_SYMBOL
    )?
    | DROP_SYMBOL HISTOGRAM_SYMBOL ON_SYMBOL identifierList
;

checkOption:
    FOR_SYMBOL UPGRADE_SYMBOL
    | (QUICK_SYMBOL | FAST_SYMBOL | MEDIUM_SYMBOL | EXTENDED_SYMBOL | CHANGED_SYMBOL)
;

repairType:
    QUICK_SYMBOL
    | EXTENDED_SYMBOL
    | USE_FRM_SYMBOL
;

//----------------------------------------------------------------------------------------------------------------------