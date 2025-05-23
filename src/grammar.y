%debug

%{
    #include<stdio.h>
    #include<string.h>
    #include<stdbool.h>
    #include "../src/tree/tree.h"
    #include "../src/typing/typing.h"
    #include "../src/linked_list/linked_list.h"
    #include "../src/tree/ast_type.h"
    #include "../src/semantic_analysis/semantic_analysis.h"
    #include "../src/thinklib/thinklib.h"
    
    //#define DP(s) printf("->%s\n", #s)
    #define DP(s) (1)


    T_Node* ast_node(AstType ast_type, char *value, T_Node* left, T_Node* right);

    extern FILE* yyin;
    extern int yylineno;
    extern int yyerror(const char *s);
    extern int yylex();


    T_Node* root;
    LL_Node* symbol_table;

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
%token <token_obj> EQUAL PLUS MINUS MULT DIV MODULO EXP LESS GREATER BANG ','

%type <token_obj> program body statement statement_list loop_declaration condition_if condition_elif condition_else variable_declaration expression assignment_expr binary_expr unary_expr postfix_expr parameter_list primary_expr arr_expr arr_body datatype 

%left OR
%left AND
%nonassoc IS_EQUAL NOT_EQUAL
%nonassoc LESS_EQUAL GREATER_EQUAL LESS GREATER

%left EQUAL PLUS_EQUAL MINUS_EQUAL MUL_EQUAL DIV_EQUAL
%left PLUS MINUS
%left MULT DIV MODULO
%right EXP

%nonassoc UNOT 
%nonassoc UMINUS


%%

// -- general ---

program:
    body		{DP(program1); $$.node = $1.node; root = $$.node; }
    ;

body:
                                            {DP(body1); $$.node = NULL; }
    | statement_seperator_optional statement statement_seperator_optional                       {DP(body2); $$.node = $2.node; }
    | statement_seperator_optional statement_list statement statement_seperator_optional    {DP(body3); $$.node = ast_node(ast_statement, NULL, $3.node, $2.node); }
    ;

// | body statement_seperator statement            {DP(body4); $$.node =  }

statement_list:
    statement_list statement statement_seperator    {DP(statement_list1); $$.node = ast_node(ast_statement, NULL, $2.node, $1.node); }
    | statement statement_seperator                 {DP(statement_list2); $$.node = $1.node; }
    ;

// note: body can be empty

statement_seperator:
    NEWLINE
    | NEWLINE statement_seperator
    | ';'
    | ';' statement_seperator
    ;

statement_seperator_optional:
    | statement_seperator
    ;

// -- statements --

statement:
    expression                      {DP(statement1); $$.node = $1.node; }
    | variable_declaration          {DP(statement2); $$.node = $1.node; }
    | condition_if                  {DP(statement3); $$.node = $1.node; }
    | loop_declaration              {DP(statement4); $$.node = $1.node; }
    ;

loop_declaration:
    WHILE '(' expression ')' optional_newline '{' body '}'      {DP(loop_declaration1); $$.node = ast_node(ast_loop_declaration, NULL, $3.node, $7.node); }

condition_if:
    CONDITION_IF '(' expression ')' optional_newline '{' body '}' condition_elif        {DP(condition_if1); 
        T_Node *branch = ast_node(ast_condition_content, NULL, $3.node, $7.node); 
        $$.node = ast_node(ast_condition_if, NULL, branch, $9.node); }
    ;

condition_elif:
    condition_else        {DP(condition_elif1); $$.node = $1.node; }
    | NEWLINE condition_elif        {DP(condition_elif2); $$.node = $2.node; }
    | CONDITION_ELIF '(' expression ')' optional_newline '{' body '}' condition_elif        {DP(condition_elif3); 
        T_Node *branch = ast_node(ast_condition_content, NULL, $3.node, $7.node);
         $$.node = ast_node(ast_condition_elif, NULL, branch, $9.node); }

condition_else:
                                                          {DP(condition_else0); $$.node = NULL; }
    | CONDITION_ELSE optional_newline '{' body '}'        {DP(condition_else1); $$.node = ast_node(ast_condition_else, NULL, $4.node, NULL); }
    ;

variable_declaration:
    datatype IDENTIFIER EQUAL expression                                     {DP(variable_declaration1); 
        T_Node *identifier = ast_node(ast_IDENTIFIER, $2.content, NULL, NULL);
        T_Node *assignment = ast_node(ast_assignment, "=", identifier, $4.node); 
        $$.node = ast_node(ast_variable_declaration, NULL, $1.node, assignment); 
        $$.node->operator = OP_EQUAL; }

    | CONSTANT datatype IDENTIFIER EQUAL expression                          {DP(variable_declaration2);
        T_Node *identifier = ast_node(ast_IDENTIFIER, $3.content, NULL, NULL);
        T_Node *assignment = ast_node(ast_assignment, "=", identifier, $5.node); 
        $$.node = ast_node(ast_variable_declaration_const, NULL, $2.node, assignment); 
        $$.node->operator = OP_EQUAL; }

    | datatype '[' expression ']' IDENTIFIER EQUAL expression                {DP(variable_declaration3);
        T_Node *identifier = ast_node(ast_IDENTIFIER, $5.content, NULL, NULL);
        T_Node *array_declaration = ast_node(ast_array_declaration, NULL, $1.node, $3.node);
        T_Node *assignment = ast_node(ast_assignment, "=", identifier, $7.node); 
        $$.node = ast_node(ast_variable_declaration, NULL, array_declaration, assignment); 
        $$.node->operator = OP_EQUAL; } 

    | CONSTANT datatype '[' expression ']' IDENTIFIER EQUAL expression       {DP(variable_declaration4); 
        T_Node *identifier = ast_node(ast_IDENTIFIER, $6.content, NULL, NULL);
        T_Node *array_declaration = ast_node(ast_array_declaration, NULL, $2.node, $4.node);
        T_Node *assignment = ast_node(ast_assignment, "=", identifier, $8.node); 
        $$.node = ast_node(ast_variable_declaration_const, NULL, array_declaration, assignment); 
        $$.node->operator = OP_EQUAL; } 
    ;
    
    /* TODO: allow only compiletime expressions for const values */

// -- expressions --

expression:
    assignment_expr     {DP(expression1); $$.node = $1.node; }
    ;

assignment_expr:
    binary_expr                                     {DP(assignment_expr1); $$.node = $1.node; }
    | postfix_expr PLUS_EQUAL assignment_expr       {DP(assignment_expr2); 
        $$.node = ast_node(ast_assignment, $2.content, $1.node, $3.node); 
        $$.node->operator = OP_PLUS_EQUAL; }
    | postfix_expr MINUS_EQUAL assignment_expr      {DP(assignment_expr3); 
        $$.node = ast_node(ast_assignment, $2.content, $1.node, $3.node); 
        $$.node->operator = OP_MINUS_EQUAL; }
    | postfix_expr MUL_EQUAL assignment_expr        {DP(assignment_expr4); 
        $$.node = ast_node(ast_assignment, $2.content, $1.node, $3.node); 
        $$.node->operator = OP_MUL_EQUAL; }
    | postfix_expr DIV_EQUAL assignment_expr        {DP(assignment_expr5); 
        $$.node = ast_node(ast_assignment, $2.content, $1.node, $3.node); 
        $$.node->operator = OP_DIV_EQUAL; }
    | postfix_expr EQUAL assignment_expr              {DP(assignment_expr6); 
        $$.node = ast_node(ast_assignment, $2.content, $1.node, $3.node); 
        $$.node->operator = OP_EQUAL; }

/*    | IDENTIFIER '[' expression ']' PLUS_EQUAL assignment_expr       {DP(assignment_expr7); 
        T_Node *identifier = ast_node(ast_IDENTIFIER, $1.content, NULL, NULL);
        T_Node *array_indexing = ast_node(ast_array_indexing, NULL, identifier, $3.node);
        $$.node = ast_node(ast_assignment, $5.content, array_indexing, $6.node); 
        $$.node->operator = OP_PLUS_EQUAL; }
    | IDENTIFIER '[' expression ']' MINUS_EQUAL assignment_expr      {DP(assignment_expr8); 
        T_Node *identifier = ast_node(ast_IDENTIFIER, $1.content, NULL, NULL);
        T_Node *array_indexing = ast_node(ast_array_indexing, NULL, identifier, $3.node);
        $$.node = ast_node(ast_assignment, $5.content, array_indexing, $6.node); 
        $$.node->operator = OP_MINUS_EQUAL; }
    | IDENTIFIER '[' expression ']' MUL_EQUAL assignment_expr        {DP(assignment_expr9); 
        T_Node *identifier = ast_node(ast_IDENTIFIER, $1.content, NULL, NULL);
        T_Node *array_indexing = ast_node(ast_array_indexing, NULL, identifier, $3.node);
        $$.node = ast_node(ast_assignment, $5.content, array_indexing, $6.node); 
        $$.node->operator = OP_MUL_EQUAL; }
    | IDENTIFIER '[' expression ']' DIV_EQUAL assignment_expr        {DP(assignment_expr10); 
        T_Node *identifier = ast_node(ast_IDENTIFIER, $1.content, NULL, NULL);
        T_Node *array_indexing = ast_node(ast_array_indexing, NULL, identifier, $3.node);
        $$.node = ast_node(ast_assignment, $5.content, array_indexing, $6.node); 
        $$.node->operator = OP_DIV_EQUAL; }
    | IDENTIFIER '[' expression ']' EQUAL assignment_expr              {DP(assignment_expr11); 
        T_Node *identifier = ast_node(ast_IDENTIFIER, $1.content, NULL, NULL);
        T_Node *array_indexing = ast_node(ast_array_indexing, NULL, identifier, $3.node);
        $$.node = ast_node(ast_assignment, $5.content, array_indexing, $6.node); 
        $$.node->operator = OP_EQUAL; }*/
    ;


binary_expr:
    unary_expr                                  {DP(binary_expr1); $$.node = $1.node; }
    | binary_expr AND binary_expr               {DP(binary_expr2); $$.node = ast_node(ast_logical_expression, $2.content, $1.node, $3.node); $$.node->operator = OP_AND; }
    | binary_expr OR binary_expr                {DP(binary_expr3); $$.node = ast_node(ast_logical_expression, $2.content, $1.node, $3.node); $$.node->operator = OP_OR; }

    | binary_expr IS_EQUAL binary_expr          {DP(binary_expr4); $$.node = ast_node(ast_logical_expression, $2.content, $1.node, $3.node); $$.node->operator = OP_IS_EQUAL; }
    | binary_expr NOT_EQUAL binary_expr         {DP(binary_expr7); $$.node = ast_node(ast_logical_expression, $2.content, $1.node, $3.node); $$.node->operator = OP_NOT_EQUAL; }

    | binary_expr LESS_EQUAL binary_expr        {DP(binary_expr5); $$.node = ast_node(ast_logical_expression, $2.content, $1.node, $3.node); $$.node->operator = OP_LESS_EQUAL; }
    | binary_expr GREATER_EQUAL binary_expr     {DP(binary_expr6); $$.node = ast_node(ast_logical_expression, $2.content, $1.node, $3.node); $$.node->operator = OP_GREATER_EQUAL; }
    | binary_expr LESS binary_expr               {DP(binary_expr8); $$.node = ast_node(ast_logical_expression, $2.content, $1.node, $3.node); $$.node->operator = OP_LESS; }
    | binary_expr GREATER binary_expr               {DP(binary_expr9); $$.node = ast_node(ast_logical_expression, $2.content, $1.node, $3.node); $$.node->operator = OP_GREATER; }

    | binary_expr PLUS binary_expr               {DP(binary_expr10); $$.node = ast_node(ast_arithmetic_expression, $2.content, $1.node, $3.node); $$.node->operator = OP_PLUS; }
    | binary_expr MINUS binary_expr               {DP(binary_expr11); $$.node = ast_node(ast_arithmetic_expression, $2.content, $1.node, $3.node); $$.node->operator = OP_MINUS; }
    | binary_expr MULT binary_expr               {DP(binary_expr12); $$.node = ast_node(ast_arithmetic_expression, $2.content, $1.node, $3.node); $$.node->operator = OP_MULT; }
    | binary_expr DIV binary_expr               {DP(binary_expr13); $$.node = ast_node(ast_arithmetic_expression, $2.content, $1.node, $3.node); $$.node->operator = OP_DIV; }
    | binary_expr EXP binary_expr               {DP(binary_expr14); $$.node = ast_node(ast_arithmetic_expression, $2.content, $1.node, $3.node); $$.node->operator = OP_EXP; }
    | binary_expr MODULO binary_expr               {DP(binary_expr15); $$.node = ast_node(ast_arithmetic_expression, $2.content, $1.node, $3.node); $$.node->operator = OP_MODULO; }
    ;

unary_expr:
    postfix_expr            {DP(unary_expr1); $$.node = $1.node; }
    | MINUS unary_expr        {DP(unary_expr2); $$.node = ast_node(ast_unary_expression, $1.content, $2.node, NULL); $$.node->operator = OP_MINUS; }
    | PLUS unary_expr        {DP(unary_expr3); $$.node = ast_node(ast_unary_expression, $1.content, $2.node, NULL); $$.node->operator = OP_PLUS; }
    | BANG unary_expr        {DP(unary_expr4); $$.node = ast_node(ast_unary_expression, $1.content, $2.node, NULL); $$.node->operator = OP_BANG; }
    ;


postfix_expr:
    primary_expr                            {DP(postfix_expr1); $$.node = $1.node; }
    | postfix_expr '[' expression ']'       {DP(postfix_expr2); $$.node = ast_node(ast_array_indexing, NULL, $1.node, $3.node); } 
    | postfix_expr '(' parameter_list ')'   {DP(postfix_expr3); $$.node = ast_node(ast_function_call, NULL, $1.node, $3.node); }
    | postfix_expr '(' ')'                  {DP(postfix_expr4); $$.node = ast_node(ast_function_call, NULL, $1.node, NULL); }
    ;

parameter_list:
    assignment_expr                         {DP(parameter_list1); $$.node = ast_node(ast_parameters, NULL, $1.node, NULL); }
    | parameter_list ',' assignment_expr    {DP(parameter_list2); $$.node = ast_node(ast_parameters, NULL, $3.node, $1.node); }
    ;


// literally defined data
primary_expr:
    INTEGER                 {DP(primary_expr1); $$.node = ast_node(ast_INTEGER, $1.content, NULL, NULL); }
    | arr_expr              {DP(primary_expr2); $$.node = $1.node; }
    | FLOAT                 {DP(primary_expr3); $$.node = ast_node(ast_FLOAT, $1.content, NULL, NULL); }
    | BOOLEAN               {DP(primary_expr4); $$.node = ast_node(ast_BOOLEAN, $1.content, NULL, NULL); }
    | STRING                {DP(primary_expr5); $$.node = ast_node(ast_STRING, $1.content, NULL, NULL); }
    | CHARACTER             {DP(primary_expr6); $$.node = ast_node(ast_CHARACTER, $1.content, NULL, NULL); }
    | IDENTIFIER            {DP(primary_expr7); $$.node = ast_node(ast_IDENTIFIER, $1.content, NULL, NULL); }
    | '(' expression ')'    {DP(primary_expr8); $$.node = $2.node; }
    ;

arr_expr:
    '[' arr_body ']'        {DP(arr_expr1); $$.node = ast_node(ast_array, NULL, $2.node, NULL); }
    ;

arr_body:
    expression                      {DP(arr_body1); $$.node = ast_node(ast_array_item, NULL, $1.node, NULL); }
    | arr_body ',' expression       {DP(arr_body2); $$.node = ast_node(ast_array_item, NULL, $3.node, $1.node); }

datatype:
    TYPE_INT        {DP(datatype1); $$.node = ast_node(ast_datatype, $1.content, NULL, NULL); $$.node->var_type = TYP_INT; }
    | TYPE_FLOAT    {DP(datatype2); $$.node = ast_node(ast_datatype, $1.content, NULL, NULL); $$.node->var_type = TYP_FLOAT; }
    | TYPE_BOOL     {DP(datatype3); $$.node = ast_node(ast_datatype, $1.content, NULL, NULL); $$.node->var_type = TYP_BOOLEAN; }
    | TYPE_STR      {DP(datatype4); $$.node = ast_node(ast_datatype, $1.content, NULL, NULL); $$.node->var_type = TYP_STRING; }
    | TYPE_CHAR     {DP(datatype5); $$.node = ast_node(ast_datatype, $1.content, NULL, NULL); $$.node->var_type = TYP_CHARACTER; }
    ;

optional_newline:
    | NEWLINE optional_newline
    ;
    
%%

T_Node* ast_node(AstType ast_type, char *value, T_Node* left, T_Node* right) {
    return t_create_node(ast_type, value, yylineno, left, right);
}

int
main(int argc, char** argv)
{
    if(argc == 2)
    {
        extern int yydebug;
        yydebug = 0;
        yyin = fopen(argv[1], "r");
        yyparse();
        printf("--- AST Created ---\n");
        t_traverse(root);
        printf("--- Begin Type Checking ---\n");
        symbol_table = create_stdlib_symbol_table();
        semantic_analysis(root, symbol_table);
        printf("--- Type Checking Done ---\n");
        ll_print_linked_list(symbol_table);
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
    fprintf(stderr, "Error in line: %d, %s\n", yylineno-1, s);
    error_count++;
    return 1;
}
