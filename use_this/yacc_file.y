%{
#include <stdio.h>
#include <string.h>
#include "dev/data_structures/data_structures.h"
#include "dev/user_created_commands.h"
#include <stdlib.h>

#define HOME getenv("HOME")
#define PWD getenv("PWD")
#define copystring(a,b) strcpy((a=(char *)malloc(strlen(b)+1)),b)

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
	printf("**********************************\n");
	printf("*--------------------------------*\n");
	printf("*------Welcome to the Shell------*\n");
	printf("*--------------------------------*\n");
	printf("**********************************\n");
	printf("%s$ ",PWD);
	yyparse();
	return 0;
} 

char *replace(char *str, char *orig, char * rep)
{
	static char buffer[4096];
	char *p;
	if(!(p = strstr(str, orig))) return str; //is orig actually in str
	
	strncpy(buffer, str, p-str); //copy char from str start to orig into buffer
	buffer[p-str] = '\0';
	
	sprintf(buffer+(p-str), "%s%s", rep, p+strlen(orig));
	
	return buffer;
}

char * insert_env(char* input)
{
	char * s = input;
	int i;
	int valid_so_far = 0;
	int start;
	int end;
	for (i = 0; i < strlen(s); i++)
	{
		if(s[i] == '$') start = i;
		if(s[i] == '{' && i == start+1) valid_so_far = 1;
		if(s[i] == '}' && valid_so_far)
		{
			char subbuf[4096];
			memcpy(subbuf, &s[start], i-start+1);
			subbuf[i-start+1] = '\0';
			
			char * var;
			copystring(var, subbuf);
			var = var + 2; 				//get rid of ${
			var[i-start-2] = '\0';  		//get rid of ending }
			
			s = replace(s, subbuf, getenv(var));
		}
	
	}
	//printf("%s", replace("Hello, world!\n", "world", "Miami"));

	return s;
}


%}
%token CD BYE PRINT_ENV SET_ENV UNSET_ENV NEW_LINE ALIAS UNALIAS BAD

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
		| commands command
		{
			
			printf("%s$ ",getenv("PWD"));
		};

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
	| bad NEW_LINE
	;

change_dir:
	CD
	{
		chdir(getenv("HOME"));
		setenv("PWD", getenv("HOME"), 1);
	}
	| CD WORD
	{
		$2 = insert_env($2);
		chdir($2);
		char pwd[4096];
		getcwd(pwd, sizeof(pwd));
		setenv("PWD", pwd, 1);
	};
	
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
		char* envname = insert_env($<string>2);
		char* envval = insert_env($<string>3);
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
		check_alias_list(alias_list, $2, $3);
	};
	
unalias:
	UNALIAS WORD
	{
		remove_alias_linked_list(alias_list, $2);
	};
	
bad:
	BAD
	{
		printf("Incorrect syntax\n");
	};

cmd:
		arg_list
		{
			int status;
			pid_t pid = fork();

			if(pid == 0){
				execute_externel_command($1, alias_list);
			}else{
				free_linked_list($1);
				waitpid(pid, &status, 0);
			}
		}	
		;
arg_list:
		arg
		{
			
			linked_list* ll = create_linked_list();
			push_linked_list(ll,$1);
			$$=ll;
		}
		|
		arg_list arg
		{
			$2 = insert_env($2);
			push_linked_list($1,$2); $$ = $1;
		}
	
arg: WORD{$$=$1;}
	
%%
