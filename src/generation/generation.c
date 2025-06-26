#include "generation.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define MAX_PAGE_SIZE 2000

typedef enum _Register
{
  R8,
  R9,
  R10,
  R11,
  R12,
  R13,
} Register;

Register free_register;

int counter = 0;
char label_buffer[10] = {0};

char buffer[MAX_PAGE_SIZE];
char definition_buffer[MAX_PAGE_SIZE];
char declaration_buffer[MAX_PAGE_SIZE];

void create_var_declaration(T_Node* declaration_node);
void assign_variable(T_Node* assign_node);
void create_if_clause(T_Node* if_node);
void create_function_call(T_Node* function_node);
void create_loop(T_Node* loop_node);
char* create_label();
char* solve_logical_expression(T_Node* logical_expr_root);

char*
register_to_string(Register reg)
{
  switch(reg)
  {
    case R8: return "r8d";
    case R9: return "r9d";
    case R10: return "r10d";
    case R11: return "r11d";
    case R12: return "r12d";
    case R13: return "r13d";
  }  
}

void
generate_assembly_(T_Node* root)
{
  switch(root->ast_type)
  {
    case ast_statement:
      if(root != NULL && !t_is_node_empty(root))
      {
      if(root->rightNode != NULL)
      {
      generate_assembly_(root->rightNode);
      }
      if(root->leftNode != NULL)
      {
      generate_assembly_(root->leftNode);
      }
      }
      break;
    case ast_variable_declaration:
    case ast_variable_declaration_const:
      create_var_declaration(root);
      break;
    case ast_assignment:
      assign_variable(root);
      break;
    case ast_condition_if:
      create_if_clause(root);
      break;
    case ast_function_call:
      create_function_call(root);
      break;
    case ast_loop_declaration:
      create_loop(root);
      break;
    default: break;
  }
}

void
generate_assembly(T_Node* root)
{
  const char* includes = "format elf64 executable\n\n\
include \"../src/asmlib/definitions.asm\"\ninclude \
\"../src/asmlib/functions.asm\"\ninclude \"../src/asmlib/structures.asm\"\n";
  if(root != NULL && !t_is_node_empty(root))
  {
  generate_assembly_(root);  
  }

  FILE* fp = fopen("build/main.asm", "w");
  if(fp)
  {
    fprintf(fp, "%s\n%s\n%sexit 0\n\n%s%s", includes, definition_buffer, buffer, declaration_buffer, "\nconversion_buffer: times 11 db 0");
    fclose(fp);
  }

  //system("fasm build/main.asm");
}

void
create_function_call(T_Node* function_node)
{
  char* fn_id = function_node->leftNode->value;  
  if(!strcmp(fn_id, "exit"))
  {
  sprintf(buffer+strlen(buffer), "%s %d\n", fn_id, 0);  
  } else if(!strcmp(fn_id, "print"))
  {
  T_Node* params = function_node->rightNode;
  char* arg_buf = params->leftNode->value;
  if(!t_is_node_empty(params->leftNode))
  {
    create_function_call(params->leftNode);
    arg_buf = "conversion_buffer";
  }
  if(arg_buf != NULL && strcmp(arg_buf, "") && arg_buf[0] == '\"')
  {
    char* str_label = strdup(create_label());
    sprintf(declaration_buffer+strlen(declaration_buffer), "%s: db %s, 0xA, 0x0\n", str_label, arg_buf);    
    sprintf(buffer+strlen(buffer), "%s %s\n", fn_id, str_label);    
    free(str_label);
  } else
  {
    sprintf(buffer+strlen(buffer), "%s %s\n", fn_id, arg_buf);    
  }
  } else if(!strcmp(fn_id, "tostr"))
  {
    T_Node* params = function_node->rightNode;
    sprintf(buffer+strlen(buffer), "%s %s\n", fn_id, params->leftNode->value);  
    
  }
}

const char*
parse_operator(char* operator, int negated)
{
  if(!strcmp(operator, "==")) return  negated ? "not_equal" : "equal";
  if(!strcmp(operator, "!=")) return  negated ? "equal" : "not_equal";
  if(!strcmp(operator, "<=")) return  negated ? "lesser_or_equal" : "greater";
  if(!strcmp(operator, ">=")) return  negated ? "greater_or_equal" : "lesser";
  if(!strcmp(operator, "<")) return  negated ? "greater_or_equal":  "lesser";
  if(!strcmp(operator, ">")) return  negated ? "lesser_or_equal":  "greater";
  return operator;
}

