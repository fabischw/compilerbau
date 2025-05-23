#ifndef FUNCTIONS_H
    #define FUNCTIONS_H

    #include "../typing/typing.h"
    #include <stdlib.h>

    typedef struct _Function {
        size_t parameter_count;
        VarType return_type;
        VarType parameter_types[];
    } Function;


    Function *func_create(size_t parameter_count, VarType parameter_types[], VarType return_type);

#endif