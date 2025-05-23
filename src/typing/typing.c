#include "typing.h"
#include <stdbool.h>

VarType
wrap_with_array_type(VarType var_type) {
    switch (var_type) {
        case TYP_INT: return TYP_ARRAY_INT;
        case TYP_STRING: return TYP_ARRAY_STRING;
        case TYP_CHARACTER: return TYP_ARRAY_CHARACTER;
        case TYP_BOOLEAN: return TYP_ARRAY_BOOLEAN;
        case TYP_FLOAT: return TYP_ARRAY_FLOAT;
        default: return TYP_NULL;
    }
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
        case TYP_ARRAY_EMPTY: return "empty[]";
        case TYP_ANY: return "any";
        case TYP_FUNCTION: return "function";
        case TYP_NULL: return "null";
        default: return "unknown";
    }
}
VarType
unwrap_array_type(VarType var_type) {
    switch (var_type) {
        case TYP_ARRAY_INT: return TYP_INT;
        case TYP_ARRAY_STRING: return TYP_STRING;
        case TYP_ARRAY_CHARACTER: return TYP_CHARACTER;
        case TYP_ARRAY_BOOLEAN: return TYP_BOOLEAN;
        case TYP_ARRAY_FLOAT: return TYP_FLOAT;
        default: return TYP_NULL;
    }
}

bool is_vartype_numeric(VarType var_type) {
    return (var_type == TYP_CHARACTER || var_type == TYP_INT || var_type == TYP_FLOAT);
}

bool is_vartype_array(VarType var_type) {
    return (
        var_type == TYP_ARRAY_BOOLEAN ||
        var_type == TYP_ARRAY_CHARACTER ||
        var_type == TYP_ARRAY_FLOAT ||
        var_type == TYP_ARRAY_INT ||
        var_type == TYP_ARRAY_STRING ||
        var_type == TYP_ARRAY_EMPTY
    );
}