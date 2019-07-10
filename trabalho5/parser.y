/* Options to bison */
// File name of generated parser.
%output "parser.c"
// Produces a 'parser.h'
%defines "parser.h"
// Give proper error messages when a syntax error is found.
%define parse.error verbose
// Enable LAC (lookahead correction) to improve syntax error handling.
%define parse.lac full
// Enable the trace option so that debugging is possible.
%define parse.trace

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "tables.h"
#include "interpreter.h"

int yylex(void);
void yyerror(char const *s);
void yylex_destroy();
extern int yylineno;
extern char* yytext;

/**
 * Adiciona uma variavel na tabela de variaveis com seu tamanho
 */
int add_variable(char* var_name, int size);
/**
 * Valida se uma variavel existe de acordo com seu nome e escopo
 */
int valid_variable(char* var_name);
/**
 * Adiciona uma funcao na tabela de funcoes com sua aridade
 */
int add_function(char* func_name);
/**
 * Valida se uma funcao existe de acordo com seu nome e numero de parametros
 */
int valid_function(char* func_name);
/**
 * Printa as tabelas de literais, funcoes e variaveis
 */
void success_print();

// AST e tabelas de literais, variaveis e funcoes
AST* ast;
LitTable* lit_table;
VarTable* var_table;
FuncTable* func_table;

// Escopo atual na varredura do codigo C-Minus, qtd. de parametros de funcao e tamanho das variaveis
int current_scope = 0, params_count = 0, var_size = 0;

// Auxiliares que carregam os valores de yytext
char func_name[128], var_name[128], var_name_bkp[128];
%}

%define api.value.type {AST*} // Type of variable yylval;

%token ELSE IF INPUT INT OUTPUT RETURN VOID WHILE WRITE SEMI COMMA
%token LBRACK RBRACK LBRACE RBRACE
%precedence LPAREN RPAREN
%token NUM ID STRING
%left LT LE GT GE EQ NEQ
%left PLUS MINUS
%left TIMES OVER
%right ASSIGN
%start program

%%
program:
	func_decl_list { ast = $1; };

func_decl_list:
	func_decl_list func_decl	{ add_child($1, $2); $$ = $1; }
|	func_decl					{ $$ = new_subtree(FLIST_NODE, 1, $1); };

func_decl:
	func_header func_body { $$ = new_subtree(FDECL_NODE, 2, $1, $2); };

func_header:
	ret_type ID { strcpy(func_name, var_name); } LPAREN params RPAREN
	{
		int index = add_function(func_name);
		params_count = 0;

		$$ = new_subtree(FHEADER_NODE, 2, new_node(FNAME_NODE, index), $5);
	};

func_body:
	LBRACE opt_var_decl opt_stmt_list RBRACE
	{
		current_scope++;

		$$ = new_subtree(FBODY_NODE, 2, $2, $3);
	};

opt_var_decl:
	%empty			{ $$ = new_node(VDECL_LIST_NODE, 0); }
|	var_decl_list 	{ $$ = $1; };

opt_stmt_list:
	%empty		{ $$ = new_node(BLOCK_NODE, 0); }
|	stmt_list 	{ $$ = $1; };

ret_type:
	INT
|	VOID;

params:
	VOID		{ $$ = new_node(PLIST_NODE, 0); }
|	param_list 	{ $$ = $1; };

param_list:
	param_list COMMA param 	{ add_child($1, $3); $$ = $1; }
|	param 					{ $$ = new_subtree(PLIST_NODE, 1, $1); };

param:
	INT ID
	{
		int index = add_variable(var_name, 0);
		params_count++;

		$$ = new_node(VDECL_NODE, index);
	}

|	INT ID LBRACK RBRACK
	{
		int index = add_variable(var_name, -1);
		params_count++;

		$$ = new_node(VDECL_NODE, index);
	};

var_decl_list:
	var_decl_list var_decl 	{ add_child($1, $2); $$ = $1; }
