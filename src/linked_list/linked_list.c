#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "linked_list.h"
#include "../typing/typing.h"


dataType* ll_create_dataType(char* id_name, VarType var_type, bool is_constant, int line_no) {
    dataType* dt = malloc(sizeof(dataType));
    dt->id_name = strdup(id_name);
    dt->var_type = var_type; 
    dt->is_constant = is_constant;
    dt->line_no = line_no;
    return dt;
}


LL_Node* ll_create_node(dataType* value) {
    LL_Node* node = malloc(sizeof(LL_Node));
    (*node).value = value;
    (*node).next = NULL;
    return node;
}

int
ll_contains_value_id(LL_Node* linked_list, char* id_name)
{
    if(linked_list == NULL) return 0;

    while(linked_list)
    {        
    if(!strcmp(linked_list->value->id_name,id_name)) return 1;
    linked_list = linked_list->next;
    }

    return 0;
}

dataType*
ll_get_by_value_id(LL_Node* linked_list, char* id_name)
{
    if(linked_list == NULL) return NULL;

    while(linked_list)
    {        
    if(!strcmp(linked_list->value->id_name,id_name)) return linked_list->value;
    linked_list = linked_list->next;
    }

    return NULL;
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
        printf("value: (id_name: %s | var_type: %s | is_constant: %d | line: %d)\n",
                current->value->id_name,
                vartype_to_string(current->value->var_type),
                current->value->is_constant,
                current->value->line_no);
        current = current->next;
    }
}
