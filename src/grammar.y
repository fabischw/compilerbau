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

    //#define ADD_ST(type, id, const) add_to_symbol_table(id, TYPE_##type, const)


    extern FILE* yyin;
    extern int yylineno;
    extern int yyerror(const char *s);
    extern int yylex();


    void add_to_symbol_table(char* id_name, VarType var_type, bool is_constant);

    T_Node* root;

    LL_Node* symbol_table = NULL;

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
        $$.node = t_create_node("var_declaration", var_dec_ass, $4.node); 
        add_to_symbol_table($2.content, $1.type, false); }

    | CONSTANT datatype IDENTIFIER '=' expression                          {DP(variable_declaration2);
        T_Node *identifier = t_create_node($3.content, NULL, NULL); 
        T_Node *var_dec_ass = t_create_node("type", $2.node, identifier); 
        $$.node = t_create_node("var_declaration_const", var_dec_ass, $5.node);  
        add_to_symbol_table($3.content, $1.type, true); }

    | datatype '[' expression ']' IDENTIFIER '=' expression                {DP(variable_declaration3);
        T_Node *identifier = t_create_node($5.content, $3.node, NULL); 
        T_Node *var_dec_ass = t_create_node("type", $1.node, identifier); 
        $$.node = t_create_node("var_declaration", var_dec_ass, $7.node);  
        add_to_symbol_table($5.content, wrap_with_array_type($1.type), false); } 

    | CONSTANT datatype '[' expression ']' IDENTIFIER '=' expression       {DP(variable_declaration4); 
        T_Node *identifier = t_create_node($6.content, $4.node, NULL); 
        T_Node *var_dec_ass = t_create_node("type", $2.node, identifier); 
        $$.node = t_create_node("var_declaration_const", var_dec_ass, $8.node);  
        add_to_symbol_table($6.content, wrap_with_array_type($2.type), true); } 
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
    unary_expr                                  {DP(binary_expr1); $$.node = $1.node; $$.type = $1.type; }
    | binary_expr AND binary_expr               {DP(binary_expr2); $$.node = t_create_node($2.content, $1.node, $3.node); 
        if ($1.type != TYP_BOOLEAN) { yyerror("Operant 1 is not of type bool"); }
        if ($3.type != TYP_BOOLEAN) { yyerror("Operant 2 is not of type bool"); }
        $$.type = TYP_BOOLEAN; }
    | binary_expr OR binary_expr                {DP(binary_expr3); $$.node = t_create_node($2.content, $1.node, $3.node); 
        if ($1.type != TYP_BOOLEAN) { yyerror("Operant 1 is not of type bool"); }
        if ($3.type != TYP_BOOLEAN) { yyerror("Operant 2 is not of type bool"); }
        $$.type = TYP_BOOLEAN; }

    | binary_expr IS_EQUAL binary_expr          {DP(binary_expr4); $$.node = t_create_node($2.content, $1.node, $3.node); 
        TODO this gets special treatment
        if ($1.type != TYP_BOOLEAN) { yyerror("Operant 1 is not of type bool"); }
        if ($3.type != TYP_BOOLEAN) { yyerror("Operant 2 is not of type bool"); }
        $$.type = TYP_BOOLEAN; }
    | binary_expr NOT_EQUAL binary_expr         {DP(binary_expr7); $$.node = t_create_node($2.content, $1.node, $3.node); 
        TODO this gets special treatment
        if ($1.type != TYP_BOOLEAN) { yyerror("Operant 1 is not of type bool"); }
        if ($3.type != TYP_BOOLEAN) { yyerror("Operant 2 is not of type bool"); }
        $$.type = TYP_BOOLEAN; }

    | binary_expr LESS_EQUAL binary_expr        {DP(binary_expr5); $$.node = t_create_node($2.content, $1.node, $3.node); 
        if ($1.type != TYP_INT || $1.type != TYP_FLOAT) { yyerror("Operant 1 is not of type int or float"); }
        if ($3.type != TYP_INT || $3.type != TYP_FLOAT) { yyerror("Operant 2 is not of type int or float"); }
        $$.type = TYP_BOOLEAN; }
    | binary_expr GREATER_EQUAL binary_expr     {DP(binary_expr6); $$.node = t_create_node($2.content, $1.node, $3.node); 
        if ($1.type != TYP_INT || $1.type != TYP_FLOAT) { yyerror("Operant 1 is not of type int or float"); }
        if ($3.type != TYP_INT || $3.type != TYP_FLOAT) { yyerror("Operant 2 is not of type int or float"); }
        $$.type = TYP_BOOLEAN; }
    | binary_expr '<' binary_expr               {DP(binary_expr8); $$.node = t_create_node($2.content, $1.node, $3.node); 
        if ($1.type != TYP_INT || $1.type != TYP_FLOAT) { yyerror("Operant 1 is not of type int or float"); }
        if ($3.type != TYP_INT || $3.type != TYP_FLOAT) { yyerror("Operant 2 is not of type int or float"); }
        $$.type = TYP_BOOLEAN; }
    | binary_expr '>' binary_expr               {DP(binary_expr9); $$.node = t_create_node($2.content, $1.node, $3.node); 
        if ($1.type != TYP_INT || $1.type != TYP_FLOAT) { yyerror("Operant 1 is not of type int or float"); }
        if ($3.type != TYP_INT || $3.type != TYP_FLOAT) { yyerror("Operant 2 is not of type int or float"); }
        $$.type = TYP_BOOLEAN; }

    | binary_expr '+' binary_expr               {DP(binary_expr10); $$.node = t_create_node($2.content, $1.node, $3.node); 
        if ($1.type != TYP_INT || $1.type != TYP_FLOAT || $3.type != TYP_INT || $3.type != TYP_FLOAT) { 
            yyerror("Arithmetik operation only works on int or float"); }
        if ($1.type != $3.type) { yyerror("Operants are not of same type"); }
        $$.type = $1.type; }
    | binary_expr '-' binary_expr               {DP(binary_expr11); $$.node = t_create_node($2.content, $1.node, $3.node); 
        if ($1.type != TYP_INT || $1.type != TYP_FLOAT || $3.type != TYP_INT || $3.type != TYP_FLOAT) { 
            yyerror("Arithmetik operation only works on int or float"); }
        if ($1.type != $3.type) { yyerror("Operants are not of same type"); }
        $$.type = $1.type; }
    | binary_expr '*' binary_expr               {DP(binary_expr12); $$.node = t_create_node($2.content, $1.node, $3.node); 
        if ($1.type != TYP_INT || $1.type != TYP_FLOAT || $3.type != TYP_INT || $3.type != TYP_FLOAT) { 
            yyerror("Arithmetik operation only works on int or float"); }
        if ($1.type != $3.type) { yyerror("Operants are not of same type"); }
        $$.type = $1.type; }
    | binary_expr '/' binary_expr               {DP(binary_expr13); $$.node = t_create_node($2.content, $1.node, $3.node); 
        if ($1.type != TYP_INT || $1.type != TYP_FLOAT || $3.type != TYP_INT || $3.type != TYP_FLOAT) { 
            yyerror("Arithmetik operation only works on int or float"); }
        if ($1.type != $3.type) { yyerror("Operants are not of same type"); }
        $$.type = $1.type; }
    | binary_expr '^' binary_expr               {DP(binary_expr14); $$.node = t_create_node($2.content, $1.node, $3.node); 
        if ($1.type != TYP_INT || $1.type != TYP_FLOAT || $3.type != TYP_INT || $3.type != TYP_FLOAT) { 
            yyerror("Arithmetik operation only works on int or float"); }
        if ($1.type != $3.type) { yyerror("Operants are not of same type"); }
        $$.type = $1.type; }
    | binary_expr '%' binary_expr               {DP(binary_expr15); $$.node = t_create_node($2.content, $1.node, $3.node); 
        if ($1.type != TYP_INT || $1.type != TYP_FLOAT || $3.type != TYP_INT || $3.type != TYP_FLOAT) { 
            yyerror("Arithmetik operation only works on int or float"); }
        if ($1.type != $3.type) { yyerror("Operants are not of same type"); }
        $$.type = $1.type; }
    ;

