%{
#include <stdio.h>
#include <string.h>
#include <dirent.h>
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
  
int main()
{
	yyparse();
} 
%}
%token NUMBER CD LS PRINTENV BYE ALIAS SAY PREV_DIR

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
	print_enviro | change_dir | list_contents | exit_now | say_word | change_dir_path;

print_enviro:
	PRINTENV
	{
		extern char **environ;
		int i=0;
		while(environ[i])
			printf("%s\n", environ[i++]);
		char* path = getenv("PWD");
		printf("%s$ ",path);
	}

change_dir:
	CD
	{
		int cd = chdir(getenv("HOME"));
		setenv("PWD",getenv("HOME"),1);
		char* path = getenv("PWD");
		printf("%s$ ",path);
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
		char* path = getenv("PWD");
		printf("%s$ ",path);
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
		char* path = getenv("PWD");
		printf("%s$ ",path);
	}
	
change_dir_path:
	CD WORD
	{
		char back_one[] = "..";
		if(strcmp($2, back_one) == 0){
			char* curr = getenv("PWD");
			char* curr_iterator = curr;
			int length = 0;
			while(*(curr_iterator++) != '\0'){
				++length;
			}
			++length;
			int i;
			for(i = length-1; i > 0; --i){
				if(curr[i] == '/'){
					int j;
					char dest[i];
					for(j = 0; j < i; ++j){
						dest[j] = curr[j];
					}
					dest[i] = '\0';
					int k = 0;
					int cd = chdir(dest);
					setenv("PWD",dest,1);
					break;
				}
			}
		}
		else{
			DIR *d;
			struct dirent *dir;
			d = opendir(".");
			if(d){
				while ((dir = readdir(d))){
					if(strcmp($2, dir->d_name) == 0){
						char* str = getenv("PWD");
						strcat(str, "/");
						strcat(str,$2); 
						int i = 0;
						int cd = chdir(str);
						setenv("PWD",str,1);
					}
				}
				closedir(d);
			}
		}
		char* path = getenv("PWD");
		printf("%s$ ",path);
	}
%%

//execlp("ls", "ls", (char *) NULL,(char *) NULL );
