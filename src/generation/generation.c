#include "generation.h"
#include <stdio.h>
#include <string.h>

typedef enum _Register
{
  R8,
  R9,
  R10,
  R11,
  R12,
  R13,
} Register;

int free_register;



void create_var_declaration(T_Node* declaration_node);
void assign_variable(T_Node* assign_node);

char*
register_to_string(Register reg)
{
  switch(reg)
  {
    case R8: return "R8";
    case R9: return "R9";
    case R10: return "R10";
    case R11: return "R11";
    case R12: return "R12";
    case R13: return "R13";
  }  
}

void
generate_assembly(T_Node* root)
{
  switch(root->ast_type)
  {
    case ast_statement:
      generate_assembly(root->rightNode);
      generate_assembly(root->leftNode);
      break;
    case ast_variable_declaration:
    case ast_variable_declaration_const:
      create_var_declaration(root);
      break;
    case ast_assignment:
      assign_variable(root);
      break;
    default: break;
  }
}

char*
solve_arithmetic_expression(T_Node* arith_expr_root)
{
  char* left_id;
  char* right_id;
  char* curr_reg = register_to_string(free_register);
  if(t_is_node_empty(arith_expr_root->leftNode))
  {
    left_id = arith_expr_root->leftNode->value;
  } else
  {
    free_register++;
    left_id = solve_arithmetic_expression(arith_expr_root->leftNode);
    free_register--;
  }
  if(t_is_node_empty(arith_expr_root->rightNode))
  {
    right_id = arith_expr_root->rightNode->value;
  } else
  {
    free_register++;
    right_id = solve_arithmetic_expression(arith_expr_root->rightNode); 
    free_register--;
  }
  // add other types of math
  // also check for diff types of variables e.g. float
  if(!strcmp(arith_expr_root->value, "+"))
  {
  printf("xor %s, %s\n add r8, %s\n add r8, %s\n", curr_reg, curr_reg, left_id, right_id);    
  } 
  else if(!strcmp(arith_expr_root->value, "-"))
  {
    
  }
  else if(!strcmp(arith_expr_root->value, "*"))
  {
    
  }
  else if(!strcmp(arith_expr_root->value, "/"))
  {
    
  }
  // ...
  return curr_reg;
}

void
assign_variable(T_Node* assign_node)
{
  const char* identifier = assign_node->leftNode->value;
  char* value;
  if(t_is_node_empty(assign_node->rightNode))
  {
    value = assign_node->rightNode->value;
  } else
  {
    switch(assign_node->rightNode->ast_type)
    {
      case ast_arithmetic_expression:
        value = solve_arithmetic_expression(assign_node->rightNode);
        break;
      default: break;
    }
  }
  printf("mov %s, %s\n", identifier, value);
}

void
create_var_declaration(T_Node* declaration_node)
{
  int is_const = ast_variable_declaration_const == declaration_node->ast_type;
  const char* type = declaration_node->leftNode->value;
  const char* identifier = declaration_node->rightNode->leftNode->value;
  char* value;
  if(t_is_node_empty(declaration_node->rightNode->rightNode))
  {
    value = declaration_node->rightNode->rightNode->value;
  } else {
    switch(declaration_node->rightNode->rightNode->ast_type)
    {
      // TODO: add more expressions!
      case ast_arithmetic_expression:
        value = solve_arithmetic_expression(declaration_node->rightNode->rightNode);
        break;
      default: break;
    }
  }
  // TODO: idk what to do with is_const
  // TODO: assignment type changes with value type
  if(!strcmp(type, "int") || !strcmp(type, "float") || !strcmp(type, "bool"))
  {
  printf("%s equ dword [%s_%s]\n%s_%s: dd 0\nmov %s, %s\n", identifier, type, identifier, type, identifier, identifier, value);
  }
  else if(!strcmp(type, "char"))
  {printf("%s equ dword [%s_%s]\n%s_%s: db 0\nmov %s, %s\n", identifier, type, identifier, type, identifier, identifier, value);
    
  }
  else if(!strcmp(type, "string"))
  {
    // is string addition allowed if not just add string like in example
    
  }
}
