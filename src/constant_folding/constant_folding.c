#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <math.h>
#include "../tree/ast_type.h"
#include "../tree/tree.h"
#include "../linked_list/linked_list.h"
#include "../typing/typing.h"


bool basic_arithmetic_fold(T_Node* node) {
    // does basic arithmetic folding without utilizing the symbol table
    if (!node) return false;

    bool found_fold = false;

    found_fold = found_fold || basic_arithmetic_fold(node->leftNode);
    found_fold = found_fold || basic_arithmetic_fold(node->rightNode);

    if (node->ast_type == ast_arithmetic_expression && node->leftNode && node->rightNode && 
        (node->leftNode->ast_type == ast_INTEGER || node->leftNode->ast_type == ast_FLOAT) &&
        (node->rightNode->ast_type == ast_INTEGER || node->rightNode->ast_type == ast_FLOAT)
    ) {
        bool is_int = node->leftNode->ast_type == ast_INTEGER;

        double left_num = atof(node->leftNode->value);
        double right_num = atof(node->rightNode->value);
        double result;

        switch (node->operator) {
            case OP_PLUS:
                result = left_num + right_num;
                break;
            case OP_MINUS:
                result = left_num - right_num;
                break;
            case OP_MULT:
                result = left_num * right_num;
                break;
            case OP_DIV:
                result = left_num / right_num;
                break;
            case OP_MODULO:
                result = fmod(left_num, right_num);
                break;
            case OP_EXP:
                result = pow(left_num, right_num);
                break;
        }

        t_free_node(&node->leftNode);
        t_free_node(&node->rightNode);

        char value[64];

        if (is_int) {
            snprintf(value, sizeof(value), "%d", (int)result);
            node->ast_type = ast_INTEGER;
        }
        else {
            snprintf(value, sizeof(value), "%f", result);
            node->ast_type = ast_FLOAT;
        }


        node->value = strdup(value);
        node->operator = OP_NULL;
        node->lineno = -1;

        found_fold = true;
    }

    return found_fold;

}


bool detect_basic_consts(T_Node* root, LL_Node* symbol_table) {
    // detects basic const declarions and updates the symbol table
    if (!root) return false;
    bool detected_update = false;

    detected_update |= detect_basic_consts(root->rightNode, symbol_table);
    detected_update |= detect_basic_consts(root->leftNode, symbol_table);
    
    if (root->ast_type == ast_variable_declaration_const &&
        root->leftNode->ast_type == ast_datatype) {
            T_Node* assign_node = root->rightNode;
            if ((assign_node->rightNode->ast_type == ast_INTEGER) || (assign_node->rightNode->ast_type == ast_FLOAT)) {
                dataType* dt = ll_get_by_value_id(symbol_table, assign_node->leftNode->value);
                if (!dt->has_const_val) {
                    dt->const_value = atof(assign_node->rightNode->value);
                    dt->has_const_val = true;
                    detected_update = true;
                }
            }
            else if (assign_node->rightNode->ast_type == ast_IDENTIFIER) {
                dataType* identifier = ll_get_by_value_id(symbol_table, assign_node->rightNode->value);
                if (identifier->has_const_val) {
                    dataType* dt = ll_get_by_value_id(symbol_table, assign_node->leftNode->value);
                    if (!dt->has_const_val) {
                        dt->const_value = identifier->const_value;
                        dt->has_const_val = true;
                        detected_update = true;
                    }
                }
            }
        }
    return detected_update;
}


static bool try_remove_decl_node(T_Node** child_ptr, LL_Node* symbol_table) {
    // function to actually remove the declaration
    if (!child_ptr || !*child_ptr) return false;

    T_Node* decl = *child_ptr;

    if (decl->ast_type != ast_variable_declaration_const) return false;
    if (!decl->rightNode || decl->rightNode->ast_type != ast_assignment) return false;
    if (!decl->rightNode->leftNode || decl->rightNode->leftNode->ast_type != ast_IDENTIFIER) return false;

    dataType* dt = ll_get_by_value_id(symbol_table, decl->rightNode->leftNode->value);
    if (dt && dt->has_const_val) {
        t_free_node(child_ptr);
        *child_ptr = NULL;
        return true;
    }

    return false;
}

bool remove_const_decls(T_Node* node, LL_Node* symbol_table) {
    // remove constant declaration from AST if the value is known
    if (!node) return false;

    bool updated = false;

    updated |= remove_const_decls(node->leftNode, symbol_table);
    updated |= remove_const_decls(node->rightNode, symbol_table);

    updated |= try_remove_decl_node(&node->leftNode, symbol_table);
    updated |= try_remove_decl_node(&node->rightNode, symbol_table);

    if (node->rightNode &&
        (node->rightNode->ast_type == ast_statement) &&
        !node->rightNode->leftNode &&
        !node->rightNode->rightNode) {
            t_free_node(&node->rightNode);
            node->rightNode = NULL;
            updated = true;
        }
    return updated;
}


bool update_ast(T_Node* root, LL_Node* symbol_table) {
    // replaces all constants in AST by literals if possible
    if (!root) return false;
    bool updated = false;
    updated |= update_ast(root->leftNode, symbol_table);
    updated |= update_ast(root->rightNode, symbol_table);

    if (root->ast_type == ast_IDENTIFIER) {
        dataType* dt = ll_get_by_value_id(symbol_table, root->value);
        if (dt->has_const_val) {
            root->is_constant = true;
            char value[64];
            switch (dt->var_type) {
                case TYP_INT:
                    root->ast_type = ast_INTEGER;
                    snprintf(value, sizeof(value), "%d", (int)dt->const_value);
                    break;
                case TYP_FLOAT:
                    root->ast_type = ast_FLOAT;
                    snprintf(value, sizeof(value), "%f", dt->const_value);
                    break;
            }
            root->value = strdup(value);
            root->operator = OP_NULL;
            root->lineno = -1;
            updated = true;
        }
    }
    return updated;
}


void perform_folding(T_Node** root_ptr , LL_Node* symbol_table) {
    T_Node wrapper_root = {0};
    wrapper_root.rightNode = *root_ptr;
    bool changed = true;
    int pass_count = 0;
    while (changed) {
        changed = basic_arithmetic_fold(wrapper_root.rightNode);
        changed |= detect_basic_consts(wrapper_root.rightNode, symbol_table);
        changed |= remove_const_decls(&wrapper_root, symbol_table);
        changed |= update_ast(wrapper_root.rightNode, symbol_table);
        pass_count += 1;

    }
    *root_ptr = wrapper_root.rightNode;
    printf("Constant folding took %d passes\n", pass_count);
}


