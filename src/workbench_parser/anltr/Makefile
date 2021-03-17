# export CLASSPATH=".:/usr/local/lib/antlr-4.9.1-complete.jar:$CLASSPATH"
# alias antlr4='java -jar /usr/local/lib/antlr-4.9.1-complete.jar'
# alias grun='java org.antlr.v4.gui.TestRig'


build: MySQLLexer.py MySQLParser.py

MySQLLexer.py : MySQLLexer.g4
	CLASSPATH=".:/usr/local/lib/antlr-4.9.1-complete.jar:$CLASSPATH" java -jar /usr/local/lib/antlr-4.9.1-complete.jar -Dlanguage=Python3 MySQLLexer.g4

MySQLParser.py: MySQLParser.g4
	CLASSPATH=".:/usr/local/lib/antlr-4.9.1-complete.jar:$CLASSPATH" java -jar /usr/local/lib/antlr-4.9.1-complete.jar -Dlanguage=Python3 MySQLParser.g4
