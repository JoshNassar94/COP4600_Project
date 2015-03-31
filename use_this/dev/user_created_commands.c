#include <stdio.h>
#include <stdlib.h>
#include <dirent.h> 
#include <string.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>

#include "user_created_commands.h"
#include "data_structures/data_structures.h"

#define copystring(a,b) strcpy((a=(char *)malloc(strlen(b)+1)),b)

void resolve_output(command_node * cn)
{
	if (cn->out_file)
	{	
		int fd;
		fd = open(cn->out_file, O_WRONLY | O_CREAT, S_IREAD | S_IWRITE);
		if (fd == -1)
		{
			perror("error: in user_created_commands.c");
			exit (1);
		}
		close(1);
		dup(fd);
		close(fd);
	}
	else
	{
		perror("WE ARE HERE");
		int fd;
		fd = open("/dev/tty", O_WRONLY);
		close(1);
		dup(fd);
	}
}

void execute_externel_command(command_node * commandNode, linked_list * alias_list){
	char * command;
	char ** arguments;
	char ** envp = {NULL};
	//char * envp = getenv("PATH");
	
	resolve_output(commandNode);
	
	linked_list * linkedlist = commandNode->cmd;

	//count the number of elements in the linked list so we know how much memory to allocate for the array;
	int list_element_count=1;
	node * current_node;
	for(current_node = linkedlist->start; current_node->next != NULL; current_node=current_node->next){
		list_element_count++;
	}
	
	//allocate the memory + 1 because argument list need to end with NULL pointer
	arguments = malloc(sizeof(char *) * list_element_count + 1);
	
	int i=0;
	current_node = linkedlist->start;
	for(i=0; i<list_element_count; i++){
		arguments[i] = current_node->data;
		current_node = current_node->next;
	}
	command = arguments[0];
	if(is_alias(command, alias_list)){
		execute_alias_command(command, alias_list);
		return;
	}
	
	char path[501];
	
	if(command[0] != '/'){
		if(find_path(path, command) == 0){
			return;
		}
		else{
			if(execve(path, arguments, envp)<0){
				puts("execve has failed");
			}
			return;
		}
	}
	else{
		if(execve(command, arguments, envp)<0){
			puts("execve has failed");
		}
	}
}

int checkifexecutable(const char* pth, const char* filename){
	DIR *d;
	struct dirent *dir;
	d = opendir(pth);
	if(d){
		while ((dir = readdir(d))){
			if(strcmp(dir->d_name,filename) == 0){
				return 1;
			}
		}
	}
	return 0;
}

int find_path(char *pth, char *exe){
	char* searchpath = getenv("PATH");
	if(searchpath == NULL)
		return 0;
	if(strlen(searchpath) <= 0)
		return 0;
	
	char* end;
	char* beg = searchpath;
	int stop = 0;
	int found = 0;
	int len;
	do {
		end = strchr(beg, ':');
		if (end == NULL) {
		   stop = 1;
		   strncpy(pth, beg, 500);
		   len = strlen(pth);
		} else {
		   strncpy(pth, beg, end - beg);
		   pth[end - beg] = '\0';
		   len = end - beg;
		}
		found = checkifexecutable(pth, exe);
		if (pth[len - 1] != '/') strncat(pth, "/", 1);
		strncat(pth, exe, 500 - len);
		if (!stop) beg = end + 1;
	} while (!stop && !found);
	return found;
}

int is_alias(char* word, linked_list * list){
	if(list->start == NULL)
		return 0;
	node * current_node = list->start;
	if(strcmp(word, current_node->alias_name) == 0){
		return 1;
	}
	
	for(current_node; current_node->next != NULL; current_node=current_node->next){
		if(strcmp(word, current_node->next->alias_name) == 0){
			return 1;
		}
	}
	return 0;
}

void execute_alias_command(char* word, linked_list * alias_list){
	node * current_node = alias_list->start;
	while(strcmp(word, current_node->alias_name) != 0)
	{
		current_node=current_node->next;
	}
	
	char* args;
	
	command_node * cn = create_command_node();
	linked_list * ll = cn->cmd;
	copystring(args, current_node->data);
	
	if(args[0] == '"'){
		int i;
		int length = strlen(args);
		char new_args[length-1];
		for(i = 0; i < length-2; ++i){
			new_args[i] = args[i+1];
		}
		new_args[length-2] = '\0';
		char* tok;
		const char delim[2] = " ";
		tok = strtok(new_args, delim);
		while(tok != NULL){
			char* test = use_env_var(tok);
			push_linked_list(ll,test);
			tok = strtok(NULL, delim);
		}
		execute_externel_command(cn, alias_list);
	} 
	else{
		push_linked_list(ll,args);
		execute_externel_command(cn, alias_list);
	}
}
 
void check_alias_list(linked_list* alias_list, char* name, char* cmd){
	if(find_alias_linked_list(alias_list, name) == 1){
		printf("Replaced the already existing alias\n");
		replace_value_alias_linked_list(alias_list, name, cmd);
	}
	else
		push_alias_linked_list(alias_list, name, cmd);
	
}

const char* use_env_var(char* tok){
	char * ret = tok;
	int i;
	int valid_so_far = 0;
	int start;
	int end;
	for (i = 0; i < strlen(ret); i++)
	{
		if(ret[i] == '$') start = i;
		if(ret[i] == '{' && i == start+1) valid_so_far = 1;
		if(ret[i] == '}' && valid_so_far)
		{
			char subbuf[4096];
			memcpy(subbuf, &ret[start], i-start+1);
			subbuf[i-start+1] = '\0';
			
			char * var;
			copystring(var, subbuf);
			var = var + 2; 				//get rid of ${
			var[i-start-2] = '\0';  		//get rid of ending }
			
			ret = replace(ret, subbuf, getenv(var));
		}
	}
	return ret;
}
