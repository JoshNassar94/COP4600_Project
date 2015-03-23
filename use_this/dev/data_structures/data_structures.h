#ifndef DATA_STRUCTURES_H
#define DATA_STRUCTURES_H
typedef struct node{
	char * data;
	struct node * next;
} node;

typedef struct linked_list{
	struct node * start;
	struct node * end;
} linked_list;

//creates an instance of a linked list
linked_list * create_linked_list();

//frees the memory of a linked list
void free_linked_list(linked_list * linkedlist);

//adds an element to a linked list
void push_linked_list(linked_list * linkedlist, char * data);

//function used for debugging linked list. Simply traverse the linked list and print all its elements.
void print_linked_list(linked_list * linkedlist);


#endif
