# COP4600_Project
A korn shell for Linux created by Joshua Nassar and Alex Smith.

The main method is inside of the yacc file, as well as some functions.
Most of the functions are in a file called user_created_commands.c.
The linked list data structure is contained within data_structures.c.


FEATURES NOT IMPLEMENTED
--------------------------

1) File Name Completion

2) Using 3 or more pipes ending in an alias and trying to output to file
	For example:
	
	alias a ls
	alias b wc
	a | b | b > out.txt
	
3) Wildcard matching using more than one * or ? in a word

FEATURES IMPLEMENTED
------------------------

1) Input Types

	-word
	
	-white space
	
	-metacharacters
	
	
2) Built-in Commands

	-setenv variable word
	
	-printenv
	
	-unsetenv variable
	
	-alias name word
	
	-bye
	
	
3) Other Commands

	-I/O redirection
	
	-Piping
	
	-Redirection of standard error
	
	-Commands checking either PATH or current directory if prefaced by /
	
	-Running programs in the background with &
	

4) Aliases

	-alias
	
	-alias name word
	
		*alias expansion on first word of a command
		
		*nested aliases
		
		*detects infinte alias expansion
		
	-unalias name
	
	
5) Environment Variable Expansion ${variable}

	-substitutes value of variable
	
6) Wildcard Matching

	-works with one of * or ? at any point in word


7) Tilde Expansion

	- ~name
	 
	- ~ not followed by a user name

ISSUES
---------

1) output when redirecting input into the shell is out of order. All the prompts are printed after execution.
