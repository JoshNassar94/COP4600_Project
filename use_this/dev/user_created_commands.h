#ifndef USER_CREATED_COMMANDS_H
#define USER_CREATED_COMMANSA_H
#include "data_structures/data_structures.h" 

//Executes a command defined outside of bash given a linked list. The first element of the linked list is the command and the elements that follow it are parameters to that command.
void execute_externel_command(linked_list * linkedlist);

#endif
