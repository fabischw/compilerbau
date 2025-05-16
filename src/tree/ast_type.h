#ifndef AST_TYPE.H
    #define AST_TYPE_H

    typedef enum _AstType {
        statement,
        expression,
        loop_declaration,
        condition_if,
        condition_content,
        condition_elif,
        condition_else,
        variable_declaration,
        datatype,
        assignment,
        variable_declaration_const,
        array_declaration,
        array_indexing,
        logical_expression,
        arithmetic_expression,
        unary_expression,
        function_call,
        parameters,
        INTEGER,
        FLOAT,
        BOOLEAN,
        STRING,
        CHARACTER,
        IDENTIFIER,
        array,
        array_item
    } AstType;

#endif