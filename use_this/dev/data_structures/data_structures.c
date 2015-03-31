#include "data_structures.h"
#include <stdlib.h>
#include <stdio.h>

linked_list * create_linked_list(){
	linked_list * linkedlist = malloc(sizeof(linked_list));
	linkedlist->start = NULL;
	return linkedlist;
}

void free_linked_list(linked_list * linkedlist){
    node * current_node;
    node * next_current_node;
    current_node = linkedlist->start;
    while(current_node->next != NULL){
        
		next_current_node = current_node->next;
        //free the node itself
        free(current_node);
        current_node = next_current_node;
    }
	free(linkedlist);
}

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


command_node * create_command_node(){
	command_node * commandNode = malloc(sizeof(command_node));
	commandNode->cmd = create_linked_list();
	command_node * next = NULL;
	return commandNode;
}

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
	}
	return 0;
}

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
