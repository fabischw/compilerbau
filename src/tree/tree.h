#ifndef TREE_H

  #define TREE_H
 
  typedef struct _t_node
  {
  
    struct _t_node* leftNode;
    struct _t_node* rightNode;
  
    char* token;
    
  } T_Node;


  T_Node* t_create_node(char* token, T_Node* leftNode, T_Node* rightNode);
  void t_free_node(T_Node** node);
  void t_traverse(T_Node* root);

#endif
