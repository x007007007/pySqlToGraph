parser grammar GBaseParser_account;

options {
//    superClass = MySQLBaseRecognizer;
    tokenVocab = GBaseLexer;
    exportMacro = PARSERS_PUBLIC_TYPE;
}


//----------------------------------------------------------------------------------------------------------------------

// Note: SET PASSWORD is part of the SET statement.
accountManagementStatement:
    {status.serverVersion >= 50606}? alterUser
    | createUser
    | dropUser
    | grant
    | renameUser
    | revoke
    | {status.serverVersion >= 80000}? setRole
;

alterUser:
    ALTER_SYMBOL USER_SYMBOL ({status.serverVersion >= 50706}? ifExists)? alterUserTail
;

alterUserTail:
    ({status.serverVersion < 80014}? createUserList | {status.serverVersion >= 80014}? alterUserList) createUserTail
    | {status.serverVersion >= 50706}? user IDENTIFIED_SYMBOL BY_SYMBOL textString (
        {status.serverVersion >= 80014}? replacePassword
    )? ({status.serverVersion >= 80014}? retainCurrentPassword)?
    | {status.serverVersion >= 80014}? user discardOldPassword
    | {status.serverVersion >= 80000}? user DEFAULT_SYMBOL ROLE_SYMBOL (
        ALL_SYMBOL
        | NONE_SYMBOL
        | roleList
    )
    | {status.serverVersion >= 80018}? user IDENTIFIED_SYMBOL (WITH_SYMBOL textOrIdentifier)? BY_SYMBOL RANDOM_SYMBOL
        PASSWORD_SYMBOL retainCurrentPassword?
    | FAILED_LOGIN_ATTEMPTS_SYMBOL real_ulong_number
    | PASSWORD_LOCK_TIME_SYMBOL (real_ulong_number | UNBOUNDED_SYMBOL)
;

userFunction:
    USER_SYMBOL parentheses
;

createUser:
    CREATE_SYMBOL USER_SYMBOL ({status.serverVersion >= 50706}? ifNotExists | /* empty */) createUserList defaultRoleClause
        createUserTail
;

createUserTail:
    {status.serverVersion >= 50706}? requireClause? connectOptions? accountLockPasswordExpireOptions*
    | /* empty */
;

defaultRoleClause:
    {status.serverVersion >= 80000}? (DEFAULT_SYMBOL ROLE_SYMBOL roleList)?
    | /* empty */
;

requireClause:
    REQUIRE_SYMBOL (requireList | option = (SSL_SYMBOL | X509_SYMBOL | NONE_SYMBOL))
;

connectOptions:
    WITH_SYMBOL (
        MAX_QUERIES_PER_HOUR_SYMBOL ulong_number
        | MAX_UPDATES_PER_HOUR_SYMBOL ulong_number
        | MAX_CONNECTIONS_PER_HOUR_SYMBOL ulong_number
        | MAX_USER_CONNECTIONS_SYMBOL ulong_number
    )+
;

accountLockPasswordExpireOptions:
    ACCOUNT_SYMBOL (LOCK_SYMBOL | UNLOCK_SYMBOL)
    | PASSWORD_SYMBOL (
        EXPIRE_SYMBOL (
            INTERVAL_SYMBOL real_ulong_number DAY_SYMBOL
            | NEVER_SYMBOL
            | DEFAULT_SYMBOL
        )?
        | HISTORY_SYMBOL (real_ulong_number | DEFAULT_SYMBOL)
        | REUSE_SYMBOL INTERVAL_SYMBOL (
            real_ulong_number DAY_SYMBOL
            | DEFAULT_SYMBOL
        )
        | {status.serverVersion >= 80014}? REQUIRE_SYMBOL CURRENT_SYMBOL (
            DEFAULT_SYMBOL
            | OPTIONAL_SYMBOL
        )?
    )
;

dropUser:
    DROP_SYMBOL USER_SYMBOL ({status.serverVersion >= 50706}? ifExists)? userList
;

grant:
    GRANT_SYMBOL (
        {status.serverVersion >= 80000}? roleOrPrivilegesList TO_SYMBOL userList (
            WITH_SYMBOL ADMIN_SYMBOL OPTION_SYMBOL
        )?
        | (roleOrPrivilegesList | ALL_SYMBOL PRIVILEGES_SYMBOL?) ON_SYMBOL aclType? grantIdentifier TO_SYMBOL grantTargetList
            versionedRequireClause? grantOptions? grantAs?
        | PROXY_SYMBOL ON_SYMBOL user TO_SYMBOL grantTargetList (
            WITH_SYMBOL GRANT_SYMBOL OPTION_SYMBOL
        )?
    )
;

grantTargetList:
    {status.serverVersion < 80011}? createUserList
    | {status.serverVersion >= 80011}? userList
;

grantOptions:
    {status.serverVersion < 80011}? WITH_SYMBOL grantOption+
    | {status.serverVersion >= 80011}? WITH_SYMBOL GRANT_SYMBOL OPTION_SYMBOL
;

exceptRoleList:
    EXCEPT_SYMBOL roleList
;

