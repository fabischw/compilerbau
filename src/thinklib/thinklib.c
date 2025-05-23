#include "../linked_list/linked_list.h"

LL_Node* create_stdlib_symbol_table() {
    dataType* lib[] = {
        ll_create_dataType("toint", TYP_FUNCTION, true, -1),
        ll_create_dataType("tostr", TYP_FUNCTION, true, -1),
        ll_create_dataType("tochar", TYP_FUNCTION, true, -1),
        ll_create_dataType("tofloat", TYP_FUNCTION, true, -1),
        ll_create_dataType("tobool", TYP_FUNCTION, true, -1),
        ll_create_dataType("exit", TYP_FUNCTION, true, -1),
        ll_create_dataType("print", TYP_FUNCTION, true, -1),
        ll_create_dataType("input", TYP_FUNCTION, true, -1),
    };
    lib[0]->func = func_create(1, (VarType[]){TYP_ANY}, TYP_FLOAT);
    lib[1]->func = func_create(1, (VarType[]){TYP_ANY}, TYP_STRING);
    lib[2]->func = func_create(1, (VarType[]){TYP_ANY}, TYP_INT);
    lib[3]->func = func_create(1, (VarType[]){TYP_ANY}, TYP_BOOLEAN);
    lib[4]->func = func_create(1, (VarType[]){TYP_ANY}, TYP_CHARACTER);
    lib[5]->func = func_create(0, NULL, TYP_NULL);
    lib[6]->func = func_create(1, (VarType[]){TYP_STRING}, TYP_NULL);
    lib[7]->func = func_create(1, (VarType[]){TYP_STRING}, TYP_STRING);
    int lib_size = 8;

    // create linked list from those dataTypes and return

    LL_Node* tbl = ll_create_node(lib[0]);
    for (int i = 1; i < lib_size; i++) {
        ll_add_value(tbl, lib[i]);
    }
    return tbl;
}