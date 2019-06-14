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

int yylex(void);
void yyerror(char const *s);
extern int yylineno;
extern char* yytext;

/**
 * Adiciona uma variavel na tabela de variaveis com seu tamanho
 */
int addVar(char* varName, int size);
/**
 * Valida se uma variavel existe de acordo com seu nome e escopo
 */
int validVar(char* varName);
/**
 * Adiciona uma funcao na tabela de funcoes com sua aridade
 */
int addFunc(char* funcName);
/**
 * Valida se uma funcao existe de acordo com seu nome e numero de parametros
 */
int validFunc(char* funcName);

// Tabelas de literais, variaveis e funcoes
LitTable* litTable;
VarTable* varTable;
FuncTable* funcTable;

// Escopo atual na varredura do codigo C-Minus, qtd. de parametros de funcao e tamanho das variaveis
int currentScope = 0, params = 0, varSize = 0;

// Auxiliares que carregam os valores de yytext
char funcName[128] = { '\0' };
char varName[128] = { '\0' };
char varNameBkp[128] = { '\0' };

AST* ast;
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
	funcDeclList { ast = $1; };

funcDeclList:
	funcDeclList funcDecl	{ add_child($1, $2); $$ = $1; }
|	funcDecl				{ $$ = new_subtree(FLIST_NODE, 1, $1); };

funcDecl:
	funcHeader funcBody { $$ = new_subtree(FDECL_NODE, 2, $1, $2); };

funcHeader:
	retType ID { strcpy(funcName, varName); } LPAREN params RPAREN {
		int index = addFunc(funcName); params = 0;

		AST* funcNameNode = new_node(FNAME_NODE, index);
		$$ = new_subtree(FHEADER_NODE, 2, funcNameNode, $5);
	};

funcBody:
	LBRACE optVarDecl optStmtList RBRACE {
		currentScope++;

		$$ = new_subtree(FBODY_NODE, 2, $2, $3);
	};

optVarDecl:
	%empty		{ $$ = new_node(VAR_DECL_LIST_NODE, 0); }
|	varDeclList { $$ = $1; };

optStmtList:
	%empty		{ $$ = new_node(BLOCK_NODE, 0); }
|	stmtList 	{ $$ = $1;};

retType:
	INT
|	VOID;

params:
	VOID		{ $$ = new_node(PARAM_LIST_NODE, 0); }
|	paramList 	{ $$ = $1; };

paramList:
	paramList COMMA param 	{ add_child($1, $3); $$ = $1; }
|	param 					{ $$ = new_subtree(PARAM_LIST_NODE, 1, $1); };

param:
	INT ID {
		int index = addVar(varName, 0); params++;
		$$ = new_node(VAR_DECL_NODE, index);
	}

|	INT ID LBRACK RBRACK {
		int index = addVar(varName, -1); params++;
		$$ = new_node(VAR_DECL_NODE, index);
	};

varDeclList:
	varDeclList varDecl { add_child($1, $2); $$ = $1; }
|	varDecl 			{ $$ = new_subtree(VAR_DECL_LIST_NODE, 1, $1); };

varDecl:
	INT ID SEMI {
		int index = addVar(varName, 0);
		$$ = new_node(VAR_DECL_NODE, index);
	}

|	INT ID LBRACK NUM { varSize = atoi(yytext); } RBRACK SEMI {
		int index = addVar(varName, varSize);
		$$ = new_node(VAR_DECL_NODE, index);
	};

stmtList:
	stmtList stmt 	{ add_child($1, $2); $$ = $1; }
|	stmt 			{ $$ = new_subtree(BLOCK_NODE, 1, $1); };

stmt:
	assignStmt 		{ $$ = $1; }
|	ifStmt 			{ $$ = $1; }
|	whileStmt 		{ $$ = $1; }
|	returnStmt 		{ $$ = $1; }
|	funcCall SEMI 	{ $$ = $1; };

assignStmt:
	lval ASSIGN arithExpr SEMI { $$ = new_subtree(ASSIGN_NODE, 2, $1, $3); };

lval:
	lvalId {
		int index = validVar(varName);
		$$ = new_node(VAR_USE_NODE, index);
	}

|	lvalId LBRACK NUM RBRACK {
		int index = validVar(varName);
		$$ = new_node(VAR_USE_NODE, index);
	}

|	lvalId LBRACK ID RBRACK {
		int index = validVar(varNameBkp), index2 = validVar(varName);
		AST* array = new_node(VAR_USE_NODE, index);
		add_child(array, new_node(VAR_USE_NODE, index2));
		$$ = array;
	};

lvalId:
	ID { strcpy(varNameBkp, varName); };

ifStmt:
	IF LPAREN boolExpr RPAREN block 			{ $$ = new_subtree(IF_NODE, 2, $3, $5); }
|	IF LPAREN boolExpr RPAREN block ELSE block 	{ $$ = new_subtree(IF_NODE, 3, $3, $5, $7); };

block:
	LBRACE optStmtList RBRACE { $$ = $2; };

whileStmt:
	WHILE LPAREN boolExpr RPAREN block { $$ = new_subtree(WHILE_NODE, 2, $3, $5); };

returnStmt:
	RETURN SEMI 			{ $$ = new_subtree(RETURN_NODE, 0); }
