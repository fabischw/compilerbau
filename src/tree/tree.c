#include <stdlib.h>
#include <stdio.h>

typedef struct _node
{

  struct _node* leftNode;
  struct _node* rightNode;

  char* token;
  
} Node;

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
