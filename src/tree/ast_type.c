#include "ast_type.h"

const char* ast_type_to_string(AstType type) {
    switch (type) {
        case ast_statement: return "statement";
        case ast_loop_declaration: return "loop_declaration";
        case ast_condition_if: return "condition_if";
        case ast_condition_content: return "condition_content";
        case ast_condition_elif: return "condition_elif";
        case ast_condition_else: return "condition_else";
        case ast_variable_declaration: return "variable_declaration";
        case ast_datatype: return "datatype";
        case ast_assignment: return "assignment";
        case ast_variable_declaration_const: return "variable_declaration_const";
        case ast_array_declaration: return "array_declaration";
        case ast_array_indexing: return "array_indexing";
        case ast_logical_expression: return "logical_expression";
        case ast_arithmetic_expression: return "arithmetic_expression";
        case ast_unary_expression: return "unary_expression";
        case ast_function_call: return "function_call";
        case ast_parameters: return "parameters";
        case ast_INTEGER: return "INTEGER";
        case ast_FLOAT: return "FLOAT";
        case ast_BOOLEAN: return "BOOLEAN";
        case ast_STRING: return "STRING";
        case ast_CHARACTER: return "CHARACTER";
        case ast_IDENTIFIER: return "IDENTIFIER";
        case ast_array: return "array";
        case ast_array_item: return "array_item";
        default: return "unknown_ast_type";
    }
}