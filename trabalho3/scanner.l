%option yylineno
%option outfile="scanner.c"
%option noyywrap
%option nounput
%option noinput

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.h"
#include "tables.h"

extern LitTable* litTable;
extern VarTable* varTable;
extern FuncTable* funcTable;
extern int currentScope;
%}

space			[ \r\n\t]
number			[0-9]+
string			\"[^"]*\"
id				[a-zA-Z][a-zA-Z0-9]*
mlcomment		\/\*([^*]|\*+[^*/])*\*+\/
comment			\/\/.*

%%
{space}     	{}
{mlcomment}		{} /* Leitura de comentarios multiline */
{comment}		{} /* Leitura de comentarios singleline */

"else"      	{ 	return ELSE; 	}
"if"        	{ 	return IF; 		}
"input"     	{ 	return INPUT; 	}
"int"       	{ 	return INT; 	}
"output"    	{ 	return OUTPUT; 	}
"return"    	{ 	return RETURN; 	}
"void"      	{ 	return VOID; 	}
"while"     	{ 	return WHILE; 	}
"write"     	{ 	return WRITE; 	}

"+"         	{ 	return PLUS; 	}
"-"         	{ 	return MINUS; 	}
"*"         	{ 	return TIMES; 	}
"/"         	{ 	return OVER; 	}
"<"         	{ 	return LT; 		}
"<="        	{ 	return LE; 		}
">"         	{ 	return GT; 		}
">="        	{ 	return GE; 		}
"=="        	{ 	return EQ; 		}
"!="        	{ 	return NEQ; 	}
"="         	{ 	return ASSIGN; 	}

";"         	{ 	return SEMI; 	}
","         	{ 	return COMMA; 	}
"("         	{ 	return LPAREN; 	}
")"         	{ 	return RPAREN; 	}
"["         	{ 	return LBRACK; 	}
"]"         	{ 	return RBRACK; 	}
"{"				{ 	return LBRACE; 	}
"}"         	{ 	return RBRACE; 	}

{number} {
	yylval.integer = atoi(yytext);
	return NUM;
}

{id} {
	memset(yylval.string, 0, 128);
	strcpy(yylval.string, yytext);
	return ID;
}

{string} {
	add_literal(litTable, yytext);
	return STRING;
}

. {
	printf("SCANNING ERROR (%d): Unknown symbol %s\n", yylineno, yytext);
	exit(EXIT_FAILURE);
}
