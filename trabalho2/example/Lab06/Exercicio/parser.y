
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
#include <math.h>

int yylex(void);
void yyerror(char const *s);
int yylineno;
%}

%token IF THEN END REPEAT UNTIL READ WRITE SEMI NUM ID
%precedence LPAREN RPAREN
%precedence ELSE
%left EQ LT
%left PLUS MINUS
%left TIMES OVER
%right ASSIGN

%%
program: stmt-sequence  { printf("PARSE SUCCESSFUL!\n"); };

stmt-sequence: stmt-sequence stmt
  | stmt ;

stmt: if-stmt
  | repeat-stmt
  | assign-stmt
  | read-stmt
  | write-stmt ;

if-stmt: IF expr THEN stmt-sequence END
  | IF expr THEN stmt-sequence ELSE stmt-sequence END ;

repeat-stmt: REPEAT stmt-sequence UNTIL expr ;

assign-stmt: ID ASSIGN expr SEMI ;

read-stmt: READ ID SEMI ;

write-stmt: WRITE expr SEMI ;

expr: expr LT expr
  | expr EQ expr
  | expr PLUS expr | expr MINUS expr
  | expr TIMES expr | expr OVER expr
  | LPAREN expr RPAREN
  | NUM
  | ID ;
%%

int main(){
  yyparse();
  return 0;
}

void yyerror (char const *s) {
  printf("PARSE ERROR (%d): %s\n", yylineno, s);
}
