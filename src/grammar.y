%{
    #include<stdio.h>
    #include<string.h>
    //#include "lex.yy.c"
    #include "../src/tree/tree.h"
    
    #define DP(s) printf("->%s\n", #s)

    extern FILE* yyin;
    extern int yylineno;
    extern int yyerror(const char *s);
    extern int yylex();

    Node* root;

%}

%union {
    struct _token_obj {
        char content[100];
        struct _node *node;
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
%token <token_obj> '=' '+' '-' '*' '/' '%' '^' '<' '>' '!' ','

%type <token_obj> program body statement loop_declaration condition_if condition_elif condition_else variable_declaration expression assignment_expr binary_expr unary_expr postfix_expr parameter_list primary_expr arr_expr arr_body datatype 

%left OR
%left AND
%nonassoc IS_EQUAL NOT_EQUAL
%nonassoc LESS_EQUAL GREATER_EQUAL '<' '>'

%left '=' PLUS_EQUAL MINUS_EQUAL MUL_EQUAL DIV_EQUAL
%left '+' '-'
%left '*' '/' '%'
%right '^'

%nonassoc UNOT 
%nonassoc UMINUS

%%

// -- general ---

program:
    body		{DP(program1); $$.node = $1.node; root = $$.node; }
    ;

body:
    | statement                             {DP(body3); $$.node = create_node("statement", $1.node, NULL); }
    | NEWLINE body                          {DP(body2); $$.node = $2.node; }
    | statement end_of_statement body		{DP(body1); $$.node = create_node("statement", $1.node, $3.node); }
    ;
// note: body can be empty

// -- statements --

statement:
    expression                      {DP(statement1); $$.node = $1.node; }
    | variable_declaration          {DP(statement2); $$.node = $1.node; }
    | condition_if                  {DP(statement3); $$.node = $1.node; }
    | loop_declaration              {DP(statement4); $$.node = $1.node; }
    ;

end_of_statement:
    NEWLINE
    | ';'
    ;

loop_declaration:
    WHILE '(' expression ')' optional_newline '{' body '}'      {DP(loop_declaration1); $$.node = create_node("while", $3.node, $7.node); }

condition_if:
    CONDITION_IF '(' expression ')' optional_newline '{' body '}' condition_elif        {DP(condition_if1); 
        Node *branch = create_node("if_content", $3.node, $7.node); $$.node = create_node("if", branch, $9.node); }
    ;

condition_elif:
    condition_else        {DP(condition_elif1); $$.node = $1.node; }
    | NEWLINE condition_elif        {DP(condition_elif2); $$.node = $2.node; }
    | CONDITION_ELIF '(' expression ')' optional_newline '{' body '}' condition_elif        {DP(condition_elif3); 
        Node *branch = create_node("elif_content", $3.node, $7.node); $$.node = create_node("elif", branch, $9.node); }

condition_else:
    | CONDITION_ELSE optional_newline '{' body '}'        {DP(condition_else1); $$.node = $4.node; }
    ;

variable_declaration:
    datatype IDENTIFIER '=' expression                                     {DP(variable_declaration1); 
        Node *identifier = create_node($2.content, NULL, NULL); 
        Node *var_dec_ass = create_node("type", $1.node, identifier); 
        $$.node = create_node("var_declaration", var_dec_ass, $4.node); }

    | CONSTANT datatype IDENTIFIER '=' expression                          {DP(variable_declaration2);
        Node *identifier = create_node($3.content, NULL, NULL); 
        Node *var_dec_ass = create_node("type", $2.node, identifier); 
        $$.node = create_node("var_declaration_const", var_dec_ass, $5.node); }

    | datatype '[' expression ']' IDENTIFIER '=' expression                {DP(variable_declaration3); 
        Node *identifier = create_node($5.content, $3.node, NULL); 
        Node *var_dec_ass = create_node("type", $1.node, identifier); 
        $$.node = create_node("var_declaration", var_dec_ass, $7.node); } 

    | CONSTANT datatype '[' expression ']' IDENTIFIER '=' expression       {DP(variable_declaration4); 
        Node *identifier = create_node($6.content, $4.node, NULL); 
        Node *var_dec_ass = create_node("type", $2.node, identifier); 
        $$.node = create_node("var_declaration_const", var_dec_ass, $8.node); } 
    ;
    
    /* TODO: allow only compiletime expressions for const values */

// -- expressions --

expression:
    assignment_expr     {DP(expression1); $$.node = $1.node; }
    ;

assignment_expr:
    binary_expr                                     {DP(assignment_expr1); $$.node = $1.node; }
    | postfix_expr PLUS_EQUAL assignment_expr       {DP(assignment_expr2); $$.node = create_node($2.content, $1.node, $3.node); }
    | postfix_expr MINUS_EQUAL assignment_expr      {DP(assignment_expr3); $$.node = create_node($2.content, $1.node, $3.node); }
    | postfix_expr MUL_EQUAL assignment_expr        {DP(assignment_expr4); $$.node = create_node($2.content, $1.node, $3.node); }
    | postfix_expr DIV_EQUAL assignment_expr        {DP(assignment_expr5); $$.node = create_node($2.content, $1.node, $3.node); }
    | postfix_expr '=' assignment_expr              {DP(assignment_expr6); $$.node = create_node($2.content, $1.node, $3.node); }
    ;


binary_expr:
    unary_expr                                  {DP(binary_expr1); $$.node = $1.node; }
    | binary_expr AND binary_expr               {DP(binary_expr2); $$.node = create_node($2.content, $1.node, $3.node); }
    | binary_expr OR binary_expr                {DP(binary_expr3); $$.node = create_node($2.content, $1.node, $3.node); }
    | binary_expr IS_EQUAL binary_expr          {DP(binary_expr4); $$.node = create_node($2.content, $1.node, $3.node); }
    | binary_expr LESS_EQUAL binary_expr        {DP(binary_expr5); $$.node = create_node($2.content, $1.node, $3.node); }
    | binary_expr GREATER_EQUAL binary_expr     {DP(binary_expr6); $$.node = create_node($2.content, $1.node, $3.node); }
    | binary_expr NOT_EQUAL binary_expr         {DP(binary_expr7); $$.node = create_node($2.content, $1.node, $3.node); }
    | binary_expr '<' binary_expr               {DP(binary_expr8); $$.node = create_node($2.content, $1.node, $3.node); }
    | binary_expr '>' binary_expr               {DP(binary_expr9); $$.node = create_node($2.content, $1.node, $3.node); }
    | binary_expr '+' binary_expr               {DP(binary_expr10); $$.node = create_node($2.content, $1.node, $3.node); }
    | binary_expr '-' binary_expr               {DP(binary_expr11); $$.node = create_node($2.content, $1.node, $3.node); }
    | binary_expr '*' binary_expr               {DP(binary_expr12); $$.node = create_node($2.content, $1.node, $3.node); }
    | binary_expr '/' binary_expr               {DP(binary_expr13); $$.node = create_node($2.content, $1.node, $3.node); }
    | binary_expr '^' binary_expr               {DP(binary_expr14); $$.node = create_node($2.content, $1.node, $3.node); }
    | binary_expr '%' binary_expr               {DP(binary_expr15); $$.node = create_node($2.content, $1.node, $3.node); }
    ;

unary_expr:
    postfix_expr            {DP(unary_expr1); $$.node = $1.node; }
    | '-' unary_expr        {DP(unary_expr2); $$.node = create_node($1.content, $2.node, NULL); }
    | '+' unary_expr        {DP(unary_expr3); $$.node = create_node($1.content, $2.node, NULL); }
    | '!' unary_expr        {DP(unary_expr4); $$.node = create_node($1.content, $2.node, NULL); }
    ;


postfix_expr:
    primary_expr                            {DP(postfix_expr1); $$.node = $1.node; }
    | postfix_expr '[' expression ']'       {DP(postfix_expr2); $$.node = create_node("indexing", $1.node, $3.node); } 
    | postfix_expr '(' parameter_list ')'    {DP(postfix_expr3); $$.node = create_node("function_call", $1.node, $3.node); }
    | postfix_expr '(' ')'                  {DP(postfix_expr4); $$.node = create_node("function_call", $1.node, NULL); }
    ;

parameter_list:
    assignment_expr                         {DP(parameter_list1); $$.node = create_node(",", $1.node, NULL); }
    | parameter_list ',' assignment_expr    {DP(parameter_list2); $$.node = create_node($2.content, $3.node, $1.node); }
    ;


// literally defined data
primary_expr:
    INTEGER                 {DP(primary_expr1); $$.node = create_node($1.content, NULL, NULL); }
    | arr_expr              {DP(primary_expr2); $$.node = $1.node; }
    | FLOAT                 {DP(primary_expr3); $$.node = create_node($1.content, NULL, NULL); }
    | BOOLEAN               {DP(primary_expr4); $$.node = create_node($1.content, NULL, NULL); }
    | STRING                {DP(primary_expr5); $$.node = create_node($1.content, NULL, NULL); }
    | CHARACTER             {DP(primary_expr6); $$.node = create_node($1.content, NULL, NULL); }
    | IDENTIFIER            {DP(primary_expr7); $$.node = create_node($1.content, NULL, NULL); }
    | '(' expression ')'    {DP(primary_expr8); $$.node = $2.node; }
    ;

arr_expr:
    '[' arr_body ']'        {DP(arr_expr1); $$.node = $2.node; }
    ;

arr_body:
    expression                      {DP(arr_body1); $$.node = create_node(",", $1.node, NULL); }
    | arr_body ',' expression       {DP(arr_body2); $$.node = create_node($2.content, $3.node, $1.node); }

datatype:
    TYPE_INT        {DP(datatype1); $$.node = create_node($1.content, NULL, NULL); }
    | TYPE_FLOAT    {DP(datatype2); $$.node = create_node($1.content, NULL, NULL); }
    | TYPE_BOOL     {DP(datatype3); $$.node = create_node($1.content, NULL, NULL); }
    | TYPE_STR      {DP(datatype4); $$.node = create_node($1.content, NULL, NULL); }
    | TYPE_CHAR     {DP(datatype5); $$.node = create_node($1.content, NULL, NULL); }
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
        traverse(root);
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