|	var_decl 				{ $$ = new_subtree(VDECL_LIST_NODE, 1, $1); };

var_decl:
	INT ID SEMI
	{
		int index = add_variable(var_name, 0);

		$$ = new_node(VDECL_NODE, index);
	}

|	INT ID LBRACK NUM { var_size = atoi(yytext); } RBRACK SEMI
	{
		int index = add_variable(var_name, var_size);
		$$ = new_node(VDECL_NODE, index);
		free_tree($4);
	};

stmt_list:
	stmt_list stmt 	{ add_child($1, $2); $$ = $1; }
|	stmt 			{ $$ = new_subtree(BLOCK_NODE, 1, $1); };

stmt:
	assign_stmt 	{ $$ = $1; }
|	if_stmt 		{ $$ = $1; }
|	while_stmt 		{ $$ = $1; }
|	return_stmt 	{ $$ = $1; }
|	func_call SEMI 	{ $$ = $1; };

assign_stmt:
	lval ASSIGN arith_expr SEMI { $$ = new_subtree(ASSIGN_NODE, 2, $1, $3); };

lval:
	lval_id
	{
		int index = valid_variable(var_name);

		$$ = new_node(VUSE_NODE, index);
	}

|	lval_id LBRACK NUM RBRACK
	{
		int index = valid_variable(var_name);
		$$ = new_node(VUSE_NODE, index);
		free_tree($3);
	}

|	lval_id LBRACK ID RBRACK
	{
		int index = valid_variable(var_name_bkp);
		int index2 = valid_variable(var_name);
		
		$$ = new_node(VUSE_NODE, index);
		add_child($$, new_node(VUSE_NODE, index2));
	};

lval_id:
	ID { strcpy(var_name_bkp, var_name); };

if_stmt:
	IF LPAREN bool_expr RPAREN block 			{ $$ = new_subtree(IF_NODE, 2, $3, $5); }
|	IF LPAREN bool_expr RPAREN block ELSE block { $$ = new_subtree(IF_NODE, 3, $3, $5, $7); };

block:
	LBRACE opt_stmt_list RBRACE { $$ = $2; };

while_stmt:
	WHILE LPAREN bool_expr RPAREN block { $$ = new_subtree(WHILE_NODE, 2, $3, $5); };

return_stmt:
	RETURN SEMI 			{ $$ = new_subtree(RETURN_NODE, 0); }
|	RETURN arith_expr SEMI 	{ $$ = new_subtree(RETURN_NODE, 1, $2); };

func_call:
	output_call 	{ $$ = $1; }
|	write_call 		{ $$ = $1; }
|	user_func_call	{ $$ = $1; };

input_call:
	INPUT LPAREN RPAREN { $$ = new_subtree(INPUT_NODE, 0); };

output_call:
	OUTPUT LPAREN arith_expr RPAREN { $$ = new_subtree(OUTPUT_NODE, 1, $3); };

write_call:
	WRITE LPAREN STRING RPAREN { $$ = new_subtree(WRITE_NODE, 1, $3); };

user_func_call:
	ID { strcpy(func_name, var_name); } LPAREN opt_arg_list RPAREN
	{
		int index = valid_function(func_name);
		params_count = 0;

		$$ = new_node(FCALL_NODE, index);
		add_child($$, $4);
	};

opt_arg_list:
	%empty		{ $$ = new_subtree(ALIST_NODE, 0); }
|	arg_list	{ $$ = $1; };

arg_list:
	arg_list COMMA arith_expr 	{ params_count++; add_child($1, $3); $$ = $1; }
|	arith_expr 					{ params_count++; $$ = new_subtree(ALIST_NODE, 1, $1); };

bool_expr:
	arith_expr LT arith_expr 	{ $$ = new_subtree(LT_NODE, 2, $1, $3); }
