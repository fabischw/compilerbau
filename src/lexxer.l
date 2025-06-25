%option noyywrap

%{
	#include <stdbool.h>
	#include "../src/typing/typing.h"
    #include "../src/tree/tree.h"
    #include "../src/linked_list/linked_list.h"
	#include "../src/tree/ast_type.h"
	#include "grammar.tab.h"
	extern int yyerror(const char* s);
	int yylineno;	
	int yylex();
%}

%option yylineno

digit [0-9]
alpha [a-zA-Z]
alphap [_a-zA-Z]

%% 

#[^\n]* ;

\"([^\"\\\n]|\\.)*\"        { strcpy(yylval.token_obj.content, (yytext)); return (STRING); }
\'.?\'                      { strcpy(yylval.token_obj.content, (yytext)); return (CHARACTER); }

{digit}+                    { strcpy(yylval.token_obj.content, (yytext)); return (INTEGER);  }
{digit}*\.{digit}*          { strcpy(yylval.token_obj.content, (yytext)); return (FLOAT); }

(True|False)                { strcpy(yylval.token_obj.content, (yytext)); return (BOOLEAN); }

"if"                        { strcpy(yylval.token_obj.content, (yytext)); return (CONDITION_IF); }
"elif"                      { strcpy(yylval.token_obj.content, (yytext)); return (CONDITION_ELIF); }
"else"                      { strcpy(yylval.token_obj.content, (yytext)); return (CONDITION_ELSE); }
"int"                       { strcpy(yylval.token_obj.content, (yytext)); return (TYPE_INT); }
"while"                     { strcpy(yylval.token_obj.content, (yytext)); return (WHILE); }
"float"                     { strcpy(yylval.token_obj.content, (yytext)); return (TYPE_FLOAT); }
"bool"                      { strcpy(yylval.token_obj.content, (yytext)); return (TYPE_BOOL); }
"str"                       { strcpy(yylval.token_obj.content, (yytext)); return (TYPE_STR); }
"char"                      { strcpy(yylval.token_obj.content, (yytext)); return (TYPE_CHAR); }
"const"                     { strcpy(yylval.token_obj.content, (yytext)); return (CONSTANT); }

"||"                        { strcpy(yylval.token_obj.content, (yytext)); return (OR); }
"&&"                        { strcpy(yylval.token_obj.content, (yytext)); return (AND); }
"=="                        { strcpy(yylval.token_obj.content, (yytext)); return (IS_EQUAL); }
"!="                        { strcpy(yylval.token_obj.content, (yytext)); return (NOT_EQUAL); }
"<="                        { strcpy(yylval.token_obj.content, (yytext)); return (LESS_EQUAL); }
">="                        { strcpy(yylval.token_obj.content, (yytext)); return (GREATER_EQUAL); }
"+="                        { strcpy(yylval.token_obj.content, (yytext)); return (PLUS_EQUAL); }
"-="                        { strcpy(yylval.token_obj.content, (yytext)); return (MINUS_EQUAL); }
"*="                        { strcpy(yylval.token_obj.content, (yytext)); return (MUL_EQUAL); }
"/="                        { strcpy(yylval.token_obj.content, (yytext)); return (DIV_EQUAL); }
"="                         { strcpy(yylval.token_obj.content, (yytext)); return (EQUAL); }
"<"                         { strcpy(yylval.token_obj.content, (yytext)); return (LESS); }
">"                         { strcpy(yylval.token_obj.content, (yytext)); return (GREATER); }
"+"                         { strcpy(yylval.token_obj.content, (yytext)); return (PLUS); }
"-"                         { strcpy(yylval.token_obj.content, (yytext)); return (MINUS); }
"*"                         { strcpy(yylval.token_obj.content, (yytext)); return (MULT); }
"/"                         { strcpy(yylval.token_obj.content, (yytext)); return (DIV); }
"^"                         { strcpy(yylval.token_obj.content, (yytext)); return (EXP); }
"%"                         { strcpy(yylval.token_obj.content, (yytext)); return (MODULO); }
"("                         { strcpy(yylval.token_obj.content, (yytext)); return ('('); }
")"                         { strcpy(yylval.token_obj.content, (yytext)); return (')'); }
"{"                         { strcpy(yylval.token_obj.content, (yytext)); return ('{'); }
"}"                         { strcpy(yylval.token_obj.content, (yytext)); return ('}'); }
"["                         { strcpy(yylval.token_obj.content, (yytext)); return ('['); }
"]"                         { strcpy(yylval.token_obj.content, (yytext)); return (']'); }
","                         { strcpy(yylval.token_obj.content, (yytext)); return (','); }
"!"                         { strcpy(yylval.token_obj.content, (yytext)); return (BANG); }


{alphap}({alphap}|{digit})*   { strcpy(yylval.token_obj.content, (yytext)); return (IDENTIFIER); }


[ \t] ;
[\r\n;\t ]+						{ return (SEPERATOR); }

. {yyerror("unknown symbol"); };

%%
