#ifndef TABLES_H
#define TABLES_H

#include "ast.h"

// Literals Table
// ----------------------------------------------------------------------------

// Opaque structure.
// For simplicity, the table is implemented as a sequential list.
struct lit_table;
typedef struct lit_table LitTable;

// Creates an empty literal table.
LitTable* create_lit_table();

// Adds the given string to the table without repetitions.
// String 's' is copied internally.
// Returns the index of the string in the table.
int add_literal(LitTable* lt, char* s);

// Returns a pointer to the string stored at index 'i'.
char* get_literal(LitTable* lt, int i);

// Prints the given table to stdout.
void print_lit_table(LitTable* lt);

// Clears the allocated structure.
void free_lit_table(LitTable* lt);


// Symbols Table
// ----------------------------------------------------------------------------

// Opaque structure.
// For simplicity, the table is implemented as a sequential list.
// This table only stores the variable name and the declaration line.
struct var_table;
typedef struct var_table VarTable;

// Creates an empty symbol table.
VarTable* create_var_table();

// Adds a fresh var to the table.
// No check is made by this function, so make sure to call 'lookup_var' first.
// Returns the index where the variable was inserted.
int add_var(VarTable* st, char* s, int line, int scope, int size);

// Returns the index where the given variable is stored or -1 otherwise.
int lookup_var(VarTable* st, char* s, int current_scope);

// Returns the variable name stored at the given index.
// No check is made by this function, so make sure that the index is valid first.
char* get_var_name(VarTable* st, int i);

// Returns the declaration line of the variable stored at the given index.
// No check is made by this function, so make sure that the index is valid first.
int get_var_line(VarTable* st, int i);

int get_var_scope(VarTable* st, int i);

int get_var_size(VarTable* st, int i);

// Prints the given table to stdout.
void print_var_table(VarTable* st);

// Clears the allocated structure.
void free_var_table(VarTable* st);


// Functions Table
// ----------------------------------------------------------------------------

// Opaque structure.
// For simplicity, the table is implemented as a sequential list.
// This table only stores the function name and the declaration line.
struct func_table;
typedef struct func_table FuncTable;

// Creates an empty symbol table.
FuncTable* create_func_table();

// Adds a fresh func to the table.
// No check is made by this function, so make sure to call 'lookup_var' first.
// Returns the index where the function was inserted.
int add_func(FuncTable* fn, char* s, int line, int arity);

// Returns the index where the given function is stored or -1 otherwise.
int lookup_func(FuncTable* fn, char* s);

/*
 * Novas funcoes
 */
void set_func_ast(FuncTable* fn, int i, AST* func_ast);

AST* get_func_ast(FuncTable* fn, int i);

// Returns the function name stored at the given index.
// No check is made by this function, so make sure that the index is valid first.
char* get_func_name(FuncTable* fn, int i);

// Returns the declaration line of the function stored at the given index.
// No check is made by this function, so make sure that the index is valid first.
int get_func_line(FuncTable* fn, int i);

int get_func_arity(FuncTable* fn, int i);

// Prints the given table to stdout.
void print_func_table(FuncTable* fn);

// Clears the allocated structure.
void free_func_table(FuncTable* fn);

#endif // TABLES_H
