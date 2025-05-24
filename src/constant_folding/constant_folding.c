#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <math.h>
#include "../tree/ast_type.h"
#include "../tree/tree.h"

bool fold(T_Node* node) {
    if (!node) return false;

    bool found_fold = false;

    found_fold = found_fold || fold(node->leftNode);
    found_fold = found_fold || fold(node->rightNode);

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

        found_fold = true;
    }

    return found_fold;

}


void perform_folding(T_Node* root) {
    bool changed = true;
    while (changed) {
        changed = fold(root);
    }
}


