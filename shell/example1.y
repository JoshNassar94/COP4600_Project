%{
#include <stdio.h>
#include <string.h>
 
void yyerror(const char *str)
{
        fprintf(stderr,"error: %s\n",str);
}
 
int yywrap()
{
        return 1;
} 
  
main()
{
        yyparse();
} 
%}
%token NUMBER BYE CD ARG
%%
commands: /* empty */
        | commands command
        ;
command:
        exit_now;

exit_now:
		BYE
		{
				printf("Exiting the shell now...\n");
				exit(0);
		};
%%
