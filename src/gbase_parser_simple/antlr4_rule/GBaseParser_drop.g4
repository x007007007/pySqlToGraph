parser grammar GBaseParser_drop;

options {
//    superClass = MySQLBaseRecognizer;
    tokenVocab = GBaseLexer;
    exportMacro = PARSERS_PUBLIC_TYPE;
}

//----------------------------------------------------------------------------------------------------------------------

dropStatement:
    DROP_SYMBOL (
        dropDatabase
        | dropEvent
        | dropFunction
        | dropProcedure
        | dropIndex
        | dropLogfileGroup
        | dropServer
        | dropTable
        | dropTableSpace
        | dropTrigger
        | dropView
        | {status.serverVersion >= 80000}? dropRole
        | {status.serverVersion >= 80011}? dropSpatialReference
        | {status.serverVersion >= 80014}? dropUndoTablespace
    )
;

dropDatabase:
    DATABASE_SYMBOL ifExists? schemaRef
;

dropEvent:
    EVENT_SYMBOL ifExists? eventRef
;

dropFunction:
    FUNCTION_SYMBOL ifExists? functionRef // Including UDFs.
;

dropProcedure:
    PROCEDURE_SYMBOL ifExists? procedureRef
;

dropIndex:
    onlineOption? the_type = INDEX_SYMBOL indexRef ON_SYMBOL tableRef indexLockAndAlgorithm?
;

dropLogfileGroup:
    LOGFILE_SYMBOL GROUP_SYMBOL logfileGroupRef (
        dropLogfileGroupOption (COMMA_SYMBOL? dropLogfileGroupOption)*
    )?
;

dropLogfileGroupOption:
    tsOptionWait
    | tsOptionEngine
;

dropServer:
    SERVER_SYMBOL ifExists? serverRef
;

dropTable:
    TEMPORARY_SYMBOL? the_type = (TABLE_SYMBOL | TABLES_SYMBOL) ifExists? tableRefList (
        RESTRICT_SYMBOL
        | CASCADE_SYMBOL
    )?
;

dropTableSpace:
    TABLESPACE_SYMBOL tablespaceRef (
        dropLogfileGroupOption (COMMA_SYMBOL? dropLogfileGroupOption)*
    )?
;

dropTrigger:
    TRIGGER_SYMBOL ifExists? triggerRef
;

dropView:
    VIEW_SYMBOL ifExists? viewRefList (RESTRICT_SYMBOL | CASCADE_SYMBOL)?
;

dropRole:
    ROLE_SYMBOL ifExists? roleList
;

dropSpatialReference:
    SPATIAL_SYMBOL REFERENCE_SYMBOL SYSTEM_SYMBOL ifExists? real_ulonglong_number
;

dropUndoTablespace:
    UNDO_SYMBOL TABLESPACE_SYMBOL tablespaceRef undoTableSpaceOptions?
;

//----------------------------------------------------------------------------------------------------------------------