void create_loop(T_Node* loop_node)
{
  T_Node* cmp_expr = loop_node->leftNode;
  char* body_label = strdup(create_label());
  char* exit_label = strdup(create_label());
  char* left_id = cmp_expr->leftNode->value;
  const char* cmp = parse_operator(cmp_expr->value, 1);
  char* right_id = cmp_expr->rightNode->value;
  
  sprintf(buffer+strlen(buffer), "while %s, %s, %s, %s\njmp %s\n%s:\n", left_id, cmp, right_id, body_label, exit_label, body_label);
  generate_assembly_(loop_node->rightNode);
  sprintf(buffer+strlen(buffer), "ret\n%s:\n", exit_label);
  free(exit_label);
  free(body_label);
}

char*
create_label()
{
  memset(label_buffer, ' ', 10);
  sprintf(label_buffer, "%s%d", "label", counter);
  counter++;
  return label_buffer;
}

void
create_if_clause(T_Node* if_node)
{
  T_Node* if_content = if_node->leftNode;
  T_Node* if_else = if_node->rightNode;
  char* left_side;
  if(t_is_node_empty(if_content->leftNode))
  {
    left_side = if_content->leftNode->value;
  } else {
    left_side = solve_logical_expression(if_content->leftNode);    
  }
  const char*  operator = "equal";
  char* right_side = "1";
  
  
  char* label_if_done = strdup(create_label());
  char* label_if_exit = strdup(create_label());
  sprintf(buffer+strlen(buffer), "if %s, %s, %s, %s, %s\n%s:\n",
         left_side, operator, right_side, 
         label_if_done, label_if_exit, label_if_done);
  generate_assembly_(if_content->rightNode);
  sprintf(buffer+strlen(buffer), "%s:\n", label_if_exit); 
  if(if_else != NULL && if_else->ast_type == ast_condition_else)
  {
    char* label_else_done = strdup(create_label());
    char* label_else_exit = strdup(create_label());
    const char* else_operator = "not_equal";
    sprintf(buffer+strlen(buffer), "if %s, %s, %s, %s, %s\n%s:\n",
           left_side, else_operator, right_side,
         label_else_done, label_else_exit, label_else_done);
    generate_assembly_(if_else->leftNode);
    sprintf(buffer+strlen(buffer), "%s:\n", label_else_exit);

    free(label_else_done);
    free(label_else_exit);
  } 
  free(label_if_done);
  free(label_if_exit);
}

