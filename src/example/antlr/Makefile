# export CLASSPATH=".:/usr/local/lib/antlr-4.9.1-complete.jar:$CLASSPATH"
# alias antlr4='java -jar /usr/local/lib/antlr-4.9.1-complete.jar'
# alias grun='java org.antlr.v4.gui.TestRig'


build: GBaseSQLLexer.py GBaseSQLParser.py

GBaseSQLLexer.py: GBaseSQLLexer.g4 GBaseSQLLexer_symbol.g4 GBaseSQLLexer_frag.g4 GBaseSQLLexer_keyword.g4
	CLASSPATH=".:/usr/local/lib/antlr-4.9.1-complete.jar:$CLASSPATH" java -jar /usr/local/lib/antlr-4.9.1-complete.jar -Dlanguage=Python3 GBaseSQLLexer.g4

GBaseSQLParser.py : GBaseSQLParser.g4 GBaseSQLParser_base1.g4
	CLASSPATH=".:/usr/local/lib/antlr-4.9.1-complete.jar:$CLASSPATH" java -jar /usr/local/lib/antlr-4.9.1-complete.jar -Dlanguage=Python3 GBaseSQLParser.g4


