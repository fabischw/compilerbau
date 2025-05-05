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
%token <token_obj> '=' '+' '-' '*' '/' '%' '^' '<' '>'

%type <token_obj> program body statement loop_declaration condition_head condition_body condition_tail variable_declaration expression assignment_expr indexing_expr arr_expr arr_body data_expr function_call_expr parameter_list math_expr assignment_operator logical_expr comparator logical_operator arithmetic_operator datatype optional_newline

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

program:
    body		{DP(program1); $$.node = $1.node; root = $$.node; }
    ;

body:
    | statement end_of_statement body		{DP(body1); $$.node = create_node("statement", $1.node, $3.node); }
    | NEWLINE body                          {DP(body2); $$.node = $2.node; }
    | statement                             {DP(body3); $$.node = create_node("statement", $1.node, NULL); }
    ;
// note: body can be empty


statement:
    expression                      {DP(statement1); $$.node = $1.node; }
    | variable_declaration          {DP(statement2); $$.node = $1.node; }
    | condition_head                {DP(statement3); $$.node = $1.node; }
    | loop_declaration              {DP(statement4); $$.node = $1.node; }
    ;

end_of_statement:
    NEWLINE
    | ';'
    ;

loop_declaration:
    WHILE '(' expression ')' optional_newline '{' body '}'      {DP(loop_declaration1); $$.node = create_node("while", $3.node, $7.node); }

condition_head:
    CONDITION_IF '(' expression ')' optional_newline '{' body '}' condition_body        {DP(condition_head1); 
        Node *branch = create_node("if_content", $3.node, $7.node); $$.node = create_node("if", branch, $9.node); }
    ;

condition_body:
    | condition_tail        {DP(condition_body1); $$.node = $1.node; }
    | NEWLINE condition_body        {DP(condition_body2); $$.node = $2.node; }
    | CONDITION_ELIF '(' expression ')' optional_newline '{' body '}' condition_body        {DP(condition_body3); 
        Node *branch = create_node("elif_content", $3.node, $7.node); $$.node = create_node("elif", branch, $9.node); }

condition_tail:
    CONDITION_ELSE optional_newline '{' body '}'        {DP(condition_tail1); $$.node = $4.node; }
    ;

variable_declaration:
    datatype IDENTIFIER '=' expression                                     {DP(variable_declaration1); 
        Node *var_dec_ass = create_node($3.content, $2.node, $4.node); $$.node = create_node("var_declaration", $1.node, var_dec_ass); }
    | CONSTANT datatype IDENTIFIER '=' expression                          {DP(variable_declaration2);
        Node *var_dec_ass = create_node($4.content, $3.node, $5.node); $$.node = create_node("var_declaration_const", $2.node, var_dec_ass); }
    | datatype '[' expression ']' IDENTIFIER '=' expression                {DP(variable_declaration3); 
        Node *var_dec_array = create_node("var_declaration_array", $1.node, $3.node); 
        Node *var_dec_ass = create_node($6.content, $5.node, $7.node); 
        $$.node = create_node("var_declaration", var_dec_array, var_dec_ass); } 
    | CONSTANT datatype '[' expression ']' IDENTIFIER '=' expression       {DP(variable_declaration4); 
        Node *var_dec_array = create_node("var_declaration_array", $2.node, $4.node); 
        Node *var_dec_ass = create_node($7.content, $6.node, $8.node); 
        $$.node = create_node("var_declaration_const", var_dec_array, var_dec_ass); } 
    ;
    
    /* TODO: allow only compiletime expressions for const values */

expression:
    '(' expression ')'      {DP(expression1); $$.node = $2.node; }
    | data_expr             {DP(expression2); $$.node = $1.node; }
    | math_expr             {DP(expression3); $$.node = $1.node; } 
    | logical_expr          {DP(expression4); $$.node = $1.node; } 
    | arr_expr              {DP(expression5); $$.node = $1.node; } 
    | function_call_expr    {DP(expression6); $$.node = $1.node; } 
    | IDENTIFIER            {DP(expression7); $$.node = create_node($1.content, NULL, NULL); } 
    | indexing_expr         {DP(expression8); $$.node = $1.node; } 
    | assignment_expr       {DP(expression9); $$.node = $1.node; } 
    ;

assignment_expr:
    IDENTIFIER assignment_operator expression %prec '='      {DP(assignment_expr1); 
        Node *identifier = create_node($1.content, NULL, NULL); $$.node = create_node($2.content, identifier, $3.node); }
    | IDENTIFIER '[' expression ']' assignment_operator expression %prec '='      {DP(assignment_expr2); 
        Node *array_indexing = create_node("array_indexing", $1.node, $3.node); $$.node = create_node($5.content, array_indexing, $6.node); }
    ;

indexing_expr:
    expression '[' expression ']' 

arr_expr:
    '[' arr_body ']'        {DP(arr_expr1); $$.node = $2.node; }
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
    expression arithmetic_operator expression       {DP(math_expr1); $$.node = create_node($2.content, $1.node, $3.node); }
    | '-' expression %prec UMINUS                   {DP(math_expr2); $$.node = create_node($1.content, NULL, $2.node); }
    ;

logical_expr:
    expression logical_operator expression      {DP(logical_expr1); $$.node = create_node($2.content, $1.node, $3.node); }
    | expression comparator expression          {DP(logical_expr2); $$.node = create_node($2.content, $1.node, $3.node); }
    | '!' expression %prec UNOT                 { }
    ;

comparator:
    IS_EQUAL
    | NOT_EQUAL
    | LESS_EQUAL
    | GREATER_EQUAL
    | '<'
    | '>'
    ;

assignment_operator:
    PLUS_EQUAL
    | MINUS_EQUAL
    | MUL_EQUAL
    | DIV_EQUAL
    | '='
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
