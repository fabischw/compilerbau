#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "linked_list.h"


dataType* ll_create_dataType(char* id_name, char* data_type, char* type, int line_no) {
    dataType* dt = malloc(sizeof(dataType));
    dt->id_name = strdup(id_name);
    dt->data_type = strdup(data_type);
    dt->type = strdup(type);
    dt->line_no = line_no;
    return dt;
}


LL_Node* ll_create_node(dataType* value) {
    LL_Node* node = malloc(sizeof(LL_Node));
    (*node).value = value;
    (*node).next = NULL;
    return node;
}


LL_Node* ll_init_list(dataType* value) {
    return ll_create_node(value);
};


void ll_add_node(LL_Node* linked_list, LL_Node* node) {
    LL_Node* current = linked_list;
    while (current->next != NULL) {
        current = current->next;
    }
    current->next = node;
}


void ll_add_value(LL_Node* linked_list, dataType* value) {
    ll_add_node(linked_list, ll_create_node(value));
};


LL_Node* ll_get_last_node(LL_Node* linked_list) {
    LL_Node* current = linked_list;
    while (current != NULL) {
        current = current->next;
    }
    return current;
}


void ll_free_dataType(dataType* dt) {
    dataType dt_val = *dt;
    free(dt_val.id_name);
    free(dt_val.data_type);
    free(dt_val.type);
    free(dt);
}


void ll_free_node(LL_Node* node) {
    ll_free_dataType(node->value);
    free(node);
}


void free_list(LL_Node* linked_list) {
    // free entire linked list
    LL_Node* current = linked_list;
    LL_Node* next;
    while (current != NULL) {
        next = current->next;
        ll_free_node(current);
        current = next;
    }
}


void ll_print_linked_list(LL_Node* linked_list) {
    // print entire linked list (used for debugging)
    LL_Node* current = linked_list;
    while (current != NULL) {
        printf("value: (id_name: %s | data_type: %s | type: %s | line: %d)\n",
                current->value->id_name,
                current->value->data_type,
                current->value->type,
                current->value->line_no);
        current = current->next;
    }
}
