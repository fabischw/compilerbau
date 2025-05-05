%{
    #include<stdio.h>
    #include "../src/tree/tree.h"
    #include "../src/linked_list/linked_list.h"
    
    extern FILE* yyin;
    extern int yylineno; 
    extern int yyerror(const char *s);
    extern int yylex();
    extern char* yytext;

 typedef enum _SymbolTableType {
        ST_VARIABLE,
        ST_CONSTANT,
        ST_KEYWORD,
        ST_FUNCTION,
    } SymbolTableType;

    void add_to_symbol_table(SymbolTableType type, char* text);

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

%type <token_obj> program body statement loop_declaration condition_head condition_body condition_tail variable_declaration expression assignment_expr indexing_expr arr_expr arr_body data_expr function_call_expr parameter_list math_expr logical_expr comparator logical_operator arithmetic_operator datatype optional_newline

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
    body		{ $$.node = $1.node; root = $$.node; }
    ;

body:
    | statement end_of_statement body		{ $$.node = create_node("statement", $1.node, $3.node); }
    | NEWLINE body                          { $$.node = $2.node; }
    | statement                             { $$.node = create_node("statement", $1.node, NULL); }
    ;
// note: body can be empty


statement:
    expression                      { $$.node = $1.node; }
    | variable_declaration          { $$.node = $1.node; }
    | condition_head                { $$.node = $1.node; }
    | loop_declaration              { $$.node = $1.node; }
    ;

end_of_statement:
    NEWLINE
    | ';'
    ;

loop_declaration:
    WHILE '(' expression ')' optional_newline '{' body '}'      { $$.node = create_node("while", $3.node, $7.node); }

condition_head:
    CONDITION_IF '(' expression ')' optional_newline '{' body '}' condition_body        { 
        Node *branch = create_node("if_content", $3.node, $7.node); $$.node = create_node("if", branch, $9.node); }
    ;

condition_body:
    | condition_tail        { $$.node = $1.node; }
    | NEWLINE condition_body        { $$.node = $2.node; }
    | CONDITION_ELIF '(' expression ')' optional_newline '{' body '}' condition_body        { 
        Node *branch = create_node("elif_content", $3.node, $7.node); $$.node = create_node("elif", branch, $9.node); }

condition_tail:
    CONDITION_ELSE optional_newline '{' body '}'        { $$.node = $4.node; }
    ;

variable_declaration:
    datatype IDENTIFIER '=' expression                                     { add_to_symbol_table(ST_VARIABLE, yytext); 
        Node *var_dec_ass = create_node("var_declaration_assignment", $2.node, $4.node); $$.node = create_node("var_declaration", $1.node, var_dec_ass); }
    | CONSTANT datatype IDENTIFIER '=' expression                          {
        Node *var_dec_ass = create_node("var_declaration_assignment", $3.node, $5.node); $$.node = create_node("var_declaration_const", $2.node, var_dec_ass); }
    | datatype '[' expression ']' IDENTIFIER '=' expression                {  } //TODO
    | CONSTANT datatype '[' expression ']' IDENTIFIER '=' expression       {  } //TODO
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
    | assignment_expr
    ;

assignment_expr:
    IDENTIFIER assignment_operator expression
    | IDENTIFIER '[' expression ']' assignment_operator expression
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

void
add_to_symbol_table(SymbolTableType type, char* text)
{
    switch(type)
    {
        case ST_VARIABLE:
            printf("Variable\n");
            printf("%s", text);
            break;

        case ST_CONSTANT:
            printf("Constant\n");
            break;

        case ST_KEYWORD:
            printf("Keyword\n");
            break;

        case ST_FUNCTION:
            break;
    }
}

int
yyerror(const char* s)
{
    fprintf(stderr, "Error in line: %d, %s\n", yylineno, s);
    return 1;
}
