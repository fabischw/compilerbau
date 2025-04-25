#ifndef LL_H
    #define LL_H

    typedef struct _dataType {
        char* id_name;
        char* data_type;
        char* type;
        int line_no;
    } dataType;

    typedef struct _Node {
        dataType* value;
        struct _Node* next;
    } Node;

    dataType* create_dataType(char* id_name, char* data_type, char* type, int line_no);
    Node* create_node(dataType* value);
    Node* init_list(dataType* value);
    void add_node(Node* linked_list, Node* node);
    void add_value(Node* linked_list, dataType* value);
    Node* get_last_node(Node* linked_list);
    void free_dataType(dataType* dt);
    void free_node(Node* node);
    void remove_last_node(Node* linked_list);
    void free_list(Node* linked_list);
    void print_linked_list(Node* linked_list);

#endif