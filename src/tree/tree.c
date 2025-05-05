#include <stdlib.h>
#include <stdio.h>
#include <string.h>
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
  t_traverse_(root, 0);
}

void
t_traverse_(T_Node* root, int depth)
{
  if(root == NULL)
  {
    for(int i = 0; i < depth; i++) printf("    ");
    printf("\n");
    return;
  }
  t_traverse_(root->leftNode, depth+1);
  for(int i = 0; i < depth; i++) printf("    ");
  if(strlen(root->token) == 0)
  {
    printf("EMPTY\n");
  } else
  {
    printf("%s\n", root->token);
  }
  t_traverse_(root->rightNode, depth+1);
}
