
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

// Symbols Table
// ----------------------------------------------------------------------------

#define SYMBOL_MAX_SIZE 128
#define SYMBOL_TABLE_MAX_SIZE 100

typedef struct {
  char name[SYMBOL_MAX_SIZE];
  int line;
} Entry;

struct sym_table {
    Entry t[SYMBOL_TABLE_MAX_SIZE];
    int size;
};

SymTable* create_sym_table() {
    SymTable *st = malloc(sizeof * st);
    st->size = 0;
    return st;
}

int lookup_var(SymTable* st, char* s) {
    for (int i = 0; i < st->size; i++) {
        if (strcmp(st->t[i].name, s) == 0)  {
            return i;
        }
    }
    return -1;
}

int add_var(SymTable* st, char* s, int line) {
    strcpy(st->t[st->size].name, s);
    st->t[st->size].line = line;
    int idx_added = st->size;
    st->size++;
    return idx_added;
}

char* get_sym_name(SymTable* st, int i) {
    return st->t[i].name;
}

int get_sym_line(SymTable* st, int i) {
    return st->t[i].line;
}

void print_sym_table(SymTable* st) {
    printf("Variables table:\n");
    for (int i = 0; i < st->size; i++) {
         printf("Entry %d -- name: %s, line: %d\n", i, get_sym_name(st, i), get_sym_line(st, i));
    }
}

void free_sym_table(SymTable* st) {
    free(st);
}

// Functions Table
// ----------------------------------------------------------------------------

#define FUNCTION_MAX_SIZE 128
#define FUNCTION_TABLE_MAX_SIZE 100

typedef struct {
  char name[FUNCTION_MAX_SIZE];
  int line;
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

int add_func(FuncTable* fn, char* s, int line) {
    strcpy(fn->t[fn->size].name, s);
    fn->t[fn->size].line = line;
    int idx_added = fn->size;
    fn->size++;
    return idx_added;
}

char* get_func_name(FuncTable* fn, int i) {
    return fn->t[i].name;
}

int get_func_line(FuncTable* fn, int i) {
    return fn->t[i].line;
}

void print_func_table(FuncTable* fn) {
    printf("Functions table:\n");
    for (int i = 0; i < fn->size; i++) {
         printf("Entry %d -- name: %s, line: %d\n", i, get_func_name(fn, i), get_func_line(fn, i));
    }
}

void free_func_table(FuncTable* fn) {
    free(fn);
}