#ifndef CONSTANT_FOLDING_H
    #define CONSTANT_FOLDING_H

    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <stdbool.h>
    #include <math.h>
    #include "../tree/tree.h"
    #include "../tree/ast_type.h"

    bool fold(T_Node* node);

    void perform_folding(T_Node* root);

#endif
