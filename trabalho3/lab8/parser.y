
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
#include "tables.h"

int yylex(void);
void yyerror(char const *s);
int yylineno;
char* yytext;

LitTable* litTable;
SymTable* symTable;
%}

%token IF THEN END REPEAT UNTIL READ WRITE LPAREN SEMI NUMBER ID STRING PUTS INT
%precedence RPAREN
%precedence ELSE
%left EQ LT
%left PLUS MINUS
%left TIMES OVER
%right ASSIGN

%start program

%%
program:
	stmt_sequence;

stmt_sequence:
	stmt_sequence stmt
	| stmt;

stmt:
	if_stmt
	| repeat_stmt
	| assign_stmt
	| read_stmt
	| write_stmt
	| var_decl
	| puts_stmt;

if_stmt: 
	IF expr THEN stmt_sequence END
	| IF expr THEN stmt_sequence ELSE stmt_sequence END;

repeat_stmt:
	REPEAT stmt_sequence UNTIL expr;

assign_stmt:
	ID ASSIGN expr SEMI;

read_stmt:
	READ ID SEMI;

write_stmt:
	WRITE expr SEMI;

expr: 
	expr LT expr
	| expr EQ expr
	| expr PLUS expr
	| expr MINUS expr
	| expr TIMES expr
	| expr OVER expr
	| LPAREN expr RPAREN
	| NUMBER
	| ID;

var_decl:
	INT ID {
		int index = lookup_var(symTable, yytext);

		if (index == -1) {
        	yylval = add_var(symTable, yytext, yylineno);
	
		} else {
			printf("SEMANTIC ERROR (%d): variable '%s' already declared at line %d.\n",
				yylineno, yytext, get_line(symTable, index));
			exit(EXIT_FAILURE);
		}
	} SEMI;

puts_stmt:
	PUTS STRING SEMI { printf("PUTS: %s.\n", get_literal(litTable, $2)); };
%%

int main() {
	litTable = create_lit_table();
	symTable = create_sym_table();

	yyparse();

	printf("\n\n");
	print_lit_table(litTable);
	free_lit_table(litTable);

	printf("\n\n");
	print_sym_table(symTable);
	free_sym_table(symTable);

	printf("\n\n");

	return 0;
}

void yyerror(char const *s) {
	printf("PARSE ERROR (%d): %s\n", yylineno, s);
	exit(EXIT_FAILURE);
}
