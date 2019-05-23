%option outfile="scanner.c"
%option yylineno
%option noyywrap
%option nounput
%option noinput

%{
#include "parser.h"
#include "tables.h"
#include "string.h"

extern LitTable* litTable;
extern SymTable* symTable;
%}

number              [0-9]+
comment             "{"[^}]*"}"	
space               [ \r\n\t]
id                  [a-zA-Z]+
string              \"[^"]*\"
%%

{comment}			{}
{space}             {}

"if"               	{ return IF; }
"then"             	{ return THEN; }
"else" 				{ return ELSE; }
"end" 				{ return END; }
"repeat" 			{ return REPEAT; }
"until" 			{ return UNTIL; }
"read" 				{ return READ; }
"write" 			{ return WRITE; }
"puts"              { return PUTS; }

"int"               { return INT; }

"+"                	{ return PLUS; }
"-"                	{ return MINUS; }
"*"                	{ return TIMES; }
"/"                	{ return OVER; }
"="                	{ return EQ; }
"<"                	{ return LT; }
"("                	{ return LPAREN; }
")"                	{ return RPAREN; }
";"                	{ return SEMI; }
":="               	{ return ASSIGN; }

{number}  			{ return NUMBER; }

{id}                { return ID; }

{string} {
    yylval = add_literal(litTable, yytext); return STRING;
}

. {
    printf("SCANNING ERROR (%d): Unknown symbol %s\n", yylineno, yytext); exit(EXIT_FAILURE);
}
