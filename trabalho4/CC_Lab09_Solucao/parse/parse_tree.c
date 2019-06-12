
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parse_tree.h"

#define CHILDREN_LIMIT 7
#define TEXT_LIMIT 256

struct node {
    char text[TEXT_LIMIT];
    int count;
    ParseTree* child[CHILDREN_LIMIT];
};

ParseTree* new_node(const char *text) {
    ParseTree* node = malloc(sizeof * node);
    strcpy(node->text, text);
    node->count = 0;
    for (int i = 0; i < CHILDREN_LIMIT; i++) {
        node->child[i] = NULL;
    }
    return node;
}

void add_child(ParseTree *parent, ParseTree *child) {
    if (parent->count == CHILDREN_LIMIT) {
        fprintf(stderr, "Cannot add another child!\n");
        exit(1);
    }
    parent->child[parent->count] = child;
    parent->count++;
}

ParseTree* new_subtree(const char *text, int child_count, ...) {
    if (child_count > CHILDREN_LIMIT) {
        fprintf(stderr, "Too many children as arguments!\n");
        exit(1);
    }

    ParseTree* node = new_node(text);
    va_list ap;
    va_start(ap, child_count);
    for (int i = 0; i < child_count; i++) {
        add_child(node, va_arg(ap, ParseTree*));
    }
    va_end(ap);
    return node;
}

void free_tree(ParseTree *tree) {
    for (int i = 0; i < tree->count; i++) {
        free_tree(tree->child[i]);
    }
    free(tree);
}

// Dot output.

int nr;

int print_node_dot(ParseTree *node) {
    int my_nr = nr++;
    printf("node%d[label=\"%s\"];\n", my_nr, node->text);
    for (int i = 0; i < node->count; i++) {
        int child_nr = print_node_dot(node->child[i]);
        printf("node%d -> node%d;\n", my_nr, child_nr);
    }
    return my_nr;
}

void print_dot(ParseTree *tree) {
    nr = 0;
    printf("digraph {\ngraph [ordering=\"out\"];\n");
    print_node_dot(tree);
    printf("}\n");
}