unary_expr:
    postfix_expr            {DP(unary_expr1); $$.node = $1.node; $$.type = $1.type; }
    | '-' unary_expr        {DP(unary_expr2); $$.node = t_create_node($1.content, $2.node, NULL); 
        if ($2.type != TYP_INT) { yyerror("Int type expected"); }
        $$.type = TYP_INT; }
    | '+' unary_expr        {DP(unary_expr3); $$.node = t_create_node($1.content, $2.node, NULL);  
        if ($2.type != TYP_INT) { yyerror("Int type expected"); }
        $$.type = TYP_INT; }
    | '!' unary_expr        {DP(unary_expr4); $$.node = t_create_node($1.content, $2.node, NULL);  
        if ($2.type != TYP_BOOLEAN) { yyerror("Bool type expected"); }
        $$.type = TYP_BOOLEAN; }
    ;


postfix_expr:
    primary_expr                            {DP(postfix_expr1); $$.node = $1.node; $$.type = $1.type; }
    | postfix_expr '[' expression ']'       {DP(postfix_expr2); $$.node = t_create_node("indexing", $1.node, $3.node); 
        if ($3.type != TYP_INT) { yyerror("Array index must be integer"); }
        VarType unwrapped = unwrap_array_type($1.type);
        if (unwrapped < 0) { 
            yyerror("Cannot index non-array type"); 
            return $1.type; } // return value despite error, just so compilation continues 
        else { return unwrapped; }} 
    | postfix_expr '(' parameter_list ')'    {DP(postfix_expr3); $$.node = t_create_node("function_call", $1.node, $3.node); RETURN_VALUE_OF_METHOD }
    | postfix_expr '(' ')'                  {DP(postfix_expr4); $$.node = t_create_node("function_call", $1.node, NULL); RETURN_VALUE_OF_METHOD }
    ;

