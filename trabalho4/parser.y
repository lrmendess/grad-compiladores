/**
 * Lucas Ribeiro Mendes Silva - 2016101236
 */

/* Options to bison */
// File name of generated parser.
%output "parser.c"
// Produces a 'parser.h'
%defines "parser.h"
// Give proper error messages when a syntax error is found.
%define parse.error verbose
// Enable LAC (lookahead correction) to improve syntax error handling.
%define parse.lac full

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tables.h"

int yylex(void);
void yyerror(char const *s);
int yylineno;
char* yytext;

/**
 * Adiciona uma variavel na tabela de variaveis com seu tamanho
 */
void addVar(char* varName, int size);
/**
 * Valida se uma variavel existe de acordo com seu nome e escopo
 */
void validVar(char* varName);
/**
 * Adiciona uma funcao na tabela de funcoes com sua aridade
 */
void addFunc(char* funcName);
/**
 * Valida se uma funcao existe de acordo com seu nome e numero de parametros
 */
void validFunc(char* funcName);

// Escopo atual na varredura do codigo C-Minus
int currentScope = 0;
// Numero de parametros de uma definicao ou chamada de funcao
int params = 0;
// Tabelas de literais, variaveis e funcoes
LitTable* litTable;
VarTable* varTable;
FuncTable* funcTable;
%}

%token ELSE IF INPUT INT OUTPUT RETURN VOID WHILE WRITE SEMI COMMA
%token LBRACK RBRACK LBRACE RBRACE
%precedence LPAREN RPAREN
%token NUM ID STRING
%left LT LE GT GE EQ NEQ
%left PLUS MINUS
%left TIMES OVER
%right ASSIGN

// Possiveis tipos para o yylval
%union
{
    int integer;
    char string[128];
}

%type<integer> NUM
%type<string> ID

%start program

%%
program:
	funcDeclList;

funcDeclList:
	funcDeclList funcDecl
|	funcDecl;

funcDecl:
	funcHeader funcBody;

funcHeader:
	retType ID LPAREN params RPAREN { addFunc($2); params = 0; };

funcBody:
	LBRACE optVarDecl optStmtList RBRACE { currentScope++; };

optVarDecl:
	%empty
|	varDeclList;

optStmtList:
	%empty
|	stmtList;

retType:
	INT
|	VOID;

params:
	VOID
|	paramList;

paramList:
	paramList COMMA param
|	param;

param:
	INT ID { addVar($2, 0); params++; }
|	INT ID LBRACK RBRACK { addVar($2, -1); params++; };

varDeclList:
	varDeclList varDecl
|	varDecl;

varDecl:
	INT ID SEMI { addVar($2, 0); }
|	INT ID LBRACK NUM RBRACK SEMI { addVar($2, $4); };

stmtList:
	stmtList stmt
|	stmt;

stmt:
	assignStmt
|	ifStmt
|	whileStmt
|	returnStmt
|	funcCall SEMI;

assignStmt:
	lval ASSIGN arithExpr SEMI;

lval:
	ID { validVar($1); }
|	ID LBRACK NUM RBRACK { validVar($1); }
|	ID LBRACK ID RBRACK { validVar($1); validVar($3); };

ifStmt:
	IF LPAREN boolExpr RPAREN block
|	IF LPAREN boolExpr RPAREN block ELSE block;

block:
	LBRACE optStmtList RBRACE;

whileStmt:
	WHILE LPAREN boolExpr RPAREN block;

returnStmt:
	RETURN SEMI
|	RETURN arithExpr SEMI;

funcCall:
	outputCall
|	writeCall
|	userFuncCall;

inputCall:
	INPUT LPAREN RPAREN;

outputCall:
	OUTPUT LPAREN arithExpr RPAREN;

writeCall:
	WRITE LPAREN STRING RPAREN;

userFuncCall:
	ID LPAREN optArgList RPAREN { validFunc($1); params = 0; };

optArgList:
	%empty
|	argList;

argList:
	argList COMMA arithExpr { params++; }
|	arithExpr { params++; };

boolExpr:
	arithExpr LT arithExpr
|	arithExpr LE arithExpr
|	arithExpr GT arithExpr
|	arithExpr GE arithExpr
|	arithExpr EQ arithExpr
|	arithExpr NEQ arithExpr;

arithExpr:
	arithExpr PLUS arithExpr
|	arithExpr MINUS arithExpr
|	arithExpr TIMES arithExpr
|	arithExpr OVER arithExpr
|	LPAREN arithExpr RPAREN
|	lval
|	inputCall
|	userFuncCall
|	NUM;

%%

int main() {
	litTable = create_lit_table();
	varTable = create_var_table();
	funcTable = create_func_table();

	yyparse();
	puts("PARSE SUCCESSFUL!");

	printf("\n");
	print_lit_table(litTable);
	free_lit_table(litTable);

	printf("\n\n");
	print_var_table(varTable);
	free_var_table(varTable);

	printf("\n\n");
	print_func_table(funcTable);
	free_func_table(funcTable);

	return 0;
}

void yyerror (char const *s) {
	printf("PARSE ERROR (%d): %s\n", yylineno, s);
	exit(EXIT_FAILURE);
}

void addVar(char* varName, int size) {
	int index = lookup_var(varTable, varName, currentScope);

	if (index == -1) {
		add_var(varTable, varName, yylineno, currentScope, size);
	} else {
		printf("SEMANTIC ERROR (%d): variable '%s' already declared at line %d.\n",
			yylineno, varName, get_var_line(varTable, index));
		exit(EXIT_FAILURE);
	}
}

void validVar(char* varName) {
	int index = lookup_var(varTable, varName, currentScope);

	if (index == -1) {
		printf("SEMANTIC ERROR (%d): variable '%s' was not declared.\n",
			yylineno, varName);
		exit(EXIT_FAILURE);
	}
}

void addFunc(char* funcName) {
	int index = lookup_func(funcTable, funcName);
	
	if (index == -1) {
		add_func(funcTable, funcName, yylineno, params);
	} else {
		printf("SEMANTIC ERROR (%d): function '%s' already declared at line %d.\n",
			yylineno, funcName, get_var_line(varTable, index));
		exit(EXIT_FAILURE);
	}
}

void validFunc(char* funcName) {
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
}
