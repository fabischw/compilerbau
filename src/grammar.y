%{
	#include<stdio.h>
	//#include "lex.yy.c"
	#include "../src/tree/tree.h"
	
	extern FILE* yyin;
	extern int yylineno; 
	extern int yyerror(const char *s);
	extern int yylex();

	Node* root;

%}

%union {
	struct _token_obj {
		char content[100];
		struct Node *node;
	} token_obj;
}

%token <token_obj> TYPE_INT TYPE_FLOAT TYPE_BOOL TYPE_STR TYPE_CHAR 
%token <token_obj> CONSTANT
%token <token_obj> IDENTIFIER
%token <token_obj> INTEGER FLOAT BOOLEAN STRING CHARACTER
%token <token_obj> OR AND
%token <token_obj> CONDITION_IF CONDITION_ELIF CONDITION_ELSE
%token <token_obj> WHILE
%token <token_obj> LESS_EQUAL GREATER_EQUAL IS_EQUAL NOT_EQUAL
%token <token_obj> NEWLINE
%token <token_obj> PLUS_EQUAL MINUS_EQUAL MUL_EQUAL DIV_EQUAL

%left OR
%left AND
%nonassoc IS_EQUAL NOT_EQUAL
%nonassoc LESS_EQUAL GREATER_EQUAL '<' '>'

%left '+' '-'
%left '*' '/' '%'
%right '^'

%nonassoc UNOT 
%nonassoc UMINUS

%%

program:
	body		{}
	;

body:
	| statement end_of_statement body
	| NEWLINE body
	| statement
	;
// note: body can be empty


statement:
	expression
	| variable_modification
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
	CONDITION_IF '(' expression ')' optional_newline '{' body '}' condition_body
	;

condition_body:
	| condition_tail
	| NEWLINE condition_body
	| CONDITION_ELIF '(' expression ')' optional_newline '{' body '}' condition_body

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
	'(' expression ')'
	| data_expr
	| math_expr
	| logical_expr
	| arr_expr
	| function_call_expr
	| IDENTIFIER
	| indexing_expr
	;

indexing_expr:
	expression '[' expression ']'

arr_expr:
	'[' arr_body ']'
	;

arr_body:
	| expression
	| arr_body ',' expression

// literally defined data
data_expr:
	INTEGER
	| FLOAT
	| BOOLEAN
	| STRING
	| CHARACTER
	;

function_call_expr:
	IDENTIFIER '(' parameter_list ')'
	| IDENTIFIER '(' ')'
	;

parameter_list:
	expression
	| parameter_list ',' expression
	;
// can be empty

	
math_expr:
	expression arithmetic_operator expression
	| '-' expression %prec UMINUS
	;

logical_expr:
	expression logical_operator expression
	| expression comparator expression
	| '!' expression %prec UNOT
	;

comparator:
	IS_EQUAL
	| NOT_EQUAL
	| LESS_EQUAL
	| GREATER_EQUAL
	| '<'
	| '>'
	;
	
logical_operator:
	AND
	| OR
	;

arithmetic_operator:
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
