#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "linked_list.h"


dataType* create_dataType(char* id_name, char* data_type, char* type, int line_no) {
    dataType* dt = malloc(sizeof(dataType));
    dt->id_name = strdup(id_name);
    dt->data_type = strdup(data_type);
    dt->type = strdup(type);
    dt->line_no = line_no;
    return dt;
}


Node* create_node(dataType* value) {
    Node* node = malloc(sizeof(Node));
    (*node).value = value;
    (*node).next = NULL;
    return node;
}


Node* init_list(dataType* value) {
    return create_node(value);
};


void add_node(Node* linked_list, Node* node) {
    Node* current = linked_list;
    while (current->next != NULL) {
        current = current->next;
    }
    current->next = node;
}


void add_value(Node* linked_list, dataType* value) {
    add_node(linked_list, create_node(value));
};


Node* get_last_node(Node* linked_list) {
    Node* current = linked_list;
    while (current != NULL) {
        current = current->next;
    }
    return current;
}


void free_dataType(dataType* dt) {
    dataType dt_val = *dt;
    free(dt_val.id_name);
    free(dt_val.data_type);
    free(dt_val.type);
    free(dt);
}


void free_node(Node* node) {
    free_dataType(node->value);
    free(node);
}


void free_list(Node* linked_list) {
    // free entire linked list
    Node* current = linked_list;
    Node* next;
    while (current != NULL) {
        next = current->next;
        free_node(current);
        current = next;
    }
}


void print_linked_list(Node* linked_list) {
    // print entire linked list (used for debugging)
    Node* current = linked_list;
    while (current != NULL) {
        printf("next: (%lu); value: (id_name: %s | data_type: %s | type: %s | line: %d)\n",
                current->next,
                current->value->id_name,
                current->value->data_type,
                current->value->type,
                current->value->line_no);
        current = current->next;
    }
}


int main(void) {
    dataType* value1 = create_dataType("test1", "int", "number", 6);
    dataType* value2 = create_dataType("test2", "bool", "boolean", 10);
    dataType* value3 = create_dataType("test3", "char", "character", 15);

    Node* mylist = init_list(value1);
    add_value(mylist, value2);
    print_linked_list(mylist);
    add_value(mylist, value3);
    print_linked_list(mylist);

    return 0;
};
