#ifndef TYPING_H
    #define TYPING_H

    #include <stdbool.h>

    /* Not using "TYPE_xx" because of redeclaration errors */
    typedef enum _VarType {
        TYP_NULL = 0,
        TYP_INT,
        TYP_STRING,
        TYP_CHARACTER,
        TYP_BOOLEAN,
        TYP_FLOAT,
        TYP_ARRAY_INT,
        TYP_ARRAY_STRING,
        TYP_ARRAY_CHARACTER,
        TYP_ARRAY_BOOLEAN,
        TYP_ARRAY_FLOAT,
        TYP_ARRAY_EMPTY
    } VarType;

    VarType wrap_with_array_type(VarType var_type);
    VarType unwrap_array_type(VarType var_type); 
    const char* vartype_to_string(VarType var_type);
    bool is_vartype_array(VarType var_type); 
    bool is_vartype_numeric(VarType var_type);

#endif