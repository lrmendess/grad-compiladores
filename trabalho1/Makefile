all: flex gcc
	@echo "Done."

flex: scanner.l
	flex scanner.l

gcc: scanner.c
	gcc scanner.c -o trab1 -lfl

clean:
	@rm -rf *.c trab1
