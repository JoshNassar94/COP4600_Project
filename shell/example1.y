%{
#include <stdio.h>
#include <string.h>
extern FILE *yyin;
extern FILE *yyout;

void yyerror(const char *str)
{
	fprintf(stderr,"error: %s\n",str);
}
 
int yywrap()
{
	return 1;
} 
  
main()
{
	yyparse();
} 
%}
%token NUMBER CD LS PRINTENV BYE ALIAS SAY

%union	//not sure how this works really. But it wont complite
{
        int number;
        char* string;
}

%token <string> WORD
%%
commands: /* empty */
	| commands command;
	
command:
	print_enviro | change_dir | list_contents | exit_now | say_word;

print_enviro:
	PRINTENV
	{
		extern char **environ;
		int i=0;
		while(environ[i])
			printf("%s\n", environ[i++]);
	}

change_dir:
	CD
	{
		int cd = chdir(getenv("HOME"));
	};
	
list_contents:
	LS
	{
		int process;
		process = fork();
		if(process > 0)		/* parent */
			wait((int*)0);
		else if(process == 0)	/* child */
		{
			execlp("ls", "ls", "--color=auto",(char *) NULL );
			exit(1);
		}
		else if(process == -1)		/* can't create a new process */
		{
			fprintf(stderr, "Can't fork!\n");
			exit(2);
		}
	};
	
exit_now:
	BYE
	{
		printf("Exiting the shell now...\n");
		exit(0);
	};
	
say_word:		//an example to use words
	SAY WORD
	{
		printf("%s\n", $2);
	}
%%

//execlp("ls", "ls", (char *) NULL,(char *) NULL );
