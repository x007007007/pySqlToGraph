parser grammar GBaseParser_clone;

options {
//    superClass = MySQLBaseRecognizer;
    tokenVocab = GBaseLexer;
    exportMacro = PARSERS_PUBLIC_TYPE;
}

//----------------------------------------------------------------------------------------------------------------------

cloneStatement:
    CLONE_SYMBOL (
        LOCAL_SYMBOL DATA_SYMBOL DIRECTORY_SYMBOL equal? textStringLiteral
        // Clone remote has been removed in 8.0.14. This alt is taken out by the conditional REMOTE_SYMBOL.
        | REMOTE_SYMBOL (FOR_SYMBOL REPLICATION_SYMBOL)?
        | {status.serverVersion >= 80014}? INSTANCE_SYMBOL FROM_SYMBOL user COLON_SYMBOL ulong_number IDENTIFIED_SYMBOL BY_SYMBOL
            textStringLiteral dataDirSSL?
    )
;

dataDirSSL:
    ssl
    | DATA_SYMBOL DIRECTORY_SYMBOL equal? textStringLiteral ssl?
;

ssl:
    REQUIRE_SYMBOL NO_SYMBOL? SSL_SYMBOL
;

//----------------------------------------------------------------------------------------------------------------------

