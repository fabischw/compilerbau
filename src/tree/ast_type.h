#ifndef AST_TYPE_H
    #define AST_TYPE_H

    typedef enum _AstType {
        ast_statement,
        ast_loop_declaration,
        ast_condition_if,
        ast_condition_content,
        ast_condition_elif,
        ast_condition_else,
        ast_variable_declaration,
        ast_datatype,
        ast_assignment,
        ast_variable_declaration_const,
        ast_array_declaration,
        ast_array_indexing,
        ast_logical_expression,
        ast_arithmetic_expression,
        ast_unary_expression,
        ast_function_call,
        ast_parameters,
        ast_INTEGER,
        ast_FLOAT,
        ast_BOOLEAN,
        ast_STRING,
        ast_CHARACTER,
        ast_IDENTIFIER,
        ast_array,
        ast_array_item
    } AstType;

    typedef enum _Operator {
        OP_NULL = 0,
        OP_EQUAL, OP_LESS_EQUAL, OP_GREATER_EQUAL, OP_IS_EQUAL, OP_NOT_EQUAL,
        OP_OR, OP_AND, OP_PLUS_EQUAL, OP_MINUS_EQUAL, OP_MUL_EQUAL, OP_DIV_EQUAL,
        OP_PLUS, OP_MINUS, OP_MULT, OP_DIV, OP_MODULO, OP_EXP, OP_LESS, OP_GREATER,
        OP_BANG,
    } Operator;

    const char* ast_type_to_string(AstType type);

#endif