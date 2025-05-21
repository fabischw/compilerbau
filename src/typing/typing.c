#include "typing.h"
#include <stdbool.h>

VarType
wrap_with_array_type(VarType var_type) {
    return (var_type & TYP_IS_ARRAY) ? var_type ^ TYP_IS_ARRAY : TYP_INVALID;
}

const char* 
vartype_to_string(VarType var_type) {
    switch (var_type) {
        case TYP_INT: return "int";
        case TYP_STRING: return "string";
        case TYP_CHARACTER: return "character";
        case TYP_BOOLEAN: return "boolean";
        case TYP_FLOAT: return "float";
        case TYP_ARRAY_INT: return "int[]";
        case TYP_ARRAY_STRING: return "string[]";
        case TYP_ARRAY_CHARACTER: return "character[]";
        case TYP_ARRAY_BOOLEAN: return "boolean[]";
        case TYP_ARRAY_FLOAT: return "float[]";
        default: return "unknown";
    }
}

VarType
unwrap_array_type(VarType var_type) {
    return (var_type & TYP_IS_ARRAY) ? TYP_INVALID : var_type ^ TYP_IS_ARRAY;
}