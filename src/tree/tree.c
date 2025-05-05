#include <stdlib.h>
#include <stdio.h>
#include "tree.h"

T_Node*
t_create_node(char* token, T_Node* leftNode, T_Node* rightNode)
{
  T_Node* node = malloc(sizeof(T_Node));  
  node->leftNode = leftNode;
  node->rightNode = rightNode;
  node->token = token;
  return node;
}

void
t_free_node(T_Node** node)
{
  if(*node == NULL) return;
  t_free_node(&(*node)->leftNode);
  t_free_node(&(*node)->rightNode);
  free(*node);
  *node = NULL;
}

void
t_traverse(T_Node* root)
{
  if(root == NULL) return;
  t_traverse(root->leftNode);
  printf("%s\n", root->token);
  t_traverse(root->rightNode);
}