|	RETURN arithExpr SEMI 	{ $$ = new_subtree(RETURN_NODE, 1, $2); };

funcCall:
	outputCall 		{ $$ = $1; }
|	writeCall 		{ $$ = $1; }
|	userFuncCall	{ $$ = $1; };

inputCall:
	INPUT LPAREN RPAREN { $$ = new_subtree(INPUT_NODE, 0); };

outputCall:
	OUTPUT LPAREN arithExpr RPAREN { $$ = new_subtree(OUTPUT_NODE, 1, $3); };

writeCall:
	WRITE LPAREN STRING RPAREN { $$ = new_subtree(WRITE_NODE, 1, $3); };

userFuncCall:
	ID { strcpy(funcName, varName); } LPAREN optArgList RPAREN {
		int index = validFunc(funcName); params = 0;
		AST* funcCallNode = new_node(FCALL_NODE, index);
		add_child(funcCallNode, $4);
		$$ = funcCallNode;
	};

optArgList:
	%empty	{ $$ = new_subtree(ARG_LIST_NODE, 0); }
|	argList { $$ = $1; };

argList:
	argList COMMA arithExpr { params++; add_child($1, $3); $$ = $1; }
|	arithExpr 				{ params++; $$ = new_subtree(ARG_LIST_NODE, 1, $1); };

boolExpr:
	arithExpr LT arithExpr 	{ $$ = new_subtree(LT_NODE, 2, $1, $3); }
|	arithExpr LE arithExpr 	{ $$ = new_subtree(LE_NODE, 2, $1, $3); }
|	arithExpr GT arithExpr 	{ $$ = new_subtree(GT_NODE, 2, $1, $3); }
|	arithExpr GE arithExpr 	{ $$ = new_subtree(GE_NODE, 2, $1, $3); }
|	arithExpr EQ arithExpr 	{ $$ = new_subtree(EQ_NODE, 2, $1, $3); }
|	arithExpr NEQ arithExpr { $$ = new_subtree(NEQ_NODE, 2, $1, $3); };

arithExpr:
	arithExpr PLUS arithExpr 	{ $$ = new_subtree(PLUS_NODE, 2, $1, $3); }
|	arithExpr MINUS arithExpr 	{ $$ = new_subtree(MINUS_NODE, 2, $1, $3); }
|	arithExpr TIMES arithExpr 	{ $$ = new_subtree(TIMES_NODE, 2, $1, $3); }
|	arithExpr OVER arithExpr 	{ $$ = new_subtree(OVER_NODE, 2, $1, $3); }
|	LPAREN arithExpr RPAREN 	{ $$ = $2; }
|	lval 						{ $$ = $1; }
|	inputCall 					{ $$ = $1; }
|	userFuncCall 				{ $$ = $1; }
|	NUM 						{ $$ = $1; };

%%

int main() {
	litTable = create_lit_table();
	varTable = create_var_table();
	funcTable = create_func_table();

	if (yyparse() == 0) {
        print_dot(ast);
		free_tree(ast);
    }

	//puts("PARSE SUCCESSFUL!");

	//printf("\n");
	//print_lit_table(litTable);
	free_lit_table(litTable);

	//printf("\n\n");
	//print_var_table(varTable);
	free_var_table(varTable);

	//printf("\n\n");
	//print_func_table(funcTable);
	free_func_table(funcTable);

	//print_tree(ast);

	return 0;
}

void yyerror (char const *s) {
	printf("PARSE ERROR (%d): %s\n", yylineno, s);
	exit(EXIT_FAILURE);
}

int addVar(char* varName, int size) {
	int index = lookup_var(varTable, varName, currentScope);

	if (index == -1) {
		return add_var(varTable, varName, yylineno, currentScope, size);
	} else {
		printf("SEMANTIC ERROR (%d): variable '%s' already declared at line %d.\n",
			yylineno, varName, get_var_line(varTable, index));
		exit(EXIT_FAILURE);
	}
}

int validVar(char* varName) {
	int index = lookup_var(varTable, varName, currentScope);

	if (index == -1) {
		printf("SEMANTIC ERROR (%d): variable '%s' was not declared.\n",
			yylineno, varName);
		exit(EXIT_FAILURE);
	}

	return index;
}

int addFunc(char* funcName) {
	int index = lookup_func(funcTable, funcName);
	
	if (index == -1) {
		return add_func(funcTable, funcName, yylineno, params);
	} else {
		printf("SEMANTIC ERROR (%d): function '%s' already declared at line %d.\n",
			yylineno, funcName, get_var_line(varTable, index));
		exit(EXIT_FAILURE);
	}
}

int validFunc(char* funcName) {
	int index = lookup_func(funcTable, funcName);

	if (index == -1) {
		printf("SEMANTIC ERROR (%d): function '%s' was not declared.\n",
			yylineno, funcName);
		exit(EXIT_FAILURE);
	} else {
		int arity = get_func_arity(funcTable, index);

		if (arity != params) {
			printf("SEMANTIC ERROR (%d): function '%s' was called with %d arguments"
			" but declared with %d parameters.\n", yylineno, funcName, params, arity);
			exit(EXIT_FAILURE);
		}
	}
	
	return index;
}
