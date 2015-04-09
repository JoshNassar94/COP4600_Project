%{
#include <stdio.h>
#include <string.h>
#include "dev/data_structures/data_structures.h"
#include "dev/user_created_commands.h"
#include <stdlib.h>

#define HOME getenv("HOME")
#define PWD getenv("PWD")
#define copystring(a,b) strcpy((a=(char *)malloc(strlen(b)+1)),b)

#define ONLY_ONE 0
#define FIRST 1
#define MIDDLE 2
#define LAST 3

#define READ_END 0
#define WRITE_END 1

#define STDIN_FILENO 0
#define STDOUT_FILENO 1
#define STDERR_FILENO 2

#define SYSCALLERR -1

extern FILE *yyin;
extern FILE *yyout;
char* cd_pwd;
linked_list* alias_list;

int error_code = 0;

//These are the in and out ifle for a command
char * in_file;
char * out_file;
int out_append;

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
	while(1){
		printf("%s$ ",PWD);
		yyparse();
	}
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

char* handle_escape_char(char *str, char *orig, char* second_half)
{
	static char buffer[4096];
	char *p;
	if(!(p = strstr(str, orig))) return str; //is orig actually in str
	
	strncpy(buffer, str, p-str); //copy char from str start to orig into buffer
	buffer[p-str] = str[p-str+1];
	static char buffer2[4096];
	
	sprintf(buffer2, "%s%s%c", buffer, second_half+2, '\0');
	
	return buffer2;
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
	char* pos;
	if(pos = strchr(s, '\\')){
		s = handle_escape_char(s, "\\", pos);
		printf("%s\n", s);
	}
	//printf("%s", replace("Hello, world!\n", "world", "Miami"));
	return s;
}


%}
%token CD BYE PRINT_ENV SET_ENV UNSET_ENV NEW_LINE ALIAS UNALIAS AMPERSAND GT GTGT LT PIPE TEST

%union
{
        int number;
        char* string;
        void* linkedlist;
}
%left CD ALIAS WORD
%token <string> WORD
%token <string> TEST
%type <linkedlist> arg_list
%type <linkedlist> cmd
%type <string> arg
%%
commands:
		| commands command
		{
			printf("%s$ ",getenv("PWD"));
		};

command:
	| NEW_LINE {/* do nothing */ }
	| change_dir NEW_LINE
	| bye NEW_LINE
	| print_enviro NEW_LINE
	| set_enviro NEW_LINE
	| unset_enviro NEW_LINE
	| full_cmd NEW_LINE
	| alias NEW_LINE
	| unalias NEW_LINE
	;

change_dir:
	CD
	{
		chdir(getenv("HOME"));
		setenv("PWD", getenv("HOME"), 1);
	}
	| CD AMPERSAND
	{
		int process = fork();
		if(process == 0){
			chdir(getenv("HOME"));
			setenv("PWD", getenv("HOME"), 1);
			exit(1);
		}
	}
	| CD WORD
	{
		$2 = insert_env($2);
		char* dest = remove_quotes($2);
		if(chdir(dest) == -1)
			printf("No such directory!\n");
		char pwd[4096];
		getcwd(pwd, sizeof(pwd));
		setenv("PWD", pwd, 1);
	}
	| CD WORD AMPERSAND
	{
		int process = fork();
		if(process == 0){
			$2 = insert_env($2);
			char* dest = remove_quotes($2);
			if(chdir(dest) == -1)
				printf("No such directory!\n");
			char pwd[4096];
			getcwd(pwd, sizeof(pwd));
			setenv("PWD", pwd, 1);
			exit(1);
		}
	};
	
