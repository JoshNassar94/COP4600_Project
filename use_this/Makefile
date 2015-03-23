
LEX = lex
YACC = yacc
CC = gcc
shell: y.tab.o lex.yy.o data_structures.o user_created_commands.o
	$(CC) -o shell y.tab.o lex.yy.o data_structures.o user_created_commands.o
y.tab.c y.tab.h: yacc_file.y
	$(YACC) -d yacc_file.y 
y.tab.o: y.tab.c 
	$(CC) -c y.tab.c 
lex.yy.o: y.tab.h lex.yy.c
	$(CC) -c lex.yy.c 
lex.yy.c: lex_file.l
	$(LEX) lex_file.l 
data_structures.o: dev/data_structures/data_structures.c dev/data_structures/data_structures.h
	$(CC) -c dev/data_structures/data_structures.c
user_created_commands.o: dev/user_created_commands.c dev/user_created_commands.h
	$(CC) -c dev/user_created_commands.c

clean:
	rm *.o
	rm *.c
	rm *.h
	rm shell
