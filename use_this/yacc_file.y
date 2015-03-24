%{
#include <stdio.h>
#include <string.h>
#include "dev/data_structures/data_structures.h"
#include "dev/user_created_commands.h"
#include <stdlib.h>

extern FILE *yyin;
extern FILE *yyout;
char* cd_pwd;
linked_list* alias_list;
void yyerror(const char *str)
{
        fprintf(stderr,"error: %s\n",str);
}
 
int yywrap()
{
        return 1;
} 
  
int main()
{
	alias_list = create_linked_list();
	printf("-------Welcome to the Shell-------\n");
	printf("%s","$ ");
	yyparse();
	return 0;
} 

%}
%token CD BYE PRINT_ENV SET_ENV UNSET_ENV NEW_LINE ALIAS UNALIAS

%union
{
        int number;
        char* string;
        void* linkedlist;
}
%left CD ALIAS WORD
%token <string> WORD
%type <linkedlist> arg_list
%type <string> arg
%%
commands:
		| commands command{printf("%s","$ ");};

command:
	| '\n'
	| change_dir NEW_LINE
	| bye NEW_LINE
	| print_enviro NEW_LINE
	| set_enviro NEW_LINE
	| unset_enviro NEW_LINE
	| cmd NEW_LINE
	| alias NEW_LINE
	| unalias NEW_LINE
	;

change_dir:
	CD{chdir(getenv("HOME"));}
	| CD WORD{chdir($2);};
	
bye:
	BYE
	{
		printf("Exiting the shell now...\n");
		exit(0);
	};
	
print_enviro:
	PRINT_ENV
	{
		extern char **environ;
		int i=0;
		while(environ[i])
			printf("%s\n", environ[i++]);
		char* path = getenv("PATH");
	}
	
set_enviro:
	SET_ENV WORD WORD
	{
		char* envname = $<string>2;
		char* envval = $<string>3;
		int result = setenv(envname, envval, 1);
		if(result == -1)
			printf("Failed to set variable %s to %s.\n", envname, envval);
	};
	
unset_enviro:
	UNSET_ENV WORD
	{
		char* name = $<string>2;
		if(getenv(name))
			unsetenv(name);
		else
			printf("No variable named %s.\n", name);
	};
	
alias:
	ALIAS
	{
		print_alias_linked_list(alias_list);
	}
	| ALIAS WORD WORD
	{
		push_alias_linked_list(alias_list, $2, $3);
	};
	
unalias:
	UNALIAS WORD
	{
		remove_alias_linked_list(alias_list, $2);
	};
	
/********************************************************************************************
 *
 *The following section, cmd, arg_list, and arg describe the functionality of "other commands"
 *(commands defined outside of the shell) ex: /bin/ls -l
 *
 ********************************************************************************************/

cmd:
		arg_list
		{
			int status;
			pid_t pid = fork();

			if(pid == 0){
				//This function is defined in user_created_commands.c
				execute_externel_command($1, alias_list);
			}else{
				free_linked_list($1);
				waitpid(pid, &status, 0);
			}
		}	
		;
arg_list:
		arg{linked_list* ll = create_linked_list();
			push_linked_list(ll,$1);
			$$=ll;}
		|
		arg_list arg{push_linked_list($1,$2); $$ = $1;}
	
arg: WORD{$$=$1;}
	
%%
