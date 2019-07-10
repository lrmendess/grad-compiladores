#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "tables.h"

// Literals Table
// ----------------------------------------------------------------------------

#define LITERAL_MAX_SIZE 128
#define LITERALS_TABLE_MAX_SIZE 100

struct lit_table {
    char t[LITERALS_TABLE_MAX_SIZE][LITERAL_MAX_SIZE];
    int size;
};

LitTable* create_lit_table() {
    LitTable *lt = malloc(sizeof * lt);
    lt->size = 0;
    return lt;
}

int add_literal(LitTable* lt, char* s) {
    for (int i = 0; i < lt->size; i++) {
        if (strcmp(lt->t[i], s) == 0) {
            return i;
        }
    }
    strcpy(lt->t[lt->size], s);
    int idx_added = lt->size;
    lt->size++;
    return idx_added;
}

char* get_literal(LitTable* lt, int i) {
    return lt->t[i];
}

void print_lit_table(LitTable* lt) {
    printf("Literals table:\n");
    for (int i = 0; i < lt->size; i++) {
        printf("Entry %d -- %s\n", i, get_literal(lt, i));
    }
}

void free_lit_table(LitTable* lt) {
    free(lt);
}

// Variables Table
// ----------------------------------------------------------------------------

#define VARIABLE_MAX_SIZE 128
#define VARIABLE_TABLE_MAX_SIZE 100

typedef struct {
    char name[VARIABLE_MAX_SIZE];
    int line;
    int scope;
    int size;
    int offset;
} VariableEntry;

struct var_table {
    VariableEntry t[VARIABLE_TABLE_MAX_SIZE];
    int size;
};

VarTable* create_var_table() {
    VarTable *st = malloc(sizeof * st);
    st->size = 0;
    return st;
}

int lookup_var(VarTable* st, char* s, int current_scope) {
    for (int i = 0; i < st->size; i++) {
//      Checa se uma variavel de mesmo escopo esta na tabela de variaveis
        if ((strcmp(st->t[i].name, s) == 0) && (st->t[i].scope == current_scope)) {
            return i;
        }
    }
    return -1;
}

int add_var(VarTable* st, char* s, int line, int scope, int size) {
    strcpy(st->t[st->size].name, s);
    st->t[st->size].line = line;
    st->t[st->size].scope = scope;
    st->t[st->size].size = size;
    st->t[st->size].offset = -1;
    int idx_added = st->size;
    st->size++;
    return idx_added;
}

void set_var_offset(VarTable* st, int i, int offset) {
    st->t[i].offset = offset;
}

int get_var_offset(VarTable* st, int i) {
    return st->t[i].offset;
}

char* get_var_name(VarTable* st, int i) {
    return st->t[i].name;
}

int get_var_line(VarTable* st, int i) {
    return st->t[i].line;
}

int get_var_scope(VarTable* st, int i) {
    return st->t[i].scope;
}

int get_var_size(VarTable* st, int i) {
    return st->t[i].size;
}

void print_var_table(VarTable* st) {
    printf("Variables table:\n");
    for (int i = 0; i < st->size; i++) {
        printf("Entry %d -- name: %s, line: %d, scope: %d, size: %d\n", i,
        get_var_name(st, i),
        get_var_line(st, i),
        get_var_scope(st, i),
        get_var_size(st, i));
    }
}

void free_var_table(VarTable* st) {
    free(st);
}

// Functions Table
// ----------------------------------------------------------------------------

#define FUNCTION_MAX_SIZE 128
#define FUNCTION_TABLE_MAX_SIZE 100

typedef struct {
    char name[FUNCTION_MAX_SIZE];
    int line;
    int arity;
    AST* func_ast;
} FunctionEntry;

struct func_table {
    FunctionEntry t[FUNCTION_TABLE_MAX_SIZE];
    int size;
};

FuncTable* create_func_table() {
    FuncTable *fn = malloc(sizeof * fn);
    fn->size = 0;
    return fn;
}

int lookup_func(FuncTable* fn, char* s) {
    for (int i = 0; i < fn->size; i++) {
        if (strcmp(fn->t[i].name, s) == 0)  {
            return i;
        }
    }
    return -1;
}

int add_func(FuncTable* fn, char* s, int line, int arity) {
    strcpy(fn->t[fn->size].name, s);
    fn->t[fn->size].line = line;
    fn->t[fn->size].arity = arity;
    int idx_added = fn->size;
    fn->size++;
    return idx_added;
}

void set_func_ast(FuncTable* fn, int i, AST* func_ast) {
    fn->t[i].func_ast = func_ast;
}

AST* get_func_ast(FuncTable* fn, int i) {
    return fn->t[i].func_ast;
}

char* get_func_name(FuncTable* fn, int i) {
    return fn->t[i].name;
}

int get_func_line(FuncTable* fn, int i) {
    return fn->t[i].line;
}

int get_func_arity(FuncTable* fn, int i) {
    return fn->t[i].arity;
}

void print_func_table(FuncTable* fn) {
    printf("Functions table:\n");
    for (int i = 0; i < fn->size; i++) {
        printf("Entry %d -- name: %s, line: %d, arity: %d\n", i,
            get_func_name(fn, i),
            get_func_line(fn, i),
            get_func_arity(fn, i)
        );
    }
}

void free_func_table(FuncTable* fn) {
    free(fn);
}
