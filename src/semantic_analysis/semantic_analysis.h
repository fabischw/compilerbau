#ifndef SEMANTIC_ANALYSIS_H
    #define SEMANTIC_ANALYSIS_H

    #include "../tree/tree.h"
    #include "../linked_list/linked_list.h"

    int semantic_analysis(T_Node* ast_root, LL_Node* symbol_table);

#endif