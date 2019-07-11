all: bison flex gcc
	@echo "Done."

bison: parser.y
	bison -v parser.y

flex: scanner.l
	flex scanner.l

gcc: scanner.c parser.c tables.c ast.c interpreter.c
	gcc -Wall -o trab5 scanner.c parser.c tables.c ast.c interpreter.c -ly -g

clean:
	@rm -f *.o *.output scanner.c parser.h parser.c trab5
