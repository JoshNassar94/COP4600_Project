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
#define STDIN_FILENO 0
#define STDOUT_FILENO 1
#define STDERR_FILENO 2

void resolve_input(char* in_file)
{
	if (in_file)
	{
		int fd;
		fd = open(in_file, O_RDONLY);
		if (fd == -1)
		{
			perror("error: could not open file");
			exit(1);
		}
		close(STDIN_FILENO);
		dup(fd);
		close(fd);
	}
	else
	{

	}
}

void resolve_output(char* out_file, int append)
{
	if (out_file)
	{	
		int fd;
		if (append) fd = open(out_file, O_WRONLY | O_APPEND | O_CREAT , S_IREAD | S_IWRITE);
		else fd = open(out_file, O_WRONLY | O_TRUNC | O_CREAT, S_IREAD | S_IWRITE);
		if (fd == -1)
		{
			perror("error: in user_created_commands.c");
			exit (1);
		}
		close(STDOUT_FILENO);
		dup(fd);
		close(fd);
	}
	else
	{
		/*perror("WE ARE HERE");
		int fd;
		fd = open("/dev/tty", O_WRONLY);
		close(1);
		dup(fd);*/
	}
}

void execute_externel_command(command_node * commandNode, linked_list * alias_list){
	char * command;
	char ** arguments;
	char ** envp = {NULL};
	//char * envp = getenv("PATH");
	
	linked_list * linkedlist = commandNode->cmd;
	linked_list* ll_copy = create_linked_list();
	
	//count the number of elements in the linked list so we know how much memory to allocate for the array;
	int list_element_count=1;
	node * current_node = linkedlist->start;
	int index;
	int counter = 1;
	push_linked_list(ll_copy, current_node->data);
	for(current_node = linkedlist->start; current_node->next != NULL; current_node=current_node->next){
		push_linked_list(ll_copy, current_node->next->data);
		counter++;
	}
	
	int list_iter;
	current_node = linkedlist->start;
	node* copy_curr_node = ll_copy->start;
	for(list_iter = 0; list_iter < counter-1; ++list_iter){
		index = isWildcard(copy_curr_node->next->data);
		if(index != -1){
			char* word = copy_curr_node->next->data;
			linked_list* files = create_linked_list();
			int numFiles = 0;
			DIR *d;
			struct dirent *dir;
			d = opendir(getenv("PWD"));
			if(d){
				while (dir = readdir(d)){
					push_linked_list(files, dir->d_name);
					++numFiles;
				}
			}
			remove_linked_list(files, numFiles);
			remove_linked_list(files, numFiles-1);
			numFiles -= 2;
			list_element_count += addWildcardArguments(files, numFiles, 0, linkedlist, copy_curr_node->next, index, word, list_element_count);
			free_linked_list(files);
			copy_curr_node=copy_curr_node->next;
			remove_linked_list(linkedlist, list_element_count);
		}
		else{
			list_element_count++;
			copy_curr_node=copy_curr_node->next;
		}
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
		retokenize(new_args);
		return;
	}
	retokenize(args);
	return;
}
 
void check_alias_list(linked_list* alias_list, char* name, char* cmd){
	if(find_alias_linked_list(alias_list, name) == 1){
		printf("Replaced the already existing alias\n");
		replace_value_alias_linked_list(alias_list, name, cmd);
	}
	else{
		push_alias_linked_list(alias_list, name, cmd);
	}
	
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

int which_command(command_node * cn)
{	
	/*printf("FOR: ");
	print_linked_list(cn->cmd);
	printf("next: %p\n", cn->next);
	printf("index: %d\n", cn->index);*/
	if (cn->next == NULL && cn->index == 0) return 0; //only one
	if (cn->next != NULL && cn->index == 0) return 1; //first node
	if (cn->next != NULL && cn->index != 0) return 2; //middle node
	if (cn->next == NULL && cn->index != 0) return 3; //last node
}


int isWildcard(char* word){
	int length = strlen(word);
	int i;
	for(i = 0; i < length; ++i){
		if(word[i] == '*' || word[i] == '?'){
			return i;
		}
	}
	return -1;
}

int addWildcardArguments(linked_list* files, int numFiles, int numMatchingStart, linked_list* ll, node* current, int index, char* word, int insertAt){
	int numMatchingFiles = 0;
	int word_length = strlen(word);
	int i;
	for(i = index; i < word_length; ++i){
		if(word[i] == '*' || word[i] == '?'){
			int file_iter;
			node* current_node = files->start;
			int curr_index = 0;
			for(file_iter = 0; file_iter < numFiles; ++file_iter){
				int file_length = strlen(current_node->data);
				if(i == 0){							//check from back
					if(checkFromBack(word_length, i, file_length, word, current_node)){
						if(word[i] == '?'){
							if(strlen(word) == strlen(current_node->data)){
								++numMatchingFiles;
								++curr_index;
							}
						}
						else{
							++numMatchingFiles;
							++curr_index;
						}
					}
					else{
						remove_linked_list(files, curr_index);
					}
				}
				else if(i == word_length-1){		//check from front
					if(checkFromFront(i, word, current_node)){
						if(word[i] == '?'){
							if(strlen(word) == strlen(current_node->data)){
								++numMatchingFiles;
								++curr_index;
							}
						}
						else{
							++numMatchingFiles;
							++curr_index;
						}
					}
					else{
						remove_linked_list(files, curr_index);
					}
				}
				else{								//check from front and back
					if(checkFromFront(i, word, current_node) && checkFromBack(word_length, i, file_length, word, current_node)){
						if(word[i] == '?'){
							if(strlen(word) == strlen(current_node->data)){
								++numMatchingFiles;
								++curr_index;
							}
						}
						else{
							++numMatchingFiles;
							++curr_index;
						}
					}
					else{
						remove_linked_list(files, curr_index);
					}
				}
				current_node = current_node->next;
			}
			numFiles = numMatchingFiles;
		}
	}
	node* curr = files->start;
	for(i = 0; i < numMatchingFiles; ++i){
		insert_linked_list(ll, curr->data, insertAt);
		curr = curr->next;
	}
	return numMatchingFiles;
}

int checkFromBack(int word_length, int index, int file_length, char* word, node* current_node){
	int j, k;
	for(j = word_length-1, k = file_length-1; j > index; --j, --k){
		if(word[j] != current_node->data[k]){
			return 0;
		}
	}
	return 1;
}

int checkFromFront(int index, char* word, node* current_node){
	int j;
	for(j = 0; j < index; ++j){
		if(word[j] != current_node->data[j]){
			return 0;
		}
	}
	return 1;
}

char* remove_quotes(char* word){
	char* ret = word;
	if(ret[0] == '"'){
		ret++;
		ret[strlen(ret)-1] = 0;
	}
	return ret;
}
