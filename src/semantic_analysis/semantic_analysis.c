#include "semantic_analysis.h"
#include "../tree/tree.h"
#include "../tree/ast_type.h"
#include <stdio.h>

int sem_postorder(T_Node* ast_node) {
    int errCount = 0;

    if (!(  // don't do postorder traversal for some node types
        ast_node->ast_type == ast_variable_declaration ||
        ast_node->ast_type == ast_variable_declaration_const
    )) {
        errCount += sem_postorder(ast_node->rightNode);
        errCount += sem_postorder(ast_node->leftNode);
    } 
    
    VarType leftType = (ast_node->leftNode) ? ast_node->leftNode->var_type : TYP_NULL;
    VarType rightType = (ast_node->rightNode) ? ast_node->rightNode->var_type : TYP_NULL;

    bool _decl_is_const = false;

    switch (ast_node->ast_type)
    {
        case ast_logical_expression:
            switch (ast_node->operator) {
                case OP_AND:
                case OP_OR:
                    if ((leftType != TYP_BOOLEAN || rightType != TYP_BOOLEAN)) {
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
                    if (!is_vartype_numeric(leftType) || !is_vartype_numeric(rightType)) {
                        sem_error("Numeric type expected", ast_node);
                    }
                    break;
                default:
                    sem_error("Unknown Operator detected, help :/", ast_node);
                    break;
            }
            ast_node->var_type = TYP_BOOLEAN;
            break;

        case ast_arithmetic_expression:
            if (!is_vartype_numeric(leftType) || !is_vartype_numeric(rightType)) {
                sem_error("Numeric type expected", ast_node);
            }
            else if (!(leftType == rightType)) {
                sem_error("Values not of same type", ast_node);
            }
            ast_node->var_type = leftType;
            break;

        case ast_unary_expression:
            switch (ast_node->operator) {
                case OP_PLUS:
                case OP_MINUS:
                    if (!is_vartype_numeric(leftType)) {
                        sem_error("Numeric type expected", ast_node);
                    }
                    ast_node->var_type = leftType;
                    break;
                case OP_BANG:
                    if (leftType != TYP_BOOLEAN) {
                        sem_error("Boolean type expected", ast_node);
                    }
                    ast_node->var_type = TYP_BOOLEAN;
                    break;
                default:
                    sem_error("Unknown Operator detected, help :/", ast_node);
                    break;
            }
            break;
            
        case ast_datatype:
        case ast_INTEGER: ast_node->var_type = TYP_INT; break;
        case ast_FLOAT: ast_node->var_type = TYP_FLOAT; break;
        case ast_BOOLEAN: ast_node->var_type = TYP_BOOLEAN; break;
        case ast_STRING: ast_node->var_type = TYP_STRING; break;
        case ast_CHARACTER: ast_node->var_type = TYP_CHARACTER; break;
        
        case ast_variable_declaration_const:
            _decl_is_const = true;
        case ast_variable_declaration:
            // check if already exists in symbol table
            // if not add to symbol table
            // then do traversal
            // then do typechecking
            char* identifier = ast_node->rightNode->leftNode->value;
            if (ast_node->leftNode->ast_type == ast_array_declaration) {

            } else {
                
            }


        case ast_assignment:
            // check if trying to assign to constant

        case ast_array_indexing:

        case ast_IDENTIFIER:
        case ast_function_call:
            


        case ast_array_declaration:
        case ast_parameters:
        case ast_array:
        case ast_array_item:
        
        case ast_statement:
        case ast_loop_declaration:
        case ast_condition_if:
        case ast_condition_content:
        case ast_condition_elif:
        case ast_condition_else:
            break;
        default:
            sem_error("Unhandled AST Node Type detected. Help :/", ast_node);
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