withRoles:
    WITH_SYMBOL ROLE_SYMBOL (
        roleList
        | ALL_SYMBOL exceptRoleList?
        | NONE_SYMBOL
        | DEFAULT_SYMBOL
    )
;

grantAs:
    AS_SYMBOL USER_SYMBOL withRoles?
;

versionedRequireClause:
    {status.serverVersion < 80011}? requireClause
;

renameUser:
    RENAME_SYMBOL USER_SYMBOL user TO_SYMBOL user (COMMA_SYMBOL user TO_SYMBOL user)*
;

revoke:
    REVOKE_SYMBOL (
        {status.serverVersion >= 80000}? roleOrPrivilegesList FROM_SYMBOL userList
        | roleOrPrivilegesList onTypeTo FROM_SYMBOL userList
        | ALL_SYMBOL PRIVILEGES_SYMBOL? (
            {status.serverVersion >= 80000}? ON_SYMBOL aclType? grantIdentifier
            | COMMA_SYMBOL GRANT_SYMBOL OPTION_SYMBOL FROM_SYMBOL userList
        )
        | PROXY_SYMBOL ON_SYMBOL user FROM_SYMBOL userList
    )
;

onTypeTo: // Optional, starting with 8.0.1.
    {status.serverVersion < 80000}? ON_SYMBOL aclType? grantIdentifier
    | {status.serverVersion >= 80000}? (ON_SYMBOL aclType? grantIdentifier)?
;

aclType:
    TABLE_SYMBOL
    | FUNCTION_SYMBOL
    | PROCEDURE_SYMBOL
;

roleOrPrivilegesList:
    roleOrPrivilege (COMMA_SYMBOL roleOrPrivilege)*
;

roleOrPrivilege:
    {status.serverVersion > 80000}? (
        roleIdentifierOrText columnInternalRefList?
        | roleIdentifierOrText (AT_TEXT_SUFFIX | AT_SIGN_SYMBOL textOrIdentifier)
    )
    | (SELECT_SYMBOL | INSERT_SYMBOL | UPDATE_SYMBOL | REFERENCES_SYMBOL) columnInternalRefList?
    | (
        DELETE_SYMBOL
        | USAGE_SYMBOL
        | INDEX_SYMBOL
        | DROP_SYMBOL
        | EXECUTE_SYMBOL
        | RELOAD_SYMBOL
        | SHUTDOWN_SYMBOL
        | PROCESS_SYMBOL
        | FILE_SYMBOL
        | PROXY_SYMBOL
        | SUPER_SYMBOL
        | EVENT_SYMBOL
        | TRIGGER_SYMBOL
    )
    | GRANT_SYMBOL OPTION_SYMBOL
    | SHOW_SYMBOL DATABASES_SYMBOL
    | CREATE_SYMBOL (
        TEMPORARY_SYMBOL the_object = TABLES_SYMBOL
        | the_object = (ROUTINE_SYMBOL | TABLESPACE_SYMBOL | USER_SYMBOL | VIEW_SYMBOL)
    )?
    | LOCK_SYMBOL TABLES_SYMBOL
    | REPLICATION_SYMBOL the_object = (CLIENT_SYMBOL | SLAVE_SYMBOL)
    | SHOW_SYMBOL VIEW_SYMBOL
    | ALTER_SYMBOL ROUTINE_SYMBOL?
    | {status.serverVersion > 80000}? (CREATE_SYMBOL | DROP_SYMBOL) ROLE_SYMBOL
;

grantIdentifier:
    MULT_OPERATOR (DOT_SYMBOL MULT_OPERATOR)?
    | schemaRef (DOT_SYMBOL MULT_OPERATOR)?
    | tableRef
    | {status.serverVersion >= 80017}? schemaRef DOT_SYMBOL tableRef
;

requireList:
    requireListElement (AND_SYMBOL? requireListElement)*
;

requireListElement:
    element = CIPHER_SYMBOL textString
    | element = ISSUER_SYMBOL textString
    | element = SUBJECT_SYMBOL textString
;

grantOption:
    option = GRANT_SYMBOL OPTION_SYMBOL
    | option = MAX_QUERIES_PER_HOUR_SYMBOL ulong_number
    | option = MAX_UPDATES_PER_HOUR_SYMBOL ulong_number
    | option = MAX_CONNECTIONS_PER_HOUR_SYMBOL ulong_number
    | option = MAX_USER_CONNECTIONS_SYMBOL ulong_number
;

setRole:
    SET_SYMBOL ROLE_SYMBOL roleList
    | SET_SYMBOL ROLE_SYMBOL (NONE_SYMBOL | DEFAULT_SYMBOL)
    | SET_SYMBOL DEFAULT_SYMBOL ROLE_SYMBOL (roleList | NONE_SYMBOL | ALL_SYMBOL) TO_SYMBOL roleList
    | SET_SYMBOL ROLE_SYMBOL ALL_SYMBOL (EXCEPT_SYMBOL roleList)?
;

roleList:
    role (COMMA_SYMBOL role)*
;

role:
    roleIdentifierOrText (AT_SIGN_SYMBOL textOrIdentifier | AT_TEXT_SUFFIX)?
;

//----------------------------------------------------------------------------------------------------------------------

