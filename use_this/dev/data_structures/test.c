#include <stdio.h>
#include <stdlib.h>
#include "data_structures.h"
int main(){
	linked_list * linkedlist = create_linked_list();
	push_linked_list(linkedlist,"Hello");
	push_linked_list(linkedlist,"Goodbye");
	push_linked_list(linkedlist,"Hello");
	push_linked_list(linkedlist,"Goodbye");
	push_linked_list(linkedlist,"Beatles");
	print_linked_list(linkedlist);
	free_linked_list(linkedlist);
	
}
