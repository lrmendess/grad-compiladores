/*  Implementacao de um scanner para analise lexica da linguagem C-MINUS (Primeiro Trabalho de Compiladores)
 *  Aluno: Lucas Miguel Tassis
 */

%option yylineno

%{
#include<stdio.h>
%}

number          [0-9]+
id	            [a-zA-Z][a-zA-Z0-9]*
comment         "//"[^\n]*
string          \"([^\"]*)\"
spaces          [ \t\n]
%x              MLCOMMENT

%%

"/*"            { BEGIN(MLCOMMENT); } /* Comeca o estado para ler multiline comment */
<MLCOMMENT>"*/" { BEGIN(INITIAL); }   /* Volta para o estado inicial */
<MLCOMMENT>.|\n { }

{spaces}        { }
{comment}       { }

"else"          { printf("%d: else -> ELSE\n", yylineno); }
"if"            { printf("%d: if -> IF\n", yylineno); }
"input"         { printf("%d: input -> INPUT\n", yylineno); }
"int"           { printf("%d: int -> INT\n", yylineno); }
"output"        { printf("%d: output -> OUTPUT\n", yylineno); }
"return"        { printf("%d: return -> RETURN\n", yylineno); }
"void"          { printf("%d: void -> VOID\n", yylineno); }
"while"         { printf("%d: while -> WHILE\n", yylineno); }
"write"         { printf("%d: write -> WRITE\n", yylineno); }

"+"             { printf("%d: + -> PLUS\n", yylineno); }
"-"             { printf("%d: - -> MINUS\n", yylineno); }
"*"             { printf("%d: * -> TIMES\n", yylineno); }
"/"             { printf("%d: / -> OVER\n", yylineno); }
"<"             { printf("%d: < -> LT\n", yylineno); }
"<="            { printf("%d: <= -> LE\n", yylineno); }
">"             { printf("%d: > -> GT\n", yylineno); }
">="            { printf("%d: >= -> GE\n", yylineno); }
"=="            { printf("%d: == -> EQ\n", yylineno); }
"!="            { printf("%d: != -> NEQ\n", yylineno); }
"="             { printf("%d: = -> ASSIGN\n", yylineno); }

";"             { printf("%d: ; -> SEMI\n", yylineno); }
","			    { printf("%d: , -> COMMA\n", yylineno); }
"("			    { printf("%d: ( -> LPAREN\n", yylineno); }
")"			    { printf("%d: ) -> RPAREN\n", yylineno); }
"["			    { printf("%d: [ -> LBRACK\n", yylineno); }
"]"			    { printf("%d: ] -> RBRACK\n", yylineno); }
"{"			    { printf("%d: { -> LBRACE\n", yylineno); }
"}"			    { printf("%d: } -> RBRACE\n", yylineno); }

{number}	    { printf("%d: %s -> NUM\n", yylineno, yytext); }
{id}		    { printf("%d: %s -> ID\n", yylineno, yytext); }
{string}    	{ printf("%d: %s -> STRING\n", yylineno, yytext); }
.			    { printf("%d: %s -> UNKNOWN\n", yylineno, yytext); }

%%

int main(){
    yylex();
    return 0;
}
