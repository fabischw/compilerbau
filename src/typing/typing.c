#include "typing.h"

VarType
wrap_with_array_type(VarType var_type) {
    switch (var_type) {
        case TYP_INT: return TYP_ARRAY_INT;
        case TYP_STRING: return TYP_ARRAY_STRING;
        case TYP_CHARACTER: return TYP_ARRAY_CHARACTER;
        case TYP_BOOLEAN: return TYP_ARRAY_BOOLEAN;
        case TYP_FLOAT: return TYP_ARRAY_FLOAT;
        default: return TYP_INVALID;
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
        default: return TYP_INVALID;
    }
}