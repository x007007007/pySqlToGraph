# export CLASSPATH=".:/usr/local/lib/antlr-4.9.1-complete.jar:$CLASSPATH"
# alias antlr4='java -jar /usr/local/lib/antlr-4.9.1-complete.jar'
# alias grun='java org.antlr.v4.gui.TestRig'


build: ../pygram/GBaseParser.py

../pygram/GBaseParser.py: GBaseParser.g4 \
    GBaseParser_account.g4  \
    GBaseParser_admin_other.g4  \
    GBaseParser_alter.g4  \
    GBaseParser_analysis.g4  \
    GBaseParser_base.g4  \
    GBaseParser_create.g4  \
    GBaseParser_clone.g4  \
    GBaseParser_dlm.g4  \
    GBaseParser_drop.g4  \
    GBaseParser_expr.g4  \
    GBaseParser_insert.g4  \
    GBaseParser_install.g4  \
    GBaseParser_load.g4  \
    GBaseParser_name_ref.g4  \
    GBaseParser_prepared.g4  \
    GBaseParser_rename.g4  \
    GBaseParser_replace.g4  \
    GBaseParser_replication.g4  \
    GBaseParser_resource_group.g4  \
    GBaseParser_routines.g4  \
    GBaseParser_select.g4  \
    GBaseParser_set.g4  \
    GBaseParser_show.g4  \
    GBaseParser_supplemental.g4  \
    GBaseParser_transaction.g4  \
    GBaseParser_update.g4  \
    GBaseParser_utility.g4
	CLASSPATH=".:/usr/local/lib/antlr-4.9.1-complete.jar:$CLASSPATH" \
 java -jar /usr/local/lib/antlr-4.9.1-complete.jar -Dlanguage=Python3 -listener -visitor -o ../pygram GBaseParser.g4 GBaseLexer.g4
