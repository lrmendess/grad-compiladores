#include <stdio.h>
#include <stdlib.h>

void bolo(int a) {
	if (a == 1) {
		bolo(a + 1);
	} else {
		a = a + 1;
	}
	printf("%d\n", a);
}

void main(void) {
	bolo(1);
}
