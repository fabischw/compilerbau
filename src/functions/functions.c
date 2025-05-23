#include "functions.h"
#include <stdlib.h>
#include <string.h>


Function 
*func_create(size_t parameter_count, VarType *parameter_types, VarType return_type) {
    Function *func = malloc(sizeof(Function) + parameter_count + sizeof(VarType));
    if (!func) return NULL;

    func->parameter_count = parameter_count;
    func->return_type = return_type;

    if (parameter_count > 0 && parameter_types != NULL) {
        memcpy(func->parameter_types, parameter_types, parameter_count * sizeof(VarType));
    }

    return func;
}