|	arith_expr LE arith_expr 	{ $$ = new_subtree(LE_NODE, 2, $1, $3); }
|	arith_expr GT arith_expr 	{ $$ = new_subtree(GT_NODE, 2, $1, $3); }
|	arith_expr GE arith_expr 	{ $$ = new_subtree(GE_NODE, 2, $1, $3); }
|	arith_expr EQ arith_expr 	{ $$ = new_subtree(EQ_NODE, 2, $1, $3); }
|	arith_expr NEQ arith_expr 	{ $$ = new_subtree(NEQ_NODE, 2, $1, $3); };

arith_expr:
	arith_expr PLUS arith_expr 	{ $$ = new_subtree(PLUS_NODE, 2, $1, $3); }
|	arith_expr MINUS arith_expr { $$ = new_subtree(MINUS_NODE, 2, $1, $3); }
|	arith_expr TIMES arith_expr { $$ = new_subtree(TIMES_NODE, 2, $1, $3); }
|	arith_expr OVER arith_expr 	{ $$ = new_subtree(OVER_NODE, 2, $1, $3); }
|	LPAREN arith_expr RPAREN 	{ $$ = $2; }
|	lval 						{ $$ = $1; }
|	input_call 					{ $$ = $1; }
|	user_func_call 				{ $$ = $1; }
|	NUM 						{ $$ = $1; };

%%

int main() {
	lit_table = create_lit_table();
	var_table = create_var_table();
	func_table = create_func_table();

	if (yyparse() == 0) {
		// print_dot(ast);
		// print_tree(ast);
		stdin = fopen(ctermid(NULL), "r");
		run_ast(ast);
		free_tree(ast);
    }

	// Libera os 3 blocos de memoria pendentes do bison
	yylex_destroy();

	// success_print();

	free_lit_table(lit_table);
	free_var_table(var_table);
	free_func_table(func_table);

	return 0;
}

void yyerror (char const *s) {
	printf("PARSE ERROR (%d): %s\n", yylineno, s);
	exit(EXIT_FAILURE);
}

int add_variable(char* var_name, int size) {
	int index = lookup_var(var_table, var_name, current_scope);

	if (index == -1) {
		return add_var(var_table, var_name, yylineno, current_scope, size);
	} else {
		printf("SEMANTIC ERROR (%d): variable '%s' already declared at line %d.\n",
			yylineno, var_name, get_var_line(var_table, index));
		exit(EXIT_FAILURE);
	}
}

int valid_variable(char* var_name) {
	int index = lookup_var(var_table, var_name, current_scope);

	if (index == -1) {
		printf("SEMANTIC ERROR (%d): variable '%s' was not declared.\n",
			yylineno, var_name);
		exit(EXIT_FAILURE);
	}

	return index;
}

int add_function(char* func_name) {
	int index = lookup_func(func_table, func_name);
	
	if (index == -1) {
		return add_func(func_table, func_name, yylineno, params_count);
	} else {
		printf("SEMANTIC ERROR (%d): function '%s' already declared at line %d.\n",
			yylineno, func_name, get_var_line(var_table, index));
		exit(EXIT_FAILURE);
	}
}

int valid_function(char* func_name) {
	int index = lookup_func(func_table, func_name);

	if (index == -1) {
		printf("SEMANTIC ERROR (%d): function '%s' was not declared.\n",
			yylineno, func_name);
		exit(EXIT_FAILURE);
	} else {
		int arity = get_func_arity(func_table, index);

		if (arity != params_count) {
			printf("SEMANTIC ERROR (%d): function '%s' was called with %d arguments"
			" but declared with %d parameters.\n", yylineno, func_name, params_count, arity);
			exit(EXIT_FAILURE);
		}
	}
	
	return index;
}

void success_print() {
	puts("PARSE SUCCESSFUL!");

	printf("\n");
	print_lit_table(lit_table);

	printf("\n\n");
	print_var_table(var_table);
	
	printf("\n\n");
	print_func_table(func_table);
}