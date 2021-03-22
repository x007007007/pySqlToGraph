parser grammar GBaseParser_install;

options {
//    superClass = MySQLBaseRecognizer;
    tokenVocab = GBaseLexer;
    exportMacro = PARSERS_PUBLIC_TYPE;
}

//----------------------------------------------------------------------------------------------------------------------

installUninstallStatment:
    // COMPONENT_SYMBOL is conditionally set in the lexer.
    action = INSTALL_SYMBOL the_type = PLUGIN_SYMBOL identifier SONAME_SYMBOL textStringLiteral
    | action = INSTALL_SYMBOL the_type = COMPONENT_SYMBOL textStringLiteralList
    | action = UNINSTALL_SYMBOL the_type = PLUGIN_SYMBOL pluginRef
    | action = UNINSTALL_SYMBOL the_type = COMPONENT_SYMBOL componentRef (
        COMMA_SYMBOL componentRef
    )*
;

//----------------------------------------------------------------------------------------------------------------------