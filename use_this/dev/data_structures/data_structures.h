#ifndef DATA_STRUCTURES_H
#define DATA_STRUCTURES_H

typedef struct node{
	char * data;
	char * alias_name;
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
void push_alias_linked_list(linked_list *, char *, char *);

//function used for debugging linked list. Simply traverse the linked list and print all its elements.
void print_linked_list(linked_list * linkedlist);
void print_alias_linked_list(linked_list *);

typedef struct command_node{
	linked_list * cmd;
	linked_list * next;
	char * in_file;
	char * out_file;
	char * err_file;
	int append;
} command_node;

//creates an instance of a command_node
command_node * create_command_node();
void remove_alias_linked_list(linked_list *, char *);

int find_alias_linked_list(linked_list *, char*);

void replace_value_alias_linked_list(linked_list *, char*, char*);
#endif
