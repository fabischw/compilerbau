all: think

think: lex.yy.c
	gcc lex.yy.c grammar.tab.c -o think

lex.yy.c: grammar.tab.c lexxer.l
	flex lexxer.l

grammar.tab.c:
	bison -d grammar.y
