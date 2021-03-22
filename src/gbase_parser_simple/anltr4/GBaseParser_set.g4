parser grammar GBaseParser_set;

options {
//    superClass = MySQLBaseRecognizer;
    tokenVocab = GBaseLexer;
    exportMacro = PARSERS_PUBLIC_TYPE;
}

//----------------------------------------------------------------------------------------------------------------------

setStatement:
    SET_SYMBOL startOptionValueList
;

startOptionValueList:
    optionValueNoOptionType optionValueListContinued
    | TRANSACTION_SYMBOL transactionCharacteristics
    | optionType startOptionValueListFollowingOptionType
    | PASSWORD_SYMBOL (FOR_SYMBOL user)? equal (
        textString replacePassword? retainCurrentPassword?
        | textString replacePassword? retainCurrentPassword?
        | {status.serverVersion < 50706}? OLD_PASSWORD_SYMBOL OPEN_PAR_SYMBOL textString CLOSE_PAR_SYMBOL
        | {status.serverVersion < 80014}? PASSWORD_SYMBOL OPEN_PAR_SYMBOL textString CLOSE_PAR_SYMBOL
    )
    | {status.serverVersion >= 80018}? PASSWORD_SYMBOL (FOR_SYMBOL user)? TO_SYMBOL RANDOM_SYMBOL replacePassword? retainCurrentPassword?
;

transactionCharacteristics:
    transactionAccessMode isolationLevel?
    | isolationLevel (COMMA_SYMBOL transactionAccessMode)?
;

transactionAccessMode:
    READ_SYMBOL (WRITE_SYMBOL | ONLY_SYMBOL)
;

isolationLevel:
    ISOLATION_SYMBOL LEVEL_SYMBOL (
        REPEATABLE_SYMBOL READ_SYMBOL
        | READ_SYMBOL (COMMITTED_SYMBOL | UNCOMMITTED_SYMBOL)
        | SERIALIZABLE_SYMBOL
    )
;

optionValueListContinued:
    (COMMA_SYMBOL optionValue)*
;

optionValueNoOptionType:
    internalVariableName equal setExprOrDefault
    | charsetClause
    | userVariable equal expr
    | setSystemVariable equal setExprOrDefault
    | NAMES_SYMBOL (
        equal expr
        | charsetName collate?
        | {status.serverVersion >= 80011}? DEFAULT_SYMBOL
    )
;

optionValue:
    optionType internalVariableName equal setExprOrDefault
    | optionValueNoOptionType
;

setSystemVariable:
    AT_AT_SIGN_SYMBOL setVarIdentType? internalVariableName
;

startOptionValueListFollowingOptionType:
    optionValueFollowingOptionType optionValueListContinued
    | TRANSACTION_SYMBOL transactionCharacteristics
;

optionValueFollowingOptionType:
    internalVariableName equal setExprOrDefault
;

setExprOrDefault:
    expr
    | (DEFAULT_SYMBOL | ON_SYMBOL | ALL_SYMBOL | BINARY_SYMBOL)
    | {status.serverVersion >= 80000}? (ROW_SYMBOL | SYSTEM_SYMBOL)
;

//----------------------------------------------------------------------------------------------------------------------

