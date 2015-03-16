all: shell

shell: y.tab.o lex.yy.o
	cc lex.yy.o y.tab.o -o shell

lex.yy.o: lex.yy.c
	cc -c lex.yy.c

y.tab.o: y.tab.c
	cc -c y.tab.c

lex.yy.c: example1.l
	lex example1.l

y.tab.c: example1.y
	yacc -d example1.y
