#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include "tree.h"
#include "../typing/typing.h"
#include "ast_type.h"

T_Node*
t_create_node(AstType ast_type, char* value, int lineno, T_Node* leftNode, T_Node* rightNode)
{
  T_Node* node = malloc(sizeof(T_Node));  
  node->leftNode = leftNode;
  node->rightNode = rightNode;
  node->ast_type = ast_type;
  node->value = value ? strdup(value) : NULL;
  node->operator = OP_NULL;
  node->is_constant = false;
  node->var_type = TYP_UNKNOWN;
  node->lineno = lineno;
  return node;
}

void
t_free_node(T_Node** node)
{
  if(*node == NULL) return;
  t_free_node(&(*node)->leftNode);
  t_free_node(&(*node)->rightNode);
  free((*node)->value);
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
    /*for(int i = 0; i < depth; i++) printf("  ");
    printf("\n");*/
    return;
  }
  t_traverse_(root->leftNode, depth+1);
  for(int i = 0; i < depth; i++) printf("  ");
  printf("%s", ast_type_to_string(root->ast_type));
  if (root->value) {
    printf(" \"%s\"", root->value);
  }
  printf("\n");
  t_traverse_(root->rightNode, depth+1);
}
