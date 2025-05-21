#ifndef TYPING_H
    #define TYPING_H

    /* Not using "TYPE_xx" because of redeclaration errors */
    typedef enum _VarType {
        TYP_INVALID         = ~0b10,
        TYP_UNKNOWN         = ~0b1,
        TYP_NULL            = 0b0,
        TYP_BOOLEAN         = 0b0000001,
        TYP_INT             = 0b1000010,
        TYP_FLOAT           = 0b1000100,
        TYP_CHARACTER       = 0b1001000,
        TYP_STRING          = 0b0010000,
        TYP_ARRAY_BOOLEAN   = 0b0100001,
        TYP_ARRAY_INT       = 0b0100010,
        TYP_ARRAY_FLOAT     = 0b0100100,
        TYP_ARRAY_CHARACTER = 0b0101000,
        TYP_ARRAY_STRING    = 0b0110000,

        TYP_IS_ARRAY        = 0b0100000,
        TYP_IS_NUMERIC      = 0b1000000,
        TYP_ANY             = 0b111111,
    } VarType;

    VarType wrap_with_array_type(VarType var_type);
    VarType unwrap_array_type(VarType var_type); 
    const char* vartype_to_string(VarType var_type);

#endif