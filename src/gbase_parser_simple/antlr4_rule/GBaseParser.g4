parser grammar GBaseParser;

import
    GBaseParser_account,
    GBaseParser_admin_other,
    GBaseParser_alter,
    GBaseParser_analysis,
    GBaseParser_base,
    GBaseParser_create,
    GBaseParser_clone,
    GbaseParser_delete,
    GBaseParser_dlm,
    GBaseParser_drop,
    GBaseParser_expr,
    GBaseParser_insert,
    GBaseParser_install,
    GBaseParser_load,
    GBaseParser_merge_into,
    GBaseParser_name_ref,
    GBaseParser_prepared,
    GBaseParser_rename,
    GBaseParser_replace,
    GBaseParser_replication,
    GBaseParser_resource_group,
    GBaseParser_routines,
    GBaseParser_select,
    GBaseParser_set,
    GBaseParser_show,
    GBaseParser_supplemental,
    GBaseParser_transaction,
    GBaseParser_update,
    GBaseParser_utility
;

@header {
from gbase_parser_simple.lexer_status import status
}

options {
//    superClass = MySQLBaseRecognizer;
    tokenVocab = GBaseLexer;
    exportMacro = PARSERS_PUBLIC_TYPE;
}



root
    : queries? EOF?
    ;

queries
    : queries query
    | query
    ;

query: (simpleStatement | beginWork) SEMICOLON_SYMBOL
;

simpleStatement:
    // DDL
//    alterStatement
//    |
    createStatement
    | mergeIntoStatement
    | dropStatement
//    | renameTableStatement
    | truncateTableStatement
    | {status.serverVersion >= 80000}? importStatement

    // DML
    | callStatement
    | deleteStatement
    | doStatement
    | handlerStatement
    | insertStatement
    | loadStatement
    | replaceStatement
    | selectStatement
    | updateStatement
    | transactionOrLockingStatement
    | replicationStatement
    | preparedStatement
    // Data Directory
    | {status.serverVersion >= 80000}? cloneStatement

    // Database administration
//    | accountManagementStatement
//    | tableAdministrationStatement
//    | installUninstallStatment
    | setStatement // SET PASSWORD is handled in accountManagementStatement.
//    | showStatement
//    | {status.serverVersion >= 80000}? resourceGroupManagement
//    | otherAdministrativeStatement

    // MySQL utilitity statements
    | utilityStatement
    | {status.serverVersion >= 50604}? getDiagnostics
    | signalStatement
    | resignalStatement
;



