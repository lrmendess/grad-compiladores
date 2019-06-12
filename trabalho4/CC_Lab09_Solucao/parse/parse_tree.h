#ifndef PARSE_TREE_H
#define PARSE_TREE_H

struct node; // Opaque structure to ensure encapsulation.

typedef struct node ParseTree;

ParseTree* new_node(const char *text);

void add_child(ParseTree *parent, ParseTree *child);

ParseTree* new_subtree(const char *text, int child_count, ...);

void free_tree(ParseTree *tree);

void print_dot(ParseTree *tree);

#endif
