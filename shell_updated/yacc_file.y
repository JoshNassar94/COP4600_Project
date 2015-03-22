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
%token CD LS BYE NUMBER PRINT_ENV FRONTSLASH PERIOD LESSTHAN GREATERTHAN PIPE DOUBLEQUOTE BACKSLASH AMPERSAND SET_ENV UNSET_ENV

%union
{
        int number;
        char* string;
}
%token <string> WORD
%%
command:
	| command '\n'
	| command plain_word {printf("No such command as \"%s\"\n",$<string>2);}
	| command change_dir_path
	| command change_dir
	| command list_dir
	| command list
	| command bye
	| command print_enviro
	| command set_enviro
	| command unset_enviro
	| metacharacters
	;
	
plain_word:
	WORD{
		$<string>$ = $<string>1;
	};
	
change_dir_path: 
	CD WORD {
		cd_pwd = getenv("PWD");
		navigate("");
		DIR *d;
		struct dirent *dir;
		d = opendir(cd_pwd);
		int found = 0;
		if(d){
			while ((dir = readdir(d))){
				if(strcmp($<string>2, dir->d_name) == 0){
					char* target = cd_pwd;
					strcat(target,"/");
					strcat(target, $<string>2);
					navigate(target);
					found = 1;
				}
			}
			if(found == 0)
				printf("No such directory!\n");
			closedir(d);
			navigate(cd_pwd);
			cd_pwd = getenv("PWD");
		}
	};
	| cd_frontslash_word
	| period
	| metacharacters
	;	
	
cd_frontslash_word:
	FRONTSLASH WORD{
		cd_pwd = getenv("PWD");
		navigate("");
		DIR *d;
		struct dirent *dir;
		d = opendir(cd_pwd);
		int found = 0;
		if(d){
			while ((dir = readdir(d))){
				if(strcmp($<string>2, dir->d_name) == 0){
					char* target = cd_pwd;
					strcat(target,"/");
					strcat(target, $<string>2);
					navigate(target);
					found = 1;
				}
			}
			if(found == 0)
				printf("No such directory!\n");
			closedir(d);
			navigate(cd_pwd);
			cd_pwd = getenv("PWD");
		}
	};
	
period:
	PERIOD{
		//Do nothing yet
	};
	
change_dir: 
	CD {
		cd_pwd = getenv("PWD");
		navigate("");
	};
	
list:
	LS{
		char* path = "";
		ls(path);
	};

list_dir:
	LS WORD{
		char* path = $<string>2;
		ls_path(path);
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
		printf("%s$ ",path);
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

metacharacters:
	lessthan
	| greaterthan
	| pipe
	| doublequote
	| backslash
	| ampersand
	;
	
lessthan:
	LESSTHAN{
		printf("Less than\n");
	};

greaterthan:
	GREATERTHAN{
		printf("Greater than\n");
	};
	
pipe:
	PIPE{
		printf("Pipe\n");
	};
	
doublequote:
	DOUBLEQUOTE{
		printf("Double quote\n");
	};
	
backslash:
	BACKSLASH{
		printf("Backslash\n");
	};
	
ampersand:
	AMPERSAND{
		printf("Ampersand\n");
	};
	
	
	
%%
#include <stdlib.h>
#include <unistd.h>
#include <dirent.h>

int main()
{
	yyparse();
	return 0;
} 

void ls(){
	int process;
	process = fork();
	if(process > 0)		/* parent */
		wait((int*)0);
	else if(process == 0)	/* child */
	{
		execl("/bin/ls", "ls", "--color=auto",(char *) NULL );
		exit(1);
	}
	else if(process == -1)		/* can't create a new process */
	{
		fprintf(stderr, "Can't fork!\n");
		exit(2);
	}
}

void ls_path(char* path){
	int process;
	process = fork();
	if(process > 0)		/* parent */
		wait((int*)0);
	else if(process == 0)	/* child */
	{
		execl("/bin/ls", "ls", "--color=auto", path, (char *) NULL );
		exit(1);
	}
	else if(process == -1)		/* can't create a new process */
	{
		fprintf(stderr, "Can't fork!\n");
		exit(2);
	}
}

void navigate(char* target){
	char empty[] = "";
	if(strcmp(target, empty) == 0){
		int cd = chdir(getenv("HOME"));
		setenv("PWD",getenv("HOME"),1);
	}
	else if(target[0] == '/'){
		int cd = chdir(target);
		char* iterator = target;
		int length = 0;
		int z = 0;
		while(iterator[z++] != '\0'){
			++length;
		}
		if(target[length-2] == '.'){
			char* curr_iterator = target;
			int length = 0;
			while(*(curr_iterator++) != '.'){
				++length;
			}
			int i;
			for(i = length-2; i > 0; --i){
				if(target[i] == '/'){
					int j;
					char dest[i];
					for(j = 0; j < i; ++j){
						dest[j] = target[j];
					}
					dest[i] = '\0';
					int x = 0;
					setenv("PWD",dest, 1);
					break;
				}
			}
		}
		else{
			setenv("PWD", target, 1);
		}
	}
	else{
		DIR *d;
		struct dirent *dir;
		d = opendir(".");
		if(d){
			while ((dir = readdir(d))){
				if(strcmp(target, dir->d_name) == 0){
					char* str = getenv("PWD");
					strcat(str, "/");
					strcat(str,target); 
					int i = 0;
					int cd = chdir(str);
					setenv("PWD",str,1);
				}
			}
			closedir(d);
		}
	}
}
