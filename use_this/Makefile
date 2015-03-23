all: shell

shell: y.tab.o lex.yy.o
	cc lex.yy.o y.tab.o -o shell

lex.yy.o: lex.yy.c
	cc -c lex.yy.c

y.tab.o: y.tab.c
	cc -c y.tab.c

lex.yy.c: lex_file.l
	lex lex_file.l

y.tab.c: yacc_file.y
	yacc -d yacc_file.y
