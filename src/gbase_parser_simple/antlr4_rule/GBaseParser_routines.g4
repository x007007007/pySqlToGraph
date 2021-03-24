parser grammar GBaseParser_routines;

options {
//    superClass = MySQLBaseRecognizer;
    tokenVocab = GBaseLexer;
    exportMacro = PARSERS_PUBLIC_TYPE;
}


//----------------- Stored routines rules ------------------------------------------------------------------------------

// Compound syntax for stored procedures, stored functions, triggers and events.
// Implements both, sp_proc_stmt and ev_sql_stmt_inner from the server grammar.
compoundStatement:
    simpleStatement
    | returnStatement
    | ifStatement
    | caseStatement
    | labeledBlock
    | unlabeledBlock
    | labeledControl
    | unlabeledControl
    | leaveStatement
    | iterateStatement
    | cursorOpen
    | cursorFetch
    | cursorClose
;

returnStatement:
    RETURN_SYMBOL expr
;

ifStatement:
    IF_SYMBOL ifBody END_SYMBOL IF_SYMBOL
;

ifBody:
    expr thenStatement (ELSEIF_SYMBOL ifBody | ELSE_SYMBOL compoundStatementList)?
;

thenStatement:
    THEN_SYMBOL compoundStatementList
;

compoundStatementList: (compoundStatement SEMICOLON_SYMBOL)+
;

caseStatement:
    CASE_SYMBOL expr? (whenExpression thenStatement)+ elseStatement? END_SYMBOL CASE_SYMBOL
;

elseStatement:
    ELSE_SYMBOL compoundStatementList
;

labeledBlock:
    label beginEndBlock labelRef?
;

unlabeledBlock:
    beginEndBlock
;

label:
    // Block labels can only be up to 16 characters long.
    labelIdentifier COLON_SYMBOL
;

beginEndBlock:
    BEGIN_SYMBOL spDeclarations? compoundStatementList? END_SYMBOL
;

labeledControl:
    label unlabeledControl labelRef?
;

unlabeledControl:
    loopBlock
    | whileDoBlock
    | repeatUntilBlock
;

loopBlock:
    LOOP_SYMBOL compoundStatementList END_SYMBOL LOOP_SYMBOL
;

whileDoBlock:
    WHILE_SYMBOL expr DO_SYMBOL compoundStatementList END_SYMBOL WHILE_SYMBOL
;

repeatUntilBlock:
    REPEAT_SYMBOL compoundStatementList UNTIL_SYMBOL expr END_SYMBOL REPEAT_SYMBOL
;

spDeclarations: (spDeclaration SEMICOLON_SYMBOL)+
;

spDeclaration:
    variableDeclaration
    | conditionDeclaration
    | handlerDeclaration
    | cursorDeclaration
;

variableDeclaration:
    DECLARE_SYMBOL identifierList dataType collate? (DEFAULT_SYMBOL expr)?
;

conditionDeclaration:
    DECLARE_SYMBOL identifier CONDITION_SYMBOL FOR_SYMBOL spCondition
;

spCondition:
    ulong_number
    | sqlstate
;

sqlstate:
    SQLSTATE_SYMBOL VALUE_SYMBOL? textLiteral
;

handlerDeclaration:
    DECLARE_SYMBOL (CONTINUE_SYMBOL | EXIT_SYMBOL | UNDO_SYMBOL) HANDLER_SYMBOL FOR_SYMBOL handlerCondition (
        COMMA_SYMBOL handlerCondition
    )* compoundStatement
;

handlerCondition:
    spCondition
    | identifier
    | SQLWARNING_SYMBOL
    | notRule FOUND_SYMBOL
    | SQLEXCEPTION_SYMBOL
;

cursorDeclaration:
    DECLARE_SYMBOL identifier CURSOR_SYMBOL FOR_SYMBOL selectStatement
;

iterateStatement:
    ITERATE_SYMBOL labelRef
;

leaveStatement:
    LEAVE_SYMBOL labelRef
;

getDiagnostics:
    GET_SYMBOL (CURRENT_SYMBOL | {status.serverVersion >= 50700}? STACKED_SYMBOL)? DIAGNOSTICS_SYMBOL (
        statementInformationItem (COMMA_SYMBOL statementInformationItem)*
        | CONDITION_SYMBOL signalAllowedExpr conditionInformationItem (
            COMMA_SYMBOL conditionInformationItem
        )*
    )
;

// Only a limited subset of expr is allowed in SIGNAL/RESIGNAL/CONDITIONS.
signalAllowedExpr:
    literal
    | variable
    | qualifiedIdentifier
;

statementInformationItem:
    (variable | identifier) EQUAL_OPERATOR (NUMBER_SYMBOL | ROW_COUNT_SYMBOL)
;

conditionInformationItem:
    (variable | identifier) EQUAL_OPERATOR (
        signalInformationItemName
        | RETURNED_SQLSTATE_SYMBOL
        | RETURNED_GBASE_ERRNO_SYMBOL
    )
;

signalInformationItemName:
    CLASS_ORIGIN_SYMBOL
    | SUBCLASS_ORIGIN_SYMBOL
    | CONSTRAINT_CATALOG_SYMBOL
    | CONSTRAINT_SCHEMA_SYMBOL
    | CONSTRAINT_NAME_SYMBOL
    | CATALOG_NAME_SYMBOL
    | SCHEMA_NAME_SYMBOL
    | TABLE_NAME_SYMBOL
    | COLUMN_NAME_SYMBOL
    | CURSOR_NAME_SYMBOL
    | MESSAGE_TEXT_SYMBOL
    | MYSQL_ERRNO_SYMBOL
;

signalStatement:
    SIGNAL_SYMBOL (identifier | sqlstate) (
        SET_SYMBOL signalInformationItem (COMMA_SYMBOL signalInformationItem)*
    )?
;

resignalStatement:
    RESIGNAL_SYMBOL (identifier | sqlstate)? (
        SET_SYMBOL signalInformationItem (COMMA_SYMBOL signalInformationItem)*
    )?
;

signalInformationItem:
    signalInformationItemName EQUAL_OPERATOR signalAllowedExpr
;

cursorOpen:
    OPEN_SYMBOL identifier
;

cursorClose:
    CLOSE_SYMBOL identifier
;

cursorFetch:
    FETCH_SYMBOL (NEXT_SYMBOL? FROM_SYMBOL)? identifier INTO_SYMBOL identifierList
;


