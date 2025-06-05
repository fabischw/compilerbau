#include "semantic_analysis.h"
#include "../tree/tree.h"
#include "../tree/ast_type.h"
#include "../linked_list/linked_list.h"
#include <stdio.h>
#include <string.h>
#include <stdarg.h>


int sem_error_count;

int sem_error(T_Node* ast_node, const char* fmt, ...);

int sem_postorder(T_Node* ast_node, LL_Node* symbol_table) {
    if (ast_node == NULL) return 0;

    if (!(  // don't do postorder traversal for some node types
        ast_node->ast_type == ast_variable_declaration ||
        ast_node->ast_type == ast_variable_declaration_const ||
        ast_node->ast_type == ast_function_call
    )) {
        sem_postorder(ast_node->rightNode, symbol_table);
        sem_postorder(ast_node->leftNode, symbol_table);
    } 

    
    VarType leftType = (ast_node->leftNode) ? ast_node->leftNode->var_type : TYP_NULL;
    VarType rightType = (ast_node->rightNode) ? ast_node->rightNode->var_type : TYP_NULL;

    bool _decl_is_const = false;
    char* identifier;
    VarType var_type;

    switch (ast_node->ast_type)
    {
        dataType* symbol;

        case ast_logical_expression:
            switch (ast_node->operator) {
                case OP_AND:
                case OP_OR:
                    if ((leftType != TYP_BOOLEAN || rightType != TYP_BOOLEAN)) {
                        sem_error(ast_node, "Logical operation on type %s and %s", 
                            vartype_to_string(leftType), vartype_to_string(rightType));
                    }
                    break;
                case OP_IS_EQUAL:
                case OP_NOT_EQUAL:
                    if (!(leftType == rightType)) {
                        sem_error(ast_node, "Equality check on type %s and %s", 
                            vartype_to_string(leftType), vartype_to_string(rightType));
                    }
                    break;
                case OP_LESS_EQUAL:
                case OP_GREATER_EQUAL:
                case OP_LESS:
                case OP_GREATER:
                    if (!is_vartype_numeric(leftType) || !is_vartype_numeric(rightType)) {
                        sem_error(ast_node, "Comparison operation on type %s and %s",
                        vartype_to_string(leftType), vartype_to_string(rightType));
                    }
                    break;
                default:
                    sem_error(ast_node, "Unknown Operator detected, help :/");
                    break;
            }
            ast_node->var_type = TYP_BOOLEAN;
            break;

        case ast_arithmetic_expression:
            if (!is_vartype_numeric(leftType) || !is_vartype_numeric(rightType)) {
                sem_error(ast_node, "Arithmetic operation on non-numeric type %s and %s",
                    vartype_to_string(leftType), vartype_to_string(rightType));
            }
            else if (!(leftType == rightType)) {
                sem_error(ast_node, "Arithmetic operation on unequal type %s and %s",
                    vartype_to_string(leftType), vartype_to_string(rightType));
            }
            ast_node->var_type = leftType;
            break;

        case ast_unary_expression:
            switch (ast_node->operator) {
                case OP_PLUS:
                case OP_MINUS:
                    if (!is_vartype_numeric(leftType)) {
                        sem_error(ast_node, "Arithmetic operation on non-numeric type %s",
                            vartype_to_string(leftType));
                    }
                    ast_node->var_type = leftType;
                    break;
                case OP_BANG:
                    if (leftType != TYP_BOOLEAN) {
                        sem_error(ast_node, "Logical operation on type", leftType);
                    }
                    ast_node->var_type = TYP_BOOLEAN;
                    break;
                default:
                    sem_error(ast_node, "Unknown Operator detected, help :/");
                    break;
            }
            break;
            
        case ast_INTEGER: ast_node->var_type = TYP_INT; break;
        case ast_FLOAT: ast_node->var_type = TYP_FLOAT; break;
        case ast_BOOLEAN: ast_node->var_type = TYP_BOOLEAN; break;
        case ast_STRING: ast_node->var_type = TYP_STRING; break;
        case ast_CHARACTER: ast_node->var_type = TYP_CHARACTER; break;
        
        case ast_variable_declaration_const:    // this node does not follow default postorder traversal
            _decl_is_const = true;
        case ast_variable_declaration:          // this node does not follow default postorder traversal
            identifier = ast_node->rightNode->leftNode->value;

            if (ll_contains_value_id(symbol_table, identifier)) {
                sem_error(ast_node, "Redeclaration of variable '%s'", identifier);
                break;
            }

            if (ast_node->leftNode->ast_type == ast_array_declaration) {
                var_type = wrap_with_array_type(ast_node->leftNode->leftNode->var_type);
                sem_postorder(ast_node->leftNode->rightNode, symbol_table); // check array length expression
                if (ast_node->leftNode->rightNode->var_type != TYP_INT &&
                    ast_node->leftNode->rightNode->var_type != TYP_CHARACTER) {
                        sem_error(ast_node, "Non numeric array index of type %s",
                            vartype_to_string(ast_node->leftNode->rightNode->var_type));
                }
            } else {
                var_type = ast_node->leftNode->var_type;
            }
            sem_postorder(ast_node->rightNode->rightNode, symbol_table); // check right side expression

            VarType exp_typ = ast_node->rightNode->rightNode->var_type;
            if (var_type != exp_typ && !(is_vartype_array(var_type) && exp_typ == TYP_ARRAY_EMPTY)) {
                sem_error(ast_node, "Assignment of %s to %s", 
                    vartype_to_string(exp_typ), vartype_to_string(var_type));
            }

            // add to symbol table
            symbol = ll_create_dataType(identifier, var_type, _decl_is_const, ast_node->lineno);
            ll_add_value(symbol_table, symbol);
            break;

        case ast_assignment:
            char* identifier;

            if (ast_node->leftNode->ast_type == ast_IDENTIFIER) {
                identifier = ast_node->leftNode->value;
            }
            else if (ast_node->leftNode->ast_type == ast_array_indexing) {
                identifier = ast_node->leftNode->leftNode->value;
            } else {
                sem_error(ast_node, "Assigning value to %s",
                    ast_type_to_string(ast_node->leftNode->ast_type));
                break;
            }

            symbol = ll_get_by_value_id(symbol_table, identifier);

            if (symbol == NULL) break;

            if (leftType != rightType && !(is_vartype_array(leftType) && rightType == TYP_ARRAY_EMPTY)) {
                sem_error(ast_node, "Assignment of %s to %s", 
                    vartype_to_string(rightType), vartype_to_string(leftType));
            }

            ast_node->var_type = leftType;

            if (symbol->is_constant) {
                sem_error(ast_node, "Assignment to constant variable");
            }
            break;

        case ast_IDENTIFIER:
            identifier = ast_node->value;
            symbol = ll_get_by_value_id(symbol_table, identifier);
            // check if variable is defined in symbol table
            if (symbol == NULL) {
                sem_error(ast_node, "Undefined variable '%s'", identifier);
                break;
            }
            ast_node->var_type = symbol->var_type;
            break;

        case ast_array_indexing:
            if (!is_vartype_array(leftType)) {
                sem_error(ast_node, "Indexing of %s int", vartype_to_string(leftType));
            }
            if (rightType != TYP_INT && rightType != TYP_CHARACTER) {
                sem_error(ast_node, "Non numeric array index of type %s",
                    vartype_to_string(rightType));
            }
            ast_node->var_type = unwrap_array_type(ast_node->leftNode->var_type);
            break;

        case ast_function_call:     // this node does not follow default postorder traversal
            // retrieve identifier name from children
            identifier = ast_node->leftNode->value;
            
            // check if symbol table contains the function
            symbol = ll_get_by_value_id(symbol_table, identifier);
            if (symbol == NULL) {
                sem_error(ast_node, "Undefined function '%s'", identifier);
                break;
            }
            else if (symbol->var_type != TYP_FUNCTION) {
                sem_error(ast_node, "Symbol '%s' is not a function", identifier);
                break;
            }
            
            // check if parameter types and count match definition in symbol table
            int counter = symbol->func->parameter_count;
            VarType* param_types = symbol->func->parameter_types;
            T_Node* parameter = ast_node;

            // count how many parameters where given
            int given_params = 0;
            while ((parameter = parameter->rightNode) != NULL) given_params++;
            // parameter count doesn't match
            if (given_params!=symbol->func->parameter_count) {
                    char temp[100];
                    sprintf(temp, "Function expects %lu arguments, %d were given", symbol->func->parameter_count, given_params);
                    sem_error(ast_node, temp);
                    break;
            }

            // compare types of parameters
            param_types = param_types+counter-1;
            parameter = ast_node;
            while ((parameter = parameter->rightNode) != NULL) {
                sem_postorder(parameter->leftNode, symbol_table);
                if ((*param_types != TYP_ANY) && parameter->leftNode->var_type != *param_types) {
                    char temp[100];
                    sprintf(temp, "Parameter %d has unexpected type", counter);
                    sem_error(ast_node, temp);
                }
                param_types--;
                counter--;
            }
            
            ast_node->var_type = symbol->func->return_type;
            break;

        case ast_parameters:
            sem_error(ast_node, "This statement should not be encountered");
            break;


        case ast_array_declaration:
            sem_error(ast_node, "This statement should not be encountered");
            break;
        case ast_array:
            if (ast_node->leftNode == NULL) {
                ast_node->var_type = TYP_ARRAY_EMPTY;
            } else {
                ast_node->var_type = wrap_with_array_type(leftType);
            }
            break;

        case ast_array_item:
            if (rightType != TYP_NULL && leftType != rightType) {
                sem_error(ast_node, "Array items of unequal type %s and %s", 
                    vartype_to_string(leftType), vartype_to_string(rightType));
            }
            ast_node->var_type = leftType;
            break;

        case ast_loop_declaration:
            if (leftType != TYP_BOOLEAN) {
                sem_error(ast_node, "Loop condition of type %s", vartype_to_string(leftType));
            }
            break;

        case ast_condition_content:
            if (leftType != TYP_BOOLEAN) {
                sem_error(ast_node, "If condition of type %s", vartype_to_string(leftType));
            }
            break;
        
        case ast_condition_if:
        case ast_condition_elif:
        case ast_condition_else:
        case ast_datatype:
        case ast_statement:
            break;
        default:
            sem_error(ast_node, "Unhandled AST Node Type detected. Help :/");
            break;
    }
}

int semantic_analysis(T_Node* ast_root, LL_Node* symbol_table) {
    sem_error_count = 0;
    sem_postorder(ast_root, symbol_table);
    return sem_error_count;
}

int 
sem_error(T_Node* ast_node, const char* fmt, ...) {
    sem_error_count++;

    char msg[1024];  
    va_list args;
    va_start(args, fmt);
    vsnprintf(msg, sizeof(msg), fmt, args);
    va_end(args);

    fprintf(stderr, "Error in line %d: %s\n", ast_node->lineno, msg);

    return 1;
}