char*
solve_logical_expression(T_Node* logical_expr_root)
{
  char* left_id;
  char* right_id;
  char* curr_reg = register_to_string(free_register);
  if(t_is_node_empty(logical_expr_root->leftNode))
  {
    left_id = logical_expr_root->leftNode->value;
    if(!strcmp(left_id, "True")) left_id = "1";
    if(!strcmp(left_id, "False")) left_id = "0";
  } else
  {
    free_register++;
    left_id = solve_logical_expression(logical_expr_root->leftNode);
    if(!strcmp(left_id, "True")) left_id = "1";
    if(!strcmp(left_id, "False")) left_id = "0";
    //free_register--;
  }
  if(t_is_node_empty(logical_expr_root->rightNode))
  {
    right_id = logical_expr_root->rightNode->value;
    if(!strcmp(right_id, "True")) right_id =  "1";
    if(!strcmp(right_id, "False")) right_id = "0";
  } else
  {
    free_register++;
    right_id = solve_logical_expression(logical_expr_root->rightNode); 
    if(!strcmp(right_id, "True")) right_id =  "1";
    if(!strcmp(right_id, "False")) right_id = "0";
    free_register--;
  }
  char* comparator = logical_expr_root->value;
  if(!strcmp(comparator, "||"))
  {
    sprintf(buffer+strlen(buffer), "mov %s, %s\nor %s, %s\n", curr_reg, left_id, curr_reg, right_id);
  }
  else if(!strcmp(comparator, "&&"))
  {
    sprintf(buffer+strlen(buffer), "mov %s, %s\nand %s, %s\n", curr_reg, left_id, curr_reg, right_id);
    //sprintf(buffer+strlen(buffer), "curr_reg: %s, left_id: %s, right_id: %s\n", curr_reg, left_id, right_id);
  }
  else if(!strcmp(comparator, ">"))
  {
    char* true_label = strdup(create_label());
    char* exit_label = strdup(create_label());
    sprintf(buffer+strlen(buffer),
"mov eax, %s\nmov ebx, %s\ncmp eax, ebx\njg %s\nmov %s, 0\njmp %s\n%s:\nmov %s, 1\n%s:\n",
left_id, right_id, true_label, curr_reg, exit_label, true_label, curr_reg, exit_label);
    // left_id < right_id ; saved in curr_reg
    // cmp left_id  right_id
    // jg .label
    // mov reg, 0
    // jmp .label2
    // .label:
    // mov reg, 1
    // label2:
  }
  
  else if(strcmp(comparator, "=") != 0)
  {
    char* true_label = strdup(create_label());
    char* false_label = strdup(create_label());
    char* jmp_label = strdup(create_label());
    sprintf(buffer+strlen(buffer), 
     "if %s, %s, %s, %s, %s\n%s:\nmov %s, 1\njmp %s\n%s:\nmov %s, 0\n%s:\n",
     left_id, parse_operator(comparator, 0), right_id, true_label, false_label,
     true_label, curr_reg, jmp_label, false_label,
     curr_reg, jmp_label);


    free(true_label);
    free(false_label);
    free(jmp_label);
  }

  if(!t_is_node_empty(logical_expr_root->leftNode)) free_register--;
  //if(!t_is_node_empty(logical_expr_root->rightNode)) free_register--;
   
  return curr_reg;
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
    sprintf(buffer+strlen(buffer), "xor %s, %s\n add %s, %s\n add %s, %s\n", curr_reg, curr_reg, curr_reg, left_id, curr_reg, right_id);    
  } 
  else if(!strcmp(arith_expr_root->value, "-"))
  {
    
    sprintf(buffer+strlen(buffer), "xor %s, %s\n mov %s, %s\n sub %s, %s\n", curr_reg, curr_reg, curr_reg, left_id, curr_reg, right_id);    
  }
  else if(!strcmp(arith_expr_root->value, "*"))
  {
    sprintf(buffer+strlen(buffer), "mov %s, 1\nimul %s, %s\n imul %s, %s\n", curr_reg, curr_reg, left_id, curr_reg, right_id);
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
      case ast_logical_expression:
        value = solve_logical_expression(assign_node->rightNode);
      default: break;
    }
  }
  sprintf(buffer+strlen(buffer), "mov %s, %s\n", identifier, value);
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
      case ast_arithmetic_expression:
        value = solve_arithmetic_expression(declaration_node->rightNode->rightNode);
        break;
      case ast_logical_expression:
        value = solve_logical_expression(declaration_node->rightNode);
      default: break;
    }
  }
  if(!strcmp(type, "int"))
  {
  sprintf(definition_buffer+strlen(definition_buffer), "%s equ dword [%s_%s]\n", identifier, type, identifier);
  sprintf(declaration_buffer+strlen(declaration_buffer), "%s_%s: dd 0\n", type, identifier);
  sprintf(buffer+strlen(buffer), "mov  %s, %s\n", identifier, value);
  }
  if(!strcmp(type, "float"))
  { 
    sprintf(definition_buffer+strlen(definition_buffer), "%s equ dword [%s_%s]\n", identifier, type, identifier);
    sprintf(declaration_buffer+strlen(declaration_buffer), "%s_%s: dd 0\n", type, identifier);
    sprintf(buffer+strlen(buffer), "mov  %s, %f\n", identifier, strtof(value, NULL));
  }
  if(!strcmp(type, "char"))
  {
    sprintf(definition_buffer+strlen(definition_buffer), "%s equ dword [%s_%s]\n", identifier, type, identifier);
    sprintf(declaration_buffer+strlen(declaration_buffer), "%s_%s: dd 0\n", type, identifier);
    sprintf(buffer+strlen(buffer), "mov  %s, %s\n", identifier, value);
  }
  if(!strcmp(type, "str"))
  {
    sprintf(declaration_buffer+strlen(declaration_buffer), "%s : db %s, 0xA, 0x0\n", identifier, value);
    
  }
  if(!strcmp(type, "bool"))
  {
    if(!strcmp(value, "True")) value = "1";
    if(!strcmp(value, "False")) value = "0";
    sprintf(definition_buffer+strlen(definition_buffer), "%s equ dword [%s_%s]\n", identifier, type, identifier);
    sprintf(declaration_buffer+strlen(declaration_buffer), "%s_%s: dd 0\n", type, identifier);
    sprintf(buffer+strlen(buffer), "mov  %s, %s\n", identifier, value);
  }
}
