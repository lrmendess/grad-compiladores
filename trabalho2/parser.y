
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

int yylex(void);
void yyerror(char const *s);
int yylineno;
%}

%token ELSE IF INPUT INT OUTPUT RETURN VOID WHILE WRITE
%token SEMI
%precedence LPAREN RPAREN
%precedence LBRACE RBRACE
%precedence LBRACK RBRACK
%token NUM STRING ID UNKNOWN
%left PLUS MINUS
%left TIMES OVER
%left LT LE GT GE
%left EQ NEQ
%left COMMA
%right ASSIGN

%%
program:
	funcDeclList;

funcDeclList:
	funcDeclList funcDecl
|	funcDecl;

funcDecl:
	funcHeader funcBody;

funcHeader:
	retType ID LPAREN params RPAREN;

funcBody:
	LBRACE optVarDecl optStmtList RBRACE;

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
	INT ID
|	INT ID LBRACK RBRACK;

varDeclList:
	varDeclList varDecl
|	varDecl;

varDecl:
	INT ID SEMI
|	INT ID LBRACK NUM RBRACK SEMI;

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
	ID
|	ID LBRACK NUM RBRACK
|	ID LBRACK ID RBRACK;

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
	ID LPAREN optArgList RPAREN;

optArgList:
	%empty
|	argList;

argList:
	argList COMMA arithExpr
|	arithExpr;

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
	yydebug = 0; // Enter debug mode.
	yyparse();
	puts("PARSE SUCCESSFUL!");
	return 0;
}

void yyerror (char const *s) {
	printf("PARSE ERROR (%d): %s\n", yylineno, s);
	exit(EXIT_FAILURE);
}
