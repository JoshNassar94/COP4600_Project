/*
Precedence Rules:
	Rules that are matched more specifically come first.
	If both match the same, first rule written in this file is used.
*/
%{
#include <stdio.h>
#include "y.tab.h"
%}
%%
cd          			return CD;
bye				return BYE;
printenv			return PRINT_ENV;
setenv				return SET_ENV;
unsetenv			return UNSET_ENV;
alias				return ALIAS;
unalias				return UNALIAS;
&				return AMPERSAND;
\\[^\n]			yylval.string=strdup(yytext); return ESCAPE;
2\>&1				return ERR_TO_OUT;
2\>				return ERR_GT;
\<				return LT;
\>\>				return GTGT;
\>				return GT;
\|				return PIPE;
\"[^\\\n]+\"		yylval.string=strdup(yytext); return WORD;
[^\<\>\|&\\ \n]+								yylval.string=strdup(yytext); return WORD;
\n          			return NEW_LINE;       
[ \t]+                  /* ignore whitespace */;
%%

//This function takes in a string, tokenizes it, and calls yyparse
void retokenize(char* str){
	const int length = strlen(str);
	char buf[length+1];
	strcpy(buf, str);
	strcat(buf, "\n");
	
	yy_switch_to_buffer(yy_scan_string(buf));
    if(yyparse())
		printf("ERROR IN PARSING THE INPUT\n");
}
