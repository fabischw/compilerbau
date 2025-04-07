%option noyywrap

%{
	#include "grammar.tab.h"
	extern int yyerror(const char* s);
	int yylineno;	
	int yylex();
	
%}

digit [0-9]
alpha [a-zA-Z]

%% 

"if" return (CONDITION_IF);
"elif" return (CONDITION_ELIF);
"else" return (CONDITION_ELSE);
"int" return (TYPE_INT);
"while" return (WHILE);
"float" return (TYPE_FLOAT);
"bool" return (TYPE_BOOL);
"str" return (TYPE_STR);
"char" return (TYPE_CHAR);
"const" return (CONSTANT);

(True|False) return (BOOLEAN);
{alpha}({alpha}|{digit})* return (IDENTIFIER);

{digit}+ return (INTEGER); 
{digit}*\.{digit}* return (FLOAT);
\"[^\"\\n]*\" return (STRING);
\'.?\' return (CHARACTER);

"||" return (OR);
"&&" return (AND);
"==" return (IS_EQUAL);
"<=" return (LESS_EQUAL);
">=" return (GREATER_EQUAL);
"=" return ('=');
"<" return ('<');
">" return ('>');
"+" return ('+');
"-" return ('-');
"*" return ('*');
"/" return ('/');
"^" return ('^');
"%" return ('%');
"(" return ('(');
")" return (')');
"{" return ('{');
"}" return ('}');
"[" return ('[');
"]" return (']');
"," return (',');
"!" return ('!');
";" return (';');

[\n]    { yylineno++; return (NEWLINE);}
#[^\n]* ;
[ \t] ;
. {yyerror("unknown symbol"); };

%%
