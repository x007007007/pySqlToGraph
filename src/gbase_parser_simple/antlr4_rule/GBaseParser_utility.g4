parser grammar GBaseParser_utility;

options {
//    superClass = MySQLBaseRecognizer;
    tokenVocab = GBaseLexer;
    exportMacro = PARSERS_PUBLIC_TYPE;
}

//----------------------------------------------------------------------------------------------------------------------

utilityStatement:
    describeStatement
    | explainStatement
    | helpCommand
    | useCommand
    | {status.serverVersion >= 80011}? restartServer
;

describeStatement:
    (EXPLAIN_SYMBOL | DESCRIBE_SYMBOL | DESC_SYMBOL) tableRef (
        textString
        | columnRef
    )?
;

explainStatement:
    (EXPLAIN_SYMBOL | DESCRIBE_SYMBOL | DESC_SYMBOL) (
        {status.serverVersion < 80000}? EXTENDED_SYMBOL
        | {status.serverVersion < 80000}? PARTITIONS_SYMBOL
        | {status.serverVersion >= 50605}? FORMAT_SYMBOL EQUAL_OPERATOR textOrIdentifier
        | {status.serverVersion >= 80018}? ANALYZE_SYMBOL
        | {status.serverVersion >= 80019}? ANALYZE_SYMBOL FORMAT_SYMBOL EQUAL_OPERATOR textOrIdentifier
    )? explainableStatement
;

// Before server version 5.6 only select statements were explainable.
explainableStatement:
    selectStatement
    | {status.serverVersion >= 50603}? (
        deleteStatement
        | insertStatement
        | replaceStatement
        | updateStatement
    )
    | {status.serverVersion >= 50700}? FOR_SYMBOL CONNECTION_SYMBOL real_ulong_number
;

helpCommand:
    HELP_SYMBOL textOrIdentifier
;

useCommand:
    USE_SYMBOL identifier
;

restartServer:
    RESTART_SYMBOL
;


