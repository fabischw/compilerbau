#include "semantic_analysis.h"
#include "../tree/tree.h"
#include "../tree/ast_type.h"
#include "../linked_list/linked_list.h"
#include <stdio.h>

/*  Error types 
Example             Description                         

int a = 5;          Redeclaration of variable

arr[1] = 5;
b = 5;              Assignment to undefined variable

print(arr[3])
print(b);           Usage of undefined variable

my_const = 5;       Assignment to constant variable

a = "wrong"         Assignment of incorrect type

func() = 5          Invalid assignment to structure

"hi" + 5            Operation on unequal types

if (5) {}           
while (5) {}        Incorrect type in condition

expects_str(123)    Parameter with invalid type

two_args(1)         Invalid number of parameters

my_arr["hi"]        Non numeric array index

6[1]                Indexing of non-array type

5 && True           

*/

int sem_error_count;

int sem_error(const char* s, T_Node* ast_node);

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
            
        case ast_INTEGER: ast_node->var_type = TYP_INT; break;
        case ast_FLOAT: ast_node->var_type = TYP_FLOAT; break;
        case ast_BOOLEAN: ast_node->var_type = TYP_BOOLEAN; break;
        case ast_STRING: ast_node->var_type = TYP_STRING; break;
        case ast_CHARACTER: ast_node->var_type = TYP_CHARACTER; break;
        
        case ast_variable_declaration_const:    // this node does not follow default postorder traversal
            _decl_is_const = true;
        case ast_variable_declaration:          // this node does not follow default postorder traversal
            identifier = ast_node->rightNode->leftNode->value;
            dataType* symbol;

            if (ll_contains_value_id(symbol_table, identifier)) {
                char temp[100];
                sprintf(temp,"Symbol '%s' already defined", identifier);
                sem_error(temp, ast_node);
                break;
            }

            if (ast_node->leftNode->ast_type == ast_array_declaration) {
                var_type = wrap_with_array_type(ast_node->leftNode->leftNode->var_type);
                sem_postorder(ast_node->leftNode->rightNode, symbol_table); // check array length expression
                if (ast_node->leftNode->rightNode->var_type != TYP_INT &&
                    ast_node->leftNode->rightNode->var_type != TYP_CHARACTER) {
                        sem_error("Expected integer or character as array index", ast_node);
                }
            } else {
                var_type = ast_node->leftNode->var_type;
            }
            sem_postorder(ast_node->rightNode->rightNode, symbol_table); // check right side expression

            VarType exp_typ = ast_node->rightNode->rightNode->var_type;
            if (var_type != exp_typ && !(is_vartype_array(var_type) && exp_typ == TYP_ARRAY_EMPTY)) {
                char temp[100];
                sprintf(temp, "Cannot assign %s to %s", vartype_to_string(exp_typ), vartype_to_string(var_type));
                sem_error(temp, ast_node);
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
                sem_error("Can only assign to IDENTIFIER or ARRAY.", ast_node);
                break;
            }

            if (!ll_contains_value_id(symbol_table, identifier)) break;

            if (leftType != rightType && !(is_vartype_array(leftType) && rightType == TYP_ARRAY_EMPTY)) {
                char temp[100];
                sprintf(temp, "Cannot assign %s to %s", vartype_to_string(rightType), vartype_to_string(leftType));
                sem_error(temp, ast_node);
            }

            ast_node->var_type = leftType;

            symbol = ll_get_by_value_id(symbol_table, identifier);
            if (symbol->is_constant) {
                sem_error("Cannot assign to constant value", ast_node);
            }
            break;

        case ast_IDENTIFIER:
            identifier = ast_node->value;
            if (!ll_contains_value_id(symbol_table, identifier)) {
                char temp[100];
                sprintf(temp, "Symbol '%s' not defined", identifier);
                sem_error(temp, ast_node);
                break;
            }
            var_type = ll_get_by_value_id(symbol_table, identifier)->var_type;
            ast_node->var_type = var_type;
            break;
        case ast_array_indexing:
            if (!is_vartype_array(leftType)) {
                sem_error("Can only index array type", ast_node);
            }
            if (rightType != TYP_INT && rightType != TYP_CHARACTER) {
                sem_error("Expected integer or character as array index", ast_node);
            }
            ast_node->var_type = unwrap_array_type(ast_node->leftNode->var_type);
            break;

        case ast_function_call:     // this node does not follow default postorder traversal
            identifier = ast_node->leftNode->value;
            if (!ll_contains_value_id(symbol_table, identifier)) {
                char temp[100];
                sprintf(temp, "Symbol '%s' not defined", identifier);
                sem_error(temp, ast_node);
                break;
            }
            symbol = ll_get_by_value_id(symbol_table, identifier);
            if (symbol->var_type != TYP_FUNCTION) {
                char temp[100];
                sprintf(temp, "Symbol '%s' is not a function", identifier);
                sem_error(temp, ast_node);
                break;
            }
            
            int counter = symbol->func->parameter_count;
            VarType* param_types = symbol->func->parameter_types;
            T_Node* parameter = ast_node;

            int given_params = 0;
            while ((parameter = parameter->rightNode) != NULL) given_params++;
            if (given_params!=symbol->func->parameter_count) {
                    char temp[100];
                    sprintf(temp, "Function expected %lu arguments, %d were given", symbol->func->parameter_count, given_params);
                    sem_error(temp, ast_node);
                    break;
            }

            param_types = param_types+counter-1;
            parameter = ast_node;
            while ((parameter = parameter->rightNode) != NULL) {
                sem_postorder(parameter->leftNode, symbol_table);
                if ((*param_types != TYP_ANY) && parameter->leftNode->var_type != *param_types) {
                    char temp[100];
                    sprintf(temp, "Parameter %d has unexpected type", counter);
                    sem_error(temp, ast_node);
                }
                param_types--;
                counter--;
            }

            ast_node->var_type = symbol->func->return_type;
            break;

        case ast_parameters:
            sem_error("This statement should not be encountered", ast_node);
            break;


        case ast_array_declaration:
            sem_error("This statement should not be encountered", ast_node);
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
                sem_error("Expected array items to be of same type", ast_node);
            }
            ast_node->var_type = leftType;
            break;

        case ast_loop_declaration:
            if (leftType != TYP_BOOLEAN) {
                sem_error("Loop condition expects Boolean", ast_node);
            }
            break;

        case ast_condition_content:
            if (leftType != TYP_BOOLEAN) {
                sem_error("If condition expects Boolean", ast_node);
            }
            break;
        
        case ast_condition_if:
        case ast_condition_elif:
        case ast_condition_else:
        case ast_datatype:
        case ast_statement:
            break;
        default:
            sem_error("Unhandled AST Node Type detected. Help :/", ast_node);
            break;
    }
}

int semantic_analysis(T_Node* ast_root, LL_Node* symbol_table) {
    sem_error_count = 0;
    sem_postorder(ast_root, symbol_table);
    return sem_error_count;
}

int
sem_error(const char* s, T_Node* ast_node)
{
    sem_error_count++;
    fprintf(stderr, "Error in line: %d, %s\n", ast_node->lineno, s);
    return 1;
}