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

#endif