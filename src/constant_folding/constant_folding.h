#ifndef CONSTANT_FOLDING_H
    #define CONSTANT_FOLDING_H

    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <stdbool.h>
    #include <math.h>
    #include "../tree/tree.h"
    #include "../tree/ast_type.h"
    #include "../linked_list/linked_list.h"
    #include "../typing/typing.h"

    bool basic_arithmetic_fold(T_Node* node);
    void perform_folding(T_Node** root_ptr , LL_Node* symbol_table);
    bool detect_basic_consts(T_Node* root, LL_Node* symbol_table);
    bool update_ast(T_Node* root, LL_Node* symbol_table);
    bool remove_const_decls(T_Node** node, LL_Node* symbol_table);

    static bool try_remove_decl_node(T_Node** child_ptr, LL_Node* symbol_table);

#endif
