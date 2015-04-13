#include "data_structures.h"
#include <stdlib.h>
#include <stdio.h>

//Creates a new linked list with null start and end pointers
linked_list * create_linked_list(){
	linked_list * linkedlist = malloc(sizeof(linked_list));
	linkedlist->start = NULL;
	linkedlist->end = NULL;
	return linkedlist;
}

//Takes a linked list, deletes it, frees the memory it used
void free_linked_list(linked_list * linkedlist){
    node * current_node;
    node * next_current_node;
    current_node = linkedlist->start;
    while(current_node->next != NULL){
        
		next_current_node = current_node->next;
        free(current_node);
        current_node = next_current_node;
    }
	free(linkedlist);
}

//Takes linked list and a string.
//Creates a new node at the end of linked list with data=string input.
void push_linked_list(linked_list * linkedlist, char * data){
	node * new_node = malloc(sizeof(node));
	new_node->data = data;
	new_node->next = NULL;

	if(linkedlist->start != NULL){
		linkedlist->end->next = new_node;
		linkedlist->end = new_node;
	}else{
		linkedlist->start = new_node;
		linkedlist->end = new_node;
	}
}

//Takes alias linked list, string name, string data.
//Creates a new node at the end of linked list with data=data, alias_name=name.
void push_alias_linked_list(linked_list * linkedlist, char * name, char * data){
	node * new_node = malloc(sizeof(node));
	new_node->data = data;
	new_node->alias_name = name;
	new_node->next = NULL;

	if(linkedlist->start != NULL){
		linkedlist->end->next = new_node;
		linkedlist->end = new_node;
	}else{
		linkedlist->start = new_node;
		linkedlist->end = new_node;
	}
}

//Takes linked list, string data, int position.
//Creates new node at position in linked list, data=data.
void insert_linked_list(linked_list* linkedlist, char* data, int position){
	node * current_node = linkedlist->start;
	if(current_node == NULL){
		return;
	}
	
	if(position == 0){
		if(linkedlist->start == NULL){
			push_linked_list(linkedlist, data);
			return;
		}
		else{
			node* new_node = malloc(sizeof(node));
			new_node->data = data;
			new_node->next = current_node;
			linkedlist->start = new_node;
			return;
		}
	}
	--position;
	
	while(current_node->next !=NULL){
		if(position == 0){
			node* new_node = malloc(sizeof(node));
			new_node->data = data;
			node* tmp = current_node->next;
			current_node->next = new_node;
			new_node->next = tmp;
			return;
		}
		--position;
		current_node = current_node->next;
	}
}

//Takes linked list.
//Prints data from every node in linked list sequentially.
void print_linked_list(linked_list * linkedlist){
	node * current_node = linkedlist->start;
	if(current_node == NULL){
		return;
	}
	while(current_node->next !=NULL){
		puts(current_node->data);
		current_node = current_node->next;
	}
	puts(current_node->data);
}

//Takes alias linked list.
//Prints alias_name and data from every node in linked list sequentially.
void print_alias_linked_list(linked_list * linkedlist){
	node * current_node = linkedlist->start;
	if(current_node == NULL){
		puts("There are currently no aliases!");
		return;
	}
	while(current_node->next !=NULL){
		printf("%s = %s\n",current_node->alias_name, current_node->data);
		current_node = current_node->next;
	}
	char* output = current_node->alias_name;
	printf("%s = %s\n",current_node->alias_name, current_node->data);
}

//Takes linked list and int position.
//Removes the node at position from linked list.
void remove_linked_list(linked_list * linkedlist, int position){
	node * current_node = linkedlist->start;
	if(current_node == NULL){
		return;
	}
	
	if(position == 0){
		linkedlist->start = current_node->next;
		return;
	}
	--position;
	
	while(current_node->next !=NULL){
		if(position == 0){
			current_node->next = current_node->next->next;
			return;
		}
		--position;
		current_node = current_node->next;
	}
}

//Takes linked list and string name.
//Removes the node with alias_name=name from linked list.
void remove_alias_linked_list(linked_list * linkedlist, char * name){
	node * current_node = linkedlist->start;
	if(current_node == NULL){
		puts("That alias does not exist");
		return;
	}
	
	if(strcmp(current_node->alias_name, name) == 0){
		linkedlist->start = current_node->next;
		return;
	}
	while(current_node->next !=NULL){
		if(strcmp(current_node->next->alias_name, name) == 0){
			current_node->next = current_node->next->next;
			return;
		}
		current_node = current_node->next;
	}
	puts("That alias does not exist");
}

//Creates command node with next=NULL and index=-1.
command_node * create_command_node(){
	command_node * commandNode = malloc(sizeof(command_node));
	commandNode->cmd = create_linked_list();
	commandNode->next = NULL;
	commandNode->index = -1;
	
	return commandNode;
}

//Takes alias linked list and string name.
//Search for node in linked list with alias_name=name.
//If it exists, return 1. Else, return 0.
int find_alias_linked_list(linked_list * linkedlist, char* name){
	if(linkedlist->start == NULL){
		return 0;
	}
	node * current_node = linkedlist->start;
	if(strcmp(current_node->alias_name, name) == 0){
		return 1;
	}
	while(current_node->next != NULL){
		if(strcmp(current_node->next->alias_name, name) == 0)
			return 1;
		current_node = current_node->next;
	}
	return 0;
}

//Takes alias linked list and string name.
//Search for node in linked list with alias_name=name.
//If it exists, return data stored in node. Else, return 0.
char* get_alias_linked_list(linked_list* linkedlist, char* name){
	if(linkedlist->start == NULL){
		return 0;
	}
	node * current_node = linkedlist->start;
	if(strcmp(current_node->alias_name, name) == 0){
		return current_node->data;
	}
	while(current_node->next != NULL){
		if(strcmp(current_node->next->alias_name, name) == 0)
			return current_node->next->data;
		current_node = current_node->next;
	}
	return 0;
}

//Takes alias linked list, string name, string cmd.
//Finds node with alias_name=name.
//Sets data=cmd, returns.
void replace_value_alias_linked_list(linked_list * linkedlist, char* name, char* cmd){
	node * current_node = linkedlist->start;
	if(strcmp(current_node->alias_name, name) == 0){
		current_node->data = cmd;
		return;
	}
	while(current_node->next != NULL){
		if(strcmp(current_node->next->alias_name, name) == 0)
			current_node->next->data = cmd;
			return;
	}
}
