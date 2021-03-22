parser grammar GBaseParser_name_ref;

options {
//    superClass = MySQLBaseRecognizer;
    tokenVocab = GBaseLexer;
    exportMacro = PARSERS_PUBLIC_TYPE;
}


//----------------- Object names and references ------------------------------------------------------------------------

// For each the_object we have at least 2 rules here:
// 1) The name when creating that the_object.
// 2) The name when used to reference it from other rules.
//
// Sometimes we need additional reference rules with different form, depending on the place such a reference is used.

// A name for a field (column/index). Can be qualified with the current schema + table (although it's not a reference).
fieldIdentifier:
    dotIdentifier
    | qualifiedIdentifier dotIdentifier?
;

columnName:
    // With server 8.0 this became a simple identifier.
    {status.serverVersion >= 80000}? identifier
    | {status.serverVersion < 80000}? fieldIdentifier
;

// A reference to a column of the the_object we are working on.
columnInternalRef:
    identifier
;

columnInternalRefList: // column_list (+ parentheses) + opt_derived_column_list in sql_yacc.yy
    OPEN_PAR_SYMBOL columnInternalRef (COMMA_SYMBOL columnInternalRef)* CLOSE_PAR_SYMBOL
;

columnRef: // A field identifier that can reference any schema/table.
    fieldIdentifier
;

insertIdentifier:
    columnRef
    | tableWild
;

indexName:
    identifier
;

indexRef: // Always internal reference. Still all qualification variations are accepted.
    fieldIdentifier
;

tableWild:
    identifier DOT_SYMBOL (identifier DOT_SYMBOL)? MULT_OPERATOR
;

schemaName:
    identifier
;

schemaRef:
    identifier
;

procedureName:
    qualifiedIdentifier
;

procedureRef:
    qualifiedIdentifier
;

functionName:
    qualifiedIdentifier
;

functionRef:
    qualifiedIdentifier
;

triggerName:
    qualifiedIdentifier
;

triggerRef:
    qualifiedIdentifier
;

viewName:
    qualifiedIdentifier
    | dotIdentifier
;

viewRef:
    qualifiedIdentifier
    | dotIdentifier
;

tablespaceName:
    identifier
;

tablespaceRef:
    identifier
;

logfileGroupName:
    identifier
;

logfileGroupRef:
    identifier
;

eventName:
    qualifiedIdentifier
;

eventRef:
    qualifiedIdentifier
;

udfName: // UDFs are referenced at the same places as any other function. So, no dedicated *_ref here.
    identifier
;

serverName:
    textOrIdentifier
;

serverRef:
    textOrIdentifier
;

engineRef:
    textOrIdentifier
;

tableName:
    qualifiedIdentifier
    | dotIdentifier
;

filterTableRef: // Always qualified.
    schemaRef dotIdentifier
;

tableRefWithWildcard:
    identifier (DOT_SYMBOL MULT_OPERATOR | dotIdentifier (DOT_SYMBOL MULT_OPERATOR)?)?
;

tableRef:
    qualifiedIdentifier
    | dotIdentifier
;

tableRefList:
    tableRef (COMMA_SYMBOL tableRef)*
;

tableAliasRefList:
    tableRefWithWildcard (COMMA_SYMBOL tableRefWithWildcard)*
;

parameterName:
    identifier
;

labelIdentifier:
    pureIdentifier
    | labelKeyword
;

labelRef:
    labelIdentifier
;

roleIdentifier:
    pureIdentifier
    | roleKeyword
;

roleRef:
    roleIdentifier
;

pluginRef:
    identifier
;

componentRef:
    textStringLiteral
;

resourceGroupRef:
    identifier
;

windowName:
    identifier
;
