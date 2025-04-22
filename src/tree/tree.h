#ifndef TREE_H

  #define TREE_H
 
  #include "tree.c"

  Node* create_node(int value);
  void free_node(Node** node);
  void traverse(Node* root);

#endif
