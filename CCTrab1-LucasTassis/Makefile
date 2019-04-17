all: trab1

trab1: lex.yy.c
	gcc lex.yy.c -o trab1 -lfl

lex.yy.c: scanner.l
	flex scanner.l

clean:
	rm -r *.c trab1
