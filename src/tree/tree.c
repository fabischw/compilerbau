#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "tree.h"

Node*
create_node(char* token, Node* leftNode, Node* rightNode)
{
  Node* node = malloc(sizeof(Node));  
  char *tokencpy = (char *)malloc(strlen(token)+1);
  strcpy(tokencpy, token);
  node->leftNode = leftNode;
  node->rightNode = rightNode;
  node->token = tokencpy;
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

void _traverse(Node* root, int depth);

void
traverse(Node* node) {
  _traverse(node, 0);
}

void
_traverse(Node* root, int depth)
{
  if(root == NULL) {
    for (int i = 0; i < depth; i++) {
      printf("   ");
    }
    printf("\n");
    return;
  }
  _traverse(root->leftNode, depth+1);
  for (int i = 0; i < depth; i++) {
    printf("   ");
  }
  if (strlen(root->token) == 0) {
    printf("EMPTY\n");
  } else {
    printf("%s\n", root->token);
  }
  _traverse(root->rightNode, depth+1);
}