parameter_list:
    assignment_expr                         {DP(parameter_list1); $$.node = t_create_node(",", $1.node, NULL); }
    | parameter_list ',' assignment_expr    {DP(parameter_list2); $$.node = t_create_node($2.content, $3.node, $1.node); }
    ;


// literally defined data
primary_expr:
    INTEGER                 {DP(primary_expr1); $$.node = t_create_node($1.content, NULL, NULL); $$.type = TYP_INT; }
    | arr_expr              {DP(primary_expr2); $$.node = $1.node; $$.type = $1.type; }
    | FLOAT                 {DP(primary_expr3); $$.node = t_create_node($1.content, NULL, NULL); $$.type = TYP_FLOAT; }
    | BOOLEAN               {DP(primary_expr4); $$.node = t_create_node($1.content, NULL, NULL); $$.type = TYP_BOOLEAN; }
    | STRING                {DP(primary_expr5); $$.node = t_create_node($1.content, NULL, NULL); $$.type = TYP_STRING; }
    | CHARACTER             {DP(primary_expr6); $$.node = t_create_node($1.content, NULL, NULL); $$.type = TYP_CHARACTER; }
    | IDENTIFIER            {DP(primary_expr7); $$.node = t_create_node($1.content, NULL, NULL); LOOK INTO SYMBOL TABLE}
    | '(' expression ')'    {DP(primary_expr8); $$.node = $2.node; $$.type = $2.type; }
    ;

arr_expr:
    '[' arr_body ']'        {DP(arr_expr1); $$.node = $2.node; $$.type = $2.type; }
    ;

arr_body:
    expression                      {DP(arr_body1); $$.node = t_create_node(",", $1.node, NULL); $$.type = $1.type; }
    | arr_body ',' expression       {DP(arr_body2); $$.node = t_create_node($2.content, $3.node, $1.node); 
        // check if elements of array definition have same type
        if ($1.type != $3.type) { yyerror("Missmatch in array types"); }
        $$.type = $1.type; }

datatype:
    TYPE_INT        {DP(datatype1); $$.node = t_create_node($1.content, NULL, NULL); $$.type = TYP_INT; }
    | TYPE_FLOAT    {DP(datatype2); $$.node = t_create_node($1.content, NULL, NULL); $$.type = TYP_FLOAT; }
    | TYPE_BOOL     {DP(datatype3); $$.node = t_create_node($1.content, NULL, NULL); $$.type = TYP_BOOLEAN; }
    | TYPE_STR      {DP(datatype4); $$.node = t_create_node($1.content, NULL, NULL); $$.type = TYP_STRING; }
    | TYPE_CHAR     {DP(datatype5); $$.node = t_create_node($1.content, NULL, NULL); $$.type = TYP_CHARACTER; }
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
        ll_print_linked_list(symbol_table);
    }
    else {
        printf (">>> Please type in any input:\n");
        yyparse();
    }
    return 0;
}

void
add_to_symbol_table(char* id_name, VarType var_type, bool is_constant)
{
    int lineno = yylineno-1;

    dataType* symbol = ll_create_dataType(id_name, var_type, is_constant, lineno);

    /*
    switch(type)
    {
        case ST_VARIABLE:
            if(ll_contains_value_id(symbol_table, identifier))
            {
                yyerror("Multiple Declaration!");
                return;
            }
            symbol = ll_create_dataType(identifier, var_type, "Variable", lineno);
            break;

        case ST_CONSTANT:
            if(ll_contains_value_id(symbol_table, identifier))
            {
                yyerror("Multiple Declaration!");
                error_count++;
                return;
            }
            symbol = ll_create_dataType(identifier, var_type, "Constant", lineno);
            break;

        case ST_KEYWORD:
            symbol = ll_create_dataType(identifier, var_type, "Keyword", lineno);
            break;

        case ST_FUNCTION:
            symbol = ll_create_dataType(identifier, var_type, "Functions", lineno);
            break;
    }
    */

    if(symbol_table == NULL)
    {
        symbol_table = ll_init_list(symbol);
    } else
    {
        ll_add_value(symbol_table, symbol);
    }
}

int
yyerror(const char* s)
{
    fprintf(stderr, "Error in line: %d, %s\n", yylineno-1, s);
    error_count++;
    return 1;
}
