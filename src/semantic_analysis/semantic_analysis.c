#include "semantic_analysis.h"
#include "../tree/tree.h"
#include "../tree/ast_type.h"
#include <stdio.h>

int sem_postorder(T_Node* ast_node) {
    int errCount = 0;
    errCount += sem_postorder(ast_node->rightNode);
    errCount += sem_postorder(ast_node->leftNode);
    
    VarType leftType = (ast_node->leftNode) ? ast_node->leftNode->var_type : TYP_NULL;
    VarType rightType = (ast_node->rightNode) ? ast_node->rightNode->var_type : TYP_NULL;


    switch (ast_node->ast_type)
    {
        case ast_logical_expression:
            switch (ast_node->operator) {
                case OP_AND:
                case OP_OR:
                    if (!(leftType & TYP_BOOLEAN & rightType)) {
                        sem_error("Boolean expected", ast_node);
                    }
                    break;
                case OP_IS_EQUAL:
                case OP_NOT_EQUAL:
                    if (!(leftType == rightType)) {
                        sem_error("Values not of same type", ast_node);
                    }
                    break;
                case OP_LESS_EQUAL:
                case OP_GREATER_EQUAL:
                case OP_LESS:
                case OP_GREATER:
                    if (!(leftType & TYP_IS_NUMERIC) || !(rightType & TYP_IS_NUMERIC)) {
                        sem_error("Numeric type expected", ast_node);
                    }
                default:
                    break;
            }
            ast_node->var_type = TYP_BOOLEAN;
            break;
        case ast_arithmetic_expression:
            if (!(leftType & TYP_IS_NUMERIC)) {
                sem_error("Numeric type expected", ast_node);
            }
            if (!(leftType == rightType)) {
                sem_error("Values not of same type", ast_node);
            }
            ast_node->var_type = leftType;
            break;
        case ast_unary_expression:
        case ast_assignment:
        case ast_array_indexing:

        case ast_statement:
        case ast_loop_declaration:
        case ast_condition_if:
        case ast_condition_content:
        case ast_condition_elif:
        case ast_condition_else:
        case ast_variable_declaration:
        case ast_variable_declaration_const:
        case ast_array_declaration:
        case ast_parameters:
        case ast_array:
        case ast_array_item:

        case ast_IDENTIFIER:
        case ast_datatype:
        case ast_function_call:
        case ast_INTEGER:
        case ast_FLOAT:
        case ast_BOOLEAN:
        case ast_STRING:
        case ast_CHARACTER:
        
        default:
            break;
    }
}

int semantic_analysis(T_Node* ast_root) {
    printf("a");
    return 0;
}

int
sem_error(const char* s, T_Node* ast_node)
{
    fprintf(stderr, "Error in line: %d, %s\n", ast_node->lineno, s);
    return 1;
}