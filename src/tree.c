#include <stdlib.h>
#include <stdio.h>

typedef struct _node
{

  struct _node* leftNode;
  struct _node* rightNode;

  int value;
  
} Node;

Node*
create_node(int value)
{
  Node* node = malloc(sizeof(Node));  
  node->leftNode = NULL;
  node->rightNode = NULL;
  node->value = value;
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
  printf("%d\n", root->value);
  traverse(root->rightNode);
}
