import os

os.system('make')

print('--------- COMECANDO TESTES NORMAIS ---------')
for i in range(1, 14):
	if i < 10:
		print('Teste c0{}.cm'.format(i))
		os.system('./trab1 < in/c0{}.cm | diff out/c0{}.out -'.format(i, i))
	else:
		print('Teste c{}.cm'.format(i))
		os.system('./trab1 < in/c{}.cm | diff out/c{}.out -'.format(i, i))


print('--------- COMECANDO TESTES DE ERROS ---------')
for i in range(1, 4):
	print('Teste err1_c0{}'.format(i))
	os.system('./trab1 < in/err1_0{}.cm | diff out/err1_0{}.out -'.format(i, i))

for i in range(1, 4):
	print('Teste err2_c0{}'.format(i))
	os.system('./trab1 < in/err2_0{}.cm | diff out/err2_0{}.out -'.format(i, i))

for i in range(1, 16):
	if i < 10:
		print('Teste err3_0{}.cm'.format(i))
		os.system('./trab1 < in/err3_0{}.cm | diff out/err3_0{}.out -'.format(i, i))
	else:
		print('Teste err3_{}.cm'.format(i))
		os.system('./trab1 < in/err3_{}.cm | diff out/err3_{}.out -'.format(i, i))

os.system('make clean')

