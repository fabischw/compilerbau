#ifndef TREE_H

  #define TREE_H
 
  #include "tree.c"

  Node* create_node(char* token);
  void free_node(Node** node);
  void traverse(Node* root);

#endif
