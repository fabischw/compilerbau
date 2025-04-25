#include <stdlib.h>
#include <stdio.h>
#include "tree.h"

Node*
create_node(char* token)
{
  Node* node = malloc(sizeof(Node));  
  node->leftNode = NULL;
  node->rightNode = NULL;
  node->token = token;
  return node;
}

void
free_node(Node** node)
{
  if(*node == NULL) return;
  free_node(&(*node)->leftNode);
  free_node(&(*node)->rightNode);
  free(*node);
  *node = NULL;
}

void
traverse(Node* root)
{
  if(root == NULL) return;
  traverse(root->leftNode);
  printf("%s\n", root->token);
  traverse(root->rightNode);
}
