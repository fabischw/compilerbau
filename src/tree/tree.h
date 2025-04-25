#ifndef TREE_H

  #define TREE_H
 
  typedef struct _node
  {
  
    struct _node* leftNode;
    struct _node* rightNode;
  
    char* token;
    
  } Node;


  Node* create_node(char* token);
  void free_node(Node** node);
  void traverse(Node* root);

#endif
