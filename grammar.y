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
%token NEWLINE
%token PLUS_EQUAL MINUS_EQUAL MUL_EQUAL DIV_EQUAL

%%

program:
	body
	;

body:
	| statement end_of_statement body
	| NEWLINE body
	| statement
	;

statement:
	variable_modification
	| condition_head
	| loop_declaration
	;

end_of_statement:
	NEWLINE
	| ';'
	;

loop_declaration:
	WHILE '(' expression ')' optional_newline '{' body '}'

condition_head:
	CONDITION_IF '(' logical_expr ')' optional_newline '{' body '}' condition_body
	;

condition_body:
	| condition_tail
	| NEWLINE condition_body
	| CONDITION_ELIF '(' logical_expr ')' optional_newline '{' body '}' condition_body

condition_tail:
	CONDITION_ELSE optional_newline '{' body '}'
	;

variable_modification:
	datatype IDENTIFIER '=' expression
	| CONSTANT datatype IDENTIFIER '=' expression
	| datatype '[' INTEGER ']' IDENTIFIER '=' expression
	| CONSTANT datatype '[' INTEGER ']' IDENTIFIER '=' expression
	| IDENTIFIER assignment_operator expression
	| IDENTIFIER '[' INTEGER ']' assignment_operator expression
	;
	
	/* TODO: allow only compiletime expressions for const values */

assignment_operator:
	PLUS_EQUAL
	| MINUS_EQUAL
	| MUL_EQUAL
	| DIV_EQUAL
	| '='
	;

expression:
	data_expr
	| '(' expression ')'
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
	| '(' math_expr ')'
	;

logical_expr:
	data_expr
	| '!' logical_expr
	| math_expr comparator math_expr
	| logical_expr logical_operation logical_expr
	| '(' logical_expr logical_operation logical_expr ')'
	| '(' logical_expr ')'
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

optional_newline:
	| NEWLINE optional_newline
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
