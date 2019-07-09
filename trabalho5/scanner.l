%option yylineno
%option outfile="scanner.c"
%option noyywrap
%option nounput
%option noinput

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "parser.h"
#include "tables.h"

extern LitTable* lit_table;
extern VarTable* var_table;
extern FuncTable* func_table;

extern char var_name[128];
%}

space		[ \r\n\t]
number		[0-9]+
string		\"[^"]*\"
id			[a-zA-Z][a-zA-Z0-9]*
mlcomment	\/\*([^*]|\*+[^*/])*\*+\/
comment		\/\/.*

%%
{space}     {}
{mlcomment}	{} /* Leitura de comentarios multiline */
{comment}	{} /* Leitura de comentarios singleline */

"else"      { return ELSE; }
"if"        { return IF; }
"input"     { return INPUT; }
"int"       { return INT; }
"output"    { return OUTPUT; }
"return"    { return RETURN; }
"void"      { return VOID; }
"while"     { return WHILE; }
"write"     { return WRITE; }

"+"         { return PLUS; }
"-"         { return MINUS; }
"*"         { return TIMES; }
"/"         { return OVER; }
"<"         { return LT; }
"<="        { return LE; }
">"         { return GT; }
">="        { return GE; }
"=="        { return EQ; }
"!="        { return NEQ; }
"="         { return ASSIGN; }

";"         { return SEMI; }
","         { return COMMA; }
"("         { return LPAREN; }
")"         { return RPAREN; }
"["         { return LBRACK; }
"]"         { return RBRACK; }
"{"			{ return LBRACE; }
"}"         { return RBRACE; }

{number} {
	yylval = new_node(NUM_NODE, atoi(yytext));
	return NUM;
}

{id} {
	/* Eh feito uma copia do yytext para o yylval para evitar vazamento de memoria */
	memset(var_name, 0, 128);
	strcpy(var_name, yytext);
	return ID;
}

{string} {
	/* Adicao de um literal na tabela de literais */
	int index = add_literal(lit_table, yytext);
	yylval = new_node(STRING_NODE, index);
	return STRING;
}

. {
	printf("SCANNING ERROR (%d): Unknown symbol %s\n", yylineno, yytext);
	exit(EXIT_FAILURE);
}
