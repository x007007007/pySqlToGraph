# export CLASSPATH=".:/usr/local/lib/antlr-4.9.1-complete.jar:$CLASSPATH"
# alias antlr4='java -jar /usr/local/lib/antlr-4.9.1-complete.jar'
# alias grun='java org.antlr.v4.gui.TestRig'


build: GBaseLexer.py GBaseParser.py

GBaseLexer.py : GBaseLexer.g4 GBaseLexer_keyword.g4 GBaseLexer_symbol.g4
	CLASSPATH=".:/usr/local/lib/antlr-4.9.1-complete.jar:$CLASSPATH" java -jar /usr/local/lib/antlr-4.9.1-complete.jar -Dlanguage=Python3 GBaseLexer.g4

GBaseParser.py: GBaseParser.g4
	CLASSPATH=".:/usr/local/lib/antlr-4.9.1-complete.jar:$CLASSPATH" java -jar /usr/local/lib/antlr-4.9.1-complete.jar -Dlanguage=Python3 GBaseParser.g4
