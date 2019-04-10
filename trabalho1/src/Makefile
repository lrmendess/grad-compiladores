all:
	flex scanner.l
	gcc lex.yy.c -o scanner -lfl

clean:
	rm scanner lex.yy.c