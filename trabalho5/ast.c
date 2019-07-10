
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

struct node {
    NodeKind kind;
    int data;
    AST* next;
    Children* children;
};

/*
 * Estrutura de lista encadeada com sentinela para substituir o array de
 * tamanho 20 que estava sendo usado na AST.
 * Todos os "metodos" que utilizavam o array foram adaptados para utilizar
 * a lista encadeada, assim mantendo a "interface" ja pre-definida.
 */
struct node_list {
    int size;
    AST* first;
    AST* last;
};

AST* new_node(NodeKind kind, int data) {
    AST* node = (AST*) malloc(sizeof(AST));

    node->kind = kind;
    node->data = data;
    node->next = NULL;

    node->children = (Children*) malloc(sizeof(Children));
    node->children->size = 0;
    node->children->first = NULL;
    node->children->last = NULL;
    
    return node;
}

void add_child(AST* parent, AST* child) {
    if (parent->children->first == NULL) {
        parent->children->first = child;
    } else {
        parent->children->last->next = child;
    }

    parent->children->last = child;
    parent->children->size++;
}

AST* get_child(AST* parent, int idx) {
    AST* aux = parent->children->first;
    for (int i = 0; aux != NULL && i < idx; i++, aux = aux->next) { }
    return aux;
}

AST* new_subtree(NodeKind kind, int child_count, ...) {
    AST* node = new_node(kind, 0);
    va_list ap;
    va_start(ap, child_count);

    for (int i = 0; i < child_count; i++) {
        add_child(node, va_arg(ap, AST*));
    }

    va_end(ap);

    return node;
}

NodeKind get_kind(AST* node) {
    return node->kind;
}

int get_data(AST* node) {
    return node->data;
}

int get_child_count(AST* node) {
    return node->children->size;
}

char* kind2str(NodeKind kind) {
    switch(kind) {
        case IF_NODE:           return "if";
        case INPUT_NODE:        return "input";
        case OUTPUT_NODE:       return "output";
        case RETURN_NODE:       return "return";
        case WHILE_NODE:        return "while";
        case WRITE_NODE:        return "write";
        
        case PLUS_NODE:         return "+";
        case MINUS_NODE:        return "-";
        case TIMES_NODE:        return "*";
        case OVER_NODE:         return "/";
        case LT_NODE:           return "<";
        case LE_NODE:           return "<=";
        case GT_NODE:           return ">";
        case GE_NODE:           return ">=";
        case EQ_NODE:           return "==";
        case NEQ_NODE:          return "!=";
        case ASSIGN_NODE:       return "=";

        case BLOCK_NODE:        return "block";
        case VDECL_LIST_NODE:   return "var_list";
        case VDECL_NODE:        return "var_decl";
        case VUSE_NODE:         return "var_use";
        case FLIST_NODE:        return "func_list";
        case FDECL_NODE:        return "func_decl";
        case FHEADER_NODE:      return "func_header";
        case FBODY_NODE:        return "func_body";
        case FNAME_NODE:        return "func_name";
        case PLIST_NODE:        return "param_list";
        case FCALL_NODE:        return "fcall";
        case ALIST_NODE:        return "arg_list";

        case NUM_NODE:          return "num";
        case STRING_NODE:       return "string";
    
        default:                return "ERROR!!";
    }
}

void print_node(AST* node, int level) {
    printf("%d: Node -- Addr: %p -- Kind: %s -- Data: %d -- Count: %d\n",
           level, node, kind2str(node->kind), node->data, node->children->size);

    for (AST* aux = node->children->first; aux != NULL; aux = aux->next) {
        print_node(aux, level + 1);
    }
}

void print_tree(AST* tree) {
    print_node(tree, 0);
}

void free_tree(AST* tree) {
    if (tree == NULL) {
        return;
    }

    AST* aux = tree->children->first;
    AST* prev = aux;
    while (aux != NULL) {
        aux = aux->next;
        free_tree(prev);
        prev = aux;
    }

    free(tree->children);
    free(tree);
}
