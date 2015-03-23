%{
#include <stdio.h>
#include <string.h>

extern FILE *yyin;
extern FILE *yyout;
char* cd_pwd;

void yyerror(const char *str)
{
        fprintf(stderr,"error: %s\n",str);
}
 
int yywrap()
{
        return 1;
} 
  
%}
%token CD BYE NUMBER PRINT_ENV SET_ENV UNSET_ENV NEW_LINE

%union
{
        int number;
        char* string;
}
%left CD WORD
%token <string> WORD
%%
commands:
		| commands command{printf("%s","$ ");};

command:
	|  '\n'
	|  plain_word NEW_LINE{printf("No such command as \"%s\"\n",$<string>1);}
	|  change_dir NEW_LINE
	|  bye NEW_LINE
	|  print_enviro NEW_LINE
	|  set_enviro NEW_LINE
	|  unset_enviro NEW_LINE
	;
	
plain_word:
	WORD{
		$<string>$ = $<string>1;
	};
	
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
	
	
	
%%
#include <stdlib.h>
#include <unistd.h>
#include <dirent.h>

int main()
{
	printf("-------Welcome to the Shell-------\n");
	printf("%s","$ ");
	yyparse();
	return 0;
} 
