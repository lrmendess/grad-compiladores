
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

int yylex(void);
void yyerror(char const *s);
%}

%token NUMBER
%left '+' '-'
%left '*' '/'

%%

line: expr '\n' ;

expr:
  NUMBER
| expr '+' expr
| expr '-' expr
| expr '*' expr
| expr '/' expr
;

%%

int main() {
  yydebug = 1; // Enter debug mode.
  yyparse();
  return 0;
}
