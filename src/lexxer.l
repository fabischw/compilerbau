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

(True|False)                { strcpy(yylval.token_obj.content, (yytext)); return (BOOLEAN); }
{alpha}({alpha}|{digit})*   { strcpy(yylval.token_obj.content, (yytext)); return (IDENTIFIER); }

{digit}+                    { strcpy(yylval.token_obj.content, (yytext)); return (INTEGER);  }
{digit}*\.{digit}*          { strcpy(yylval.token_obj.content, (yytext)); return (FLOAT); }
\"[^\"\\n]*\"               { strcpy(yylval.token_obj.content, (yytext)); return (STRING); }
\'.?\'                      { strcpy(yylval.token_obj.content, (yytext)); return (CHARACTER); }

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
"="                         { strcpy(yylval.token_obj.content, (yytext)); return ('='); }
"<"                         { strcpy(yylval.token_obj.content, (yytext)); return ('<'); }
">"                         { strcpy(yylval.token_obj.content, (yytext)); return ('>'); }
"+"                         { strcpy(yylval.token_obj.content, (yytext)); return ('+'); }
"-"                         { strcpy(yylval.token_obj.content, (yytext)); return ('-'); }
"*"                         { strcpy(yylval.token_obj.content, (yytext)); return ('*'); }
"/"                         { strcpy(yylval.token_obj.content, (yytext)); return ('/'); }
"^"                         { strcpy(yylval.token_obj.content, (yytext)); return ('^'); }
"%"                         { strcpy(yylval.token_obj.content, (yytext)); return ('%'); }
"("                         { strcpy(yylval.token_obj.content, (yytext)); return ('('); }
")"                         { strcpy(yylval.token_obj.content, (yytext)); return (')'); }
"{"                         { strcpy(yylval.token_obj.content, (yytext)); return ('{'); }
"}"                         { strcpy(yylval.token_obj.content, (yytext)); return ('}'); }
"["                         { strcpy(yylval.token_obj.content, (yytext)); return ('['); }
"]"                         { strcpy(yylval.token_obj.content, (yytext)); return (']'); }
","                         { strcpy(yylval.token_obj.content, (yytext)); return (','); }
"!"                         { strcpy(yylval.token_obj.content, (yytext)); return ('!'); }
";"                         { strcpy(yylval.token_obj.content, (yytext)); return (';'); }

[\n]                        { yylineno++; return (NEWLINE); }
#[^\n]* ;
[ \t] ;
. {yyerror("unknown symbol"); };

%%
