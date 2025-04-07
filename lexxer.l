%option noyywrap

%{
	#include "grammar.tab.h"
	extern int yyerror(const char* s);
	int yylineno;	
	int yylex();
	
%}

%% 

(True|False) return (BOOLEAN);
int return (TYPE_INT);
float return (TYPE_FLOAT);
bool return (TYPE_BOOL);
str return (TYPE_STR);
char return (TYPE_CHAR);
const return (CONSTANT);

if return (CONDITION_IF);
elif return (CONDITION_ELIF);
else return (CONDITION_ELSE);

while return (WHILE);

[a-zA-Z]+ return (IDENTIFIER);

[0-9]+ return (INTEGER); 
[1-9][0-9]*\.[0-9]*|[0-9]\.[0-9]* return (FLOAT);
\"[^\"\\n]*\" return (STRING);
\'.\' return (CHARACTER);

\|\| return (OR);
\&\& return (AND);
== return (IS_EQUAL);
[<=] return (LESS_EQUAL);
[>=] return (GREATER_EQUAL);
[^=<>]=[^=] return ('=');
\<[^=] return ('<');
\>[^=] return ('>');

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

[\n]    { yylineno++; }
#[^\n]* ;
[ \t] ;
. {yyerror("unknown symbol"); };

%%
