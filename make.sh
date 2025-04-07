#/bin/sh

bison -d grammar.y
flex lexxer.l

gcc lex.yy.c grammar.tab.c
rm lex.yy.c grammar.tab.c grammar.tab.h 
