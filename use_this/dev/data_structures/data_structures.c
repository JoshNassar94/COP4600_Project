#include "data_structures.h"
#include <stdlib.h>

linked_list * create_linked_list(){
	linked_list * linkedlist = malloc(sizeof(linked_list));
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

void print_linked_list(linked_list * linkedlist){
	node * current_node = linkedlist->start;
	while(current_node->next !=NULL){
		puts(current_node->data);
		current_node = current_node->next;
	}
	puts(current_node->data);
}


