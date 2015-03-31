#ifndef USER_CREATED_COMMANDS_H
#define USER_CREATED_COMMANSA_H
#include "data_structures/data_structures.h" 

int is_alias(char*, linked_list *);

void execute_alias_command(char*, linked_list *);

//Executes a command defined outside of bash given a linked list. The first element of the linked list is the command and the elements that follow it are parameters to that command.
void execute_externel_command(command_node *, linked_list *);

void check_alias_list(linked_list*, char*, char*);

const char* use_env_var(char*);
#endif
