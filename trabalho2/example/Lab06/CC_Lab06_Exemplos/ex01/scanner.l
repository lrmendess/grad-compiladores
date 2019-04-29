%option outfile="scanner.c"
%option noyywrap
%option nounput
%option noinput

%{
#include "parser.h"
%}

%%

[0-9]+  { return NUMBER; }
" "     ; // skip blanks
.|\n    { return yytext[0]; }
