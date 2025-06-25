#ifndef TREE_H

  #define TREE_H
  #include "../typing/typing.h"
  #include "ast_type.h"
  #include "../tree/ast_type.h"
  #include <stdbool.h>
 
  typedef struct _t_node
  {
  
    struct _t_node* leftNode;
    struct _t_node* rightNode;
  
    AstType ast_type;
    char* value;
    Operator operator;
    bool is_constant;
    VarType var_type;
    int lineno;
    
    
  } T_Node;


  T_Node* t_create_node(AstType ast_type, char* value, int lineno, T_Node* leftNode, T_Node* rightNode);
  void t_free_node(T_Node** node);
  void t_traverse_(T_Node* root, int depth);
  void t_traverse(T_Node* root);
  int t_is_node_empty(T_Node* node);

#endif
