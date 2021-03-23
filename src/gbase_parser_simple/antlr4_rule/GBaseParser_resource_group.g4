parser grammar GBaseParser_resource_group;

options {
//    superClass = MySQLBaseRecognizer;
    tokenVocab = GBaseLexer;
    exportMacro = PARSERS_PUBLIC_TYPE;
}

//----------------------------------------------------------------------------------------------------------------------

resourceGroupManagement:
    createResourceGroup
    | alterResourceGroup
    | setResourceGroup
    | dropResourceGroup
;

createResourceGroup:
    CREATE_SYMBOL RESOURCE_SYMBOL GROUP_SYMBOL identifier TYPE_SYMBOL equal? (
        USER_SYMBOL
        | SYSTEM_SYMBOL
    ) resourceGroupVcpuList? resourceGroupPriority? resourceGroupEnableDisable?
;

resourceGroupVcpuList:
    VCPU_SYMBOL equal? vcpuNumOrRange (COMMA_SYMBOL? vcpuNumOrRange)*
;

vcpuNumOrRange:
    INT_NUMBER (MINUS_OPERATOR INT_NUMBER)?
;

resourceGroupPriority:
    THREAD_PRIORITY_SYMBOL equal? INT_NUMBER
;

resourceGroupEnableDisable:
    ENABLE_SYMBOL
    | DISABLE_SYMBOL
;

alterResourceGroup:
    ALTER_SYMBOL RESOURCE_SYMBOL GROUP_SYMBOL resourceGroupRef resourceGroupVcpuList? resourceGroupPriority?
        resourceGroupEnableDisable? FORCE_SYMBOL?
;

setResourceGroup:
    SET_SYMBOL RESOURCE_SYMBOL GROUP_SYMBOL identifier (FOR_SYMBOL threadIdList)?
;

threadIdList:
    real_ulong_number (COMMA_SYMBOL? real_ulong_number)*
;

dropResourceGroup:
    DROP_SYMBOL RESOURCE_SYMBOL GROUP_SYMBOL resourceGroupRef FORCE_SYMBOL?
;

//----------------------------------------------------------------------------------------------------------------------