bye:
	BYE
	{
		printf("Exiting the shell now...\n");
		exit(0);
	}
	| BYE
	{
		int process = fork();
		if(process == 0){
			printf("Exiting the shell now...\n");
			exit(1);
		}
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
	| PRINT_ENV AMPERSAND
	{
		int process = fork();
		if(process == 0){
			extern char **environ;
			int i=0;
			while(environ[i])
				printf("%s\n", environ[i++]);
			char* path = getenv("PATH");
		}
	};
	
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
	| ALIAS AMPERSAND
	{
		int process = fork();
		if(process == 0){
			print_alias_linked_list(alias_list);
			exit(1);
		}
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
full_cmd:
	cmd
	{
		if (error_code)
		{
			printf("error: unrecognized error\n");
			error_code = 0;
		}
		else
		{
			int status;
			pid_t pid;
			command_node * current_cmd = $1;
			while (current_cmd)
			{
			
				switch( pid = fork() )
				{
					case 0:			//in child
						switch( which_command(current_cmd) )
						{
							case ONLY_ONE:
								resolve_input(in_file);
								resolve_output(out_file, out_append);
								
								execute_externel_command(current_cmd, alias_list);
								exit(0);
							break;
							
							case FIRST:
								
								if (close(STDOUT_FILENO) == SYSCALLERR) { printf("ERROR"); }
								if (dup(current_cmd->next->fd[WRITE_END]) != 1)  { printf("ERROR"); }
								if (close(current_cmd->next->fd[READ_END]) == SYSCALLERR)  { printf("ERROR"); }
								resolve_input(in_file);			
								
								execute_externel_command(current_cmd, alias_list);
								exit(0);
							break;
							
							case LAST:
								
								if (close(STDIN_FILENO) == SYSCALLERR) { printf("ERROR 1\n"); }
								if (dup(current_cmd->fd[READ_END]) != 0)  { printf("ERROR 2\n"); }
								//if (close(current_cmd->fd[WRITE_END]) == SYSCALLERR)  { printf("ERROR 3\n"); }
								resolve_output(out_file, out_append);
								
					
								execute_externel_command(current_cmd, alias_list);
								exit(0);
							break;	
							
							default:
								perror("WTF?????????");
							break;
								
						}
					break;
					
					default:			//in parent
						if (current_cmd->next) 
						{
							close(current_cmd->next->fd[WRITE_END]);
						}
						free_linked_list(current_cmd->cmd);
						waitpid(pid, &status, 0);

					break;
				}
				current_cmd = current_cmd->next;
			}
		}
		in_file = NULL;
		out_file = NULL;
	}
	| cmd AMPERSAND
	{
		if (error_code)
		{
			printf("error: unrecognized error\n");
			error_code = 0;
		}
		else
		{
			int status;
			pid_t pid;
			command_node * current_cmd = $1;
			while (current_cmd)
			{
			
				switch( pid = fork() )
				{
					case 0:			//in child
						switch( which_command(current_cmd) )
						{
							case ONLY_ONE:
								resolve_input(in_file);
								resolve_output(out_file, out_append);
								
								execute_externel_command(current_cmd, alias_list);
								exit(0);
							break;
							
							case FIRST:
								
								if (close(STDOUT_FILENO) == SYSCALLERR) { printf("ERROR"); }
								if (dup(current_cmd->next->fd[WRITE_END]) != 1)  { printf("ERROR"); }
								if (close(current_cmd->next->fd[READ_END]) == SYSCALLERR)  { printf("ERROR"); }
								resolve_input(in_file);			
								
								execute_externel_command(current_cmd, alias_list);
								exit(0);
							break;
							
							case LAST:
								
								if (close(STDIN_FILENO) == SYSCALLERR) { printf("ERROR 1\n"); }
								if (dup(current_cmd->fd[READ_END]) != 0)  { printf("ERROR 2\n"); }
								//if (close(current_cmd->fd[WRITE_END]) == SYSCALLERR)  { printf("ERROR 3\n"); }
								resolve_output(out_file, out_append);
								
					
								execute_externel_command(current_cmd, alias_list);
								exit(0);
							break;	
							
							default:
								perror("WTF?????????");
							break;
								
						}
					break;
					
					default:			//in parent
						if (current_cmd->next) 
						{
							close(current_cmd->next->fd[WRITE_END]);
						}
						free_linked_list(current_cmd->cmd);

					break;
				}
				current_cmd = current_cmd->next;
			}
		}
		in_file = NULL;
		out_file = NULL;
	};
cmd:
		cmd PIPE cmd
		{
			command_node * begin = $1;
			command_node * end = $3;
			end->index = begin->index + 1;
			
			begin->next = end;
			
			pipe(end->fd);
			
			$$ = $1;
		}
		|
		cmd LT WORD
		{
			if (in_file) error_code = 1;
			command_node * cn = $1;
			in_file = $3;
		}
		|
		cmd GTGT WORD
		{
			if (out_file) error_code = 1;
			command_node * cn = $1;
			out_file = $3;
			out_append = 1;
		}
		|
		cmd GT WORD
		{
			if (out_file) error_code = 1;
			command_node * cn = $1;
			out_file = $3;
			out_append = 0;
		}
		|
		
		arg_list
		{
			$$ = $1;
		}
			
		;


arg_list:
		arg
		{
			command_node * cn = create_command_node();
			cn->index = 0;
			//linked_list* ll = create_linked_list();
			push_linked_list(cn->cmd,$1);
			$$=cn;
		}
		|
		arg_list arg
		{
			$2 = insert_env($2);		//change all instances of ${ENV} to the coresponding variable
			command_node * cn = $1;
			push_linked_list(cn->cmd,$2); 
			$$ = $1;
		}
	
arg: WORD{$$=$1;}
	
%%

