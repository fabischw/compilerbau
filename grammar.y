%{
	#include<stdio.h>
	
	extern FILE* yyin;
	extern int yylineno; 
	extern int yyerror(const char *s);
	extern int yylex();
%}

%token TYPE_INT TYPE_FLOAT TYPE_BOOL TYPE_STR TYPE_CHAR 
%token CONSTANT
%token IDENTIFIER
%token INTEGER FLOAT BOOLEAN STRING CHARACTER
%token OR AND
%token CONDITION_IF CONDITION_ELIF CONDITION_ELSE
%token WHILE
%token LESS_EQUAL GREATER_EQUAL IS_EQUAL

%%

program:
	body
	;

body:
	| variable_declaration body
	| condition_declaration body
	| variable_changing body
	| loop_declaration body
	;

loop_declaration:
	WHILE '(' logical_expr ')' '{' body '}'

variable_changing:
	IDENTIFIER '=' expression
	| IDENTIFIER '[' INTEGER ']' '=' expression
	;

condition_declaration:
	CONDITION_IF '(' logical_expr ')' '{' body '}'
	| CONDITION_IF '(' logical_expr ')' '{' body '}' CONDITION_ELSE '{' body '}'
	| CONDITION_IF '(' logical_expr ')' '{' body '}' CONDITION_ELIF '(' logical_expr ')' '{' body '}'
	| CONDITION_IF '(' logical_expr ')' '{' body '}' CONDITION_ELIF '(' logical_expr ')' '{' body '}' CONDITION_ELSE '{' body '}'
	;
	/* add elif  + elif else */

variable_declaration:
	datatype IDENTIFIER '=' expression
	| CONSTANT datatype IDENTIFIER '=' expression
	| datatype '[' INTEGER ']' IDENTIFIER '=' expression
	| CONSTANT '[' INTEGER ']' IDENTIFIER '=' expression
	;
/* const only comptime stuff */

expression:
	data_expr
	| math_expr
	| logical_expr
	| arr_expr
	;

arr_expr:
	'[' arr_body ']'
	;

arr_body:
	data_expr
	| data_expr ',' arr_body

data_expr:
	INTEGER
	| FLOAT
	| BOOLEAN
	| STRING
	| CHARACTER
	| IDENTIFIER
	;

math_expr:
	data_expr
	| '-' data_expr
	| math_expr operation math_expr
	| '(' math_expr operation math_expr ')'
	;

logical_expr:
	data_expr
	| logical_expr comparator logical_expr
	| '!' logical_expr
	| logical_expr logical_operation logical_expr
	| '(' logical_expr logical_operation logical_expr ')'
	;

comparator:
	IS_EQUAL
	| LESS_EQUAL
	| GREATER_EQUAL
	| '<'
	| '>'
	;

	
logical_operation:
	AND
	| OR
	;

operation:
	'+'
	| '-'
	| '*'
	| '/'
	| '^'
	| '%'
	;

datatype:
	TYPE_INT
	| TYPE_FLOAT
	| TYPE_BOOL
	| TYPE_STR
	| TYPE_CHAR
	;

%%

int
main(int argc, char** argv)
{
	if(argc == 2)
	{
		yyin = fopen(argv[1], "r");
		yyparse();
		fclose(yyin);
	}
	else {
    	printf (">>> Please type in any input:\n");
    	yyparse();
	}
    return 0;
}

int
yyerror(const char* s)
{
	fprintf(stderr, "Error in line: %d, %s\n", yylineno, s);
	return 1;
}
