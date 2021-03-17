# export CLASSPATH=".:/usr/local/lib/antlr-4.9.1-complete.jar:$CLASSPATH"
# alias antlr4='java -jar /usr/local/lib/antlr-4.9.1-complete.jar'
# alias grun='java org.antlr.v4.gui.TestRig'


build: GBaseSQLToken.py GBaseSQL.py

GBaseSQLToken.py: GBaseSQLToken.g4
	CLASSPATH=".:/usr/local/lib/antlr-4.9.1-complete.jar:$CLASSPATH" java -jar /usr/local/lib/antlr-4.9.1-complete.jar -Dlanguage=Python3 GBaseSQLToken.g4

GBaseSQL.py : GBaseSQL.g4
	CLASSPATH=".:/usr/local/lib/antlr-4.9.1-complete.jar:$CLASSPATH" java -jar /usr/local/lib/antlr-4.9.1-complete.jar -Dlanguage=Python3 GBaseSQL.g4


