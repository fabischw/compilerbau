#ifndef LL_H
    #define LL_H

    typedef struct _dataType {
        char* id_name;
        char* data_type;
        char* type;
        int line_no;
    } dataType;

    typedef struct _LL_Node {
        dataType* value;
        struct _LL_Node* next;
    } LL_Node;

    dataType* ll_create_dataType(char* id_name, char* data_type, char* type, int line_no);
    LL_Node* ll_create_node(dataType* value);
    LL_Node* ll_init_list(dataType* value);
    void ll_add_node(LL_Node* linked_list, LL_Node* node);
    void ll_add_value(LL_Node* linked_list, dataType* value);
    LL_Node* ll_get_last_node(LL_Node* linked_list);
    void ll_free_dataType(dataType* dt);
    void ll_free_node(LL_Node* node);
    void ll_remove_last_node(LL_Node* linked_list);
    void ll_free_list(LL_Node* linked_list);
    void ll_print_linked_list(LL_Node* linked_list);

#endif
