%{
#include <stdio.h>
#include <string.h>
 
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
%token NUMBER CD LS PRINTENV BYE ALIAS
%%
commands: /* empty */
	| commands command;
	
command:
	print_enviro | change_dir | list_contents | exit_now;

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
		int cd = chdir("/home/josh");
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
%%

//execlp("ls", "ls", (char *) NULL,(char *) NULL );
