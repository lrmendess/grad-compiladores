
%option outfile="scanner.c"
%option noyywrap
%option nounput
%option noinput
%option yylineno

%{
#include <stdio.h>
#include "parser.h"
%}

number      [0-9]+
identifier  [a-zA-Z]+
ignore      [ \t\n]

%%

"{"[^}]*"}"     { }
"if"            { return IF; }
"then"          { return THEN; }
"else"          { return ELSE; }
"end"           { return END; }
"repeat"        { return REPEAT; }
"until"         { return UNTIL; }
"read"          { return READ; }
"write"         { return WRITE; }
"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return TIMES; }
"/"             { return OVER; }
"="             { return EQ; }
"<"             { return LT; }
"("             { return LPAREN; }
")"             { return RPAREN; }
";"             { return SEMI; }
":="            { return ASSIGN; }
{number}        { return NUM; }
{identifier}    { return ID; }
{ignore}        { }
                /* Be sure to keep this as the last rule */
.               { printf("SCANNING ERROR (%d): Unknown symbol %s\n", yylineno, yytext);
                  exit(1); }
%%
