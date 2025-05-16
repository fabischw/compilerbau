%debug

%{
    #include<stdio.h>
    #include<string.h>
    #include<stdbool.h>
    #include "../src/tree/tree.h"
    #include "../src/typing/typing.h"
    #include "../src/linked_list/linked_list.h"
    
    //#define DP(s) /*printf("->%s\n", #s)*/
    #define DP(s) (1)



    extern FILE* yyin;
    extern int yylineno;
    extern int yyerror(const char *s);
    extern int yylex();


    T_Node* root;

    int error_count = 0;

%}

%union {
    struct _token_obj {
        char content[100];
        T_Node *node;
        VarType type;
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
                                            {DP(body0); $$.node = NULL; }
    | statement                             {DP(body1); $$.node = t_create_node("statement", $1.node, NULL); }
    | NEWLINE body                          {DP(body2); $$.node = $2.node; }
    | statement end_of_statement body		{DP(body3); $$.node = t_create_node("statement", $1.node, $3.node); }
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
    WHILE '(' expression ')' optional_newline '{' body '}'      {DP(loop_declaration1); $$.node = t_create_node("while", $3.node, $7.node); }

condition_if:
    CONDITION_IF '(' expression ')' optional_newline '{' body '}' condition_elif        {DP(condition_if1); 
        T_Node *branch = t_create_node("if_content", $3.node, $7.node); $$.node = t_create_node("if", branch, $9.node); }
    ;

condition_elif:
    condition_else        {DP(condition_elif1); $$.node = $1.node; }
    | NEWLINE condition_elif        {DP(condition_elif2); $$.node = $2.node; }
    | CONDITION_ELIF '(' expression ')' optional_newline '{' body '}' condition_elif        {DP(condition_elif3); 
        T_Node *branch = t_create_node("elif_content", $3.node, $7.node); $$.node = t_create_node("elif", branch, $9.node); }

condition_else:
                                                          {DP(condition_else0); $$.node = NULL; }
    | CONDITION_ELSE optional_newline '{' body '}'        {DP(condition_else1); $$.node = $4.node; }
    ;

variable_declaration:
    datatype IDENTIFIER '=' expression                                     {DP(variable_declaration1); 
        T_Node *identifier = t_create_node($2.content, NULL, NULL); 
        T_Node *var_dec_ass = t_create_node("type", $1.node, identifier); 
        $$.node = t_create_node("var_declaration", var_dec_ass, $4.node); }

    | CONSTANT datatype IDENTIFIER '=' expression                          {DP(variable_declaration2);
        T_Node *identifier = t_create_node($3.content, NULL, NULL); 
        T_Node *var_dec_ass = t_create_node("type", $2.node, identifier); 
        $$.node = t_create_node("var_declaration_const", var_dec_ass, $5.node); }

    | datatype '[' expression ']' IDENTIFIER '=' expression                {DP(variable_declaration3);
        T_Node *identifier = t_create_node($5.content, $3.node, NULL); 
        T_Node *var_dec_ass = t_create_node("type", $1.node, identifier); 
        $$.node = t_create_node("var_declaration", var_dec_ass, $7.node); } 

    | CONSTANT datatype '[' expression ']' IDENTIFIER '=' expression       {DP(variable_declaration4); 
        T_Node *identifier = t_create_node($6.content, $4.node, NULL); 
        T_Node *var_dec_ass = t_create_node("type", $2.node, identifier); 
        $$.node = t_create_node("var_declaration_const", var_dec_ass, $8.node); } 
    ;
    
    /* TODO: allow only compiletime expressions for const values */

// -- expressions --

expression:
    assignment_expr     {DP(expression1); $$.node = $1.node; }
    ;

assignment_expr:
    binary_expr                                     {DP(assignment_expr1); $$.node = $1.node; }
    | IDENTIFIER PLUS_EQUAL assignment_expr       {DP(assignment_expr2); 
        T_Node *identifier = t_create_node($1.content, NULL, NULL); 
        $$.node = t_create_node($2.content, identifier, $3.node); }
    | IDENTIFIER MINUS_EQUAL assignment_expr      {DP(assignment_expr3); 
        T_Node *identifier = t_create_node($1.content, NULL, NULL); 
        $$.node = t_create_node($2.content, identifier, $3.node); }
    | IDENTIFIER MUL_EQUAL assignment_expr        {DP(assignment_expr4); 
        T_Node *identifier = t_create_node($1.content, NULL, NULL); 
        $$.node = t_create_node($2.content, identifier, $3.node); }
    | IDENTIFIER DIV_EQUAL assignment_expr        {DP(assignment_expr5); 
        T_Node *identifier = t_create_node($1.content, NULL, NULL); 
        $$.node = t_create_node($2.content, identifier, $3.node); }
    | IDENTIFIER '=' assignment_expr              {DP(assignment_expr6); 
        T_Node *identifier = t_create_node($1.content, NULL, NULL); 
        $$.node = t_create_node($2.content, identifier, $3.node); }

    | IDENTIFIER '[' expression ']' PLUS_EQUAL assignment_expr       {DP(assignment_expr2); 
        T_Node *identifier = t_create_node($1.content, $3.node, NULL); 
        $$.node = t_create_node($5.content, identifier, $6.node); }
    | IDENTIFIER '[' expression ']' MINUS_EQUAL assignment_expr      {DP(assignment_expr3); 
        T_Node *identifier = t_create_node($1.content, $3.node, NULL); 
        $$.node = t_create_node($5.content, identifier, $6.node); }
    | IDENTIFIER '[' expression ']' MUL_EQUAL assignment_expr        {DP(assignment_expr4); 
        T_Node *identifier = t_create_node($1.content, $3.node, NULL); 
        $$.node = t_create_node($5.content, identifier, $6.node); }
    | IDENTIFIER '[' expression ']' DIV_EQUAL assignment_expr        {DP(assignment_expr5); 
        T_Node *identifier = t_create_node($1.content, $3.node, NULL); 
        $$.node = t_create_node($5.content, identifier, $6.node); }
    | IDENTIFIER '[' expression ']' '=' assignment_expr              {DP(assignment_expr6); 
        T_Node *identifier = t_create_node($1.content, $3.node, NULL); 
        $$.node = t_create_node($5.content, identifier, $6.node); }
    ;


binary_expr:
    unary_expr                                  {DP(binary_expr1); $$.node = $1.node; }
    | binary_expr AND binary_expr               {DP(binary_expr2); $$.node = t_create_node($2.content, $1.node, $3.node); }
    | binary_expr OR binary_expr                {DP(binary_expr3); $$.node = t_create_node($2.content, $1.node, $3.node); }

    | binary_expr IS_EQUAL binary_expr          {DP(binary_expr4); $$.node = t_create_node($2.content, $1.node, $3.node); }
    | binary_expr NOT_EQUAL binary_expr         {DP(binary_expr7); $$.node = t_create_node($2.content, $1.node, $3.node); }

    | binary_expr LESS_EQUAL binary_expr        {DP(binary_expr5); $$.node = t_create_node($2.content, $1.node, $3.node); }
    | binary_expr GREATER_EQUAL binary_expr     {DP(binary_expr6); $$.node = t_create_node($2.content, $1.node, $3.node); }
    | binary_expr '<' binary_expr               {DP(binary_expr8); $$.node = t_create_node($2.content, $1.node, $3.node); }
    | binary_expr '>' binary_expr               {DP(binary_expr9); $$.node = t_create_node($2.content, $1.node, $3.node); }

    | binary_expr '+' binary_expr               {DP(binary_expr10); $$.node = t_create_node($2.content, $1.node, $3.node); }
    | binary_expr '-' binary_expr               {DP(binary_expr11); $$.node = t_create_node($2.content, $1.node, $3.node); }
    | binary_expr '*' binary_expr               {DP(binary_expr12); $$.node = t_create_node($2.content, $1.node, $3.node); }
    | binary_expr '/' binary_expr               {DP(binary_expr13); $$.node = t_create_node($2.content, $1.node, $3.node); }
    | binary_expr '^' binary_expr               {DP(binary_expr14); $$.node = t_create_node($2.content, $1.node, $3.node); }
    | binary_expr '%' binary_expr               {DP(binary_expr15); $$.node = t_create_node($2.content, $1.node, $3.node); }
    ;

unary_expr:
    postfix_expr            {DP(unary_expr1); $$.node = $1.node; }
    | '-' unary_expr        {DP(unary_expr2); $$.node = t_create_node($1.content, $2.node, NULL); }
    | '+' unary_expr        {DP(unary_expr3); $$.node = t_create_node($1.content, $2.node, NULL); }
    | '!' unary_expr        {DP(unary_expr4); $$.node = t_create_node($1.content, $2.node, NULL); }
    ;


postfix_expr:
    primary_expr                            {DP(postfix_expr1); $$.node = $1.node; }
    | postfix_expr '[' expression ']'       {DP(postfix_expr2); $$.node = t_create_node("indexing", $1.node, $3.node); } 
    | postfix_expr '(' parameter_list ')'    {DP(postfix_expr3); $$.node = t_create_node("function_call", $1.node, $3.node); }
    | postfix_expr '(' ')'                  {DP(postfix_expr4); $$.node = t_create_node("function_call", $1.node, NULL); }
    ;

parameter_list:
    assignment_expr                         {DP(parameter_list1); $$.node = t_create_node(",", $1.node, NULL); }
    | parameter_list ',' assignment_expr    {DP(parameter_list2); $$.node = t_create_node($2.content, $3.node, $1.node); }
    ;


// literally defined data
primary_expr:
    INTEGER                 {DP(primary_expr1); $$.node = t_create_node($1.content, NULL, NULL); }
    | arr_expr              {DP(primary_expr2); $$.node = $1.node; }
    | FLOAT                 {DP(primary_expr3); $$.node = t_create_node($1.content, NULL, NULL); }
    | BOOLEAN               {DP(primary_expr4); $$.node = t_create_node($1.content, NULL, NULL); }
    | STRING                {DP(primary_expr5); $$.node = t_create_node($1.content, NULL, NULL); }
    | CHARACTER             {DP(primary_expr6); $$.node = t_create_node($1.content, NULL, NULL); }
    | IDENTIFIER            {DP(primary_expr7); $$.node = t_create_node($1.content, NULL, NULL); }
    | '(' expression ')'    {DP(primary_expr8); $$.node = $2.node; }
    ;

arr_expr:
    '[' arr_body ']'        {DP(arr_expr1); $$.node = $2.node; }
    ;

arr_body:
    expression                      {DP(arr_body1); $$.node = t_create_node(",", $1.node, NULL); }
    | arr_body ',' expression       {DP(arr_body2); $$.node = t_create_node($2.content, $3.node, $1.node); }

datatype:
    TYPE_INT        {DP(datatype1); $$.node = t_create_node($1.content, NULL, NULL); }
    | TYPE_FLOAT    {DP(datatype2); $$.node = t_create_node($1.content, NULL, NULL); }
    | TYPE_BOOL     {DP(datatype3); $$.node = t_create_node($1.content, NULL, NULL); }
    | TYPE_STR      {DP(datatype4); $$.node = t_create_node($1.content, NULL, NULL); }
    | TYPE_CHAR     {DP(datatype5); $$.node = t_create_node($1.content, NULL, NULL); }
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
        extern int yydebug;
        yydebug = 0;
        yyin = fopen(argv[1], "r");
        yyparse();
        fclose(yyin);
        t_traverse(root);
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
    fprintf(stderr, "Error in line: %d, %s\n", yylineno-1, s);
    error_count++;
    return 1